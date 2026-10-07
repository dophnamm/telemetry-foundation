# Prior art for a node-local telemetry "flight recorder" and for support bundles in on-prem / air-gapped Kubernetes products

Scope: build-vs-reuse input for a custom OTel Collector component `flightrecorder` (always-on DEBUG logs, possibly traces, kept in a node-local ring buffer of about 2 GiB / 15 min per node, with a 24 h snapshot kept on FATAL or an error spike), and for locally generated, redacted, hand-carried support bundles. Research date: 2026-10-07. Versions current at that date: OTel Collector core v1.1.0 / contrib v0.162.0 (released 2026-09-29, [release](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.162.0)), Fluent Bit 5.1.3 (2026-10-01), Vector v0.59.0 (2026-10-06), dotnet-monitor v10.0.4 (2026-09-08), Replicated troubleshoot v0.134.1 (2026-09-14), sos 4.12.0 (2026-08-17), rancher/support-bundle-kit v0.0.98 (2026-09-29), crashd v0.4.3 (2025-05-22), Elastic support-diagnostics v9.4.1 (2026-07-02). These versions come from each project's GitHub releases list, read with `gh release list` on 2026-10-07.

## Q1. Which OpenTelemetry Collector components (core + contrib, 2026) could provide a time-windowed local buffer or trigger-based retention? Are there proposals or third-party components?

### Takeaway
No core or contrib component implements what `flightrecorder` needs: a node-local, drop-oldest, time- or size-bounded buffer for **logs**, plus a trigger that freezes a window into a retained snapshot. The nearest building blocks each cover only part of it:
- `fileexporter` with size-based rotation (alpha), plus `otlpjsonfile`/`filelog` to read the data back.
- `file_storage` (beta) with the persistent `sending_queue`. This is a delivery queue that rejects new data when full, not a ring buffer.
- `tail_sampling` (beta, traces only) with `decision_wait`, optionally backed by the alpha `pebble_tail_storage` extension behind an alpha feature gate.

Related upstream work is all early-stage or not donated: a Go-runtime `flightrecorderreceiver` donation (sponsor needed), a VictoriaMetrics retroactive-sampling prototype (not donated), a zpages "support bundle" proposal (open, 2026-09), and Telemetry Policy (OTEP merged, processor in development). So the trigger/snapshot logic would have to be built. The storage, rotation, redaction and OpAMP pieces can be reused.

### Cited Findings

**Persistent queue / storage**
- `file_storage` extension: stability **beta**, in the contrib and k8s distributions. It persists state to a bbolt database under `directory` (default `/var/lib/otelcol/file_storage`). Its keys:
  - `max_size`: "When a write would need the file to grow past this limit, the write is rejected with a storage-full error".
  - `fsync`: "will force the database to perform an fsync after each write… at the cost of performance".
  - `create_directory` / `directory_permissions` (default `0750`).
  - `recreate`: renames a corrupted bbolt DB to `{filename}.{ISO 8601 timestamp}.backup` and starts fresh.
  - `compaction.on_start` / `compaction.on_rebound` / `compaction.directory` / `compaction.max_transaction_size` (default 65536).
  — [filestorage README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/storage/filestorage)
- Exporter helper `sending_queue` keys: `enabled` (default true), `num_consumers` (10), `wait_for_result`, `block_on_overflow`, `sizer` (`requests` | `items` | `bytes`, where bytes is "the least performant option"), `queue_size` (default 1000), and `storage` (a storage extension ID, which turns on persistence).
  - "If data cannot be added to the sending queue, it is typically dropped. This occurs when the queue has reached its configured capacity or, for persistent queues, when the underlying storage cannot accept additional data".
  - On restart "the items will be picked and the exporting is continued". Auth-extension context is not propagated through the persistent queue.
  — [exporterhelper README](https://github.com/open-telemetry/opentelemetry-collector/tree/main/exporter/exporterhelper)
- Open bug (2026-08-07, Collector 0.151.0): "When using the persistent sending queue with `fsync: false`, logs buffered while the exporter is unable to reach its destination are lost if the Collector is restarted before connectivity is restored." — [contrib#50102](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/50102)

**File rotation and read-back**
- `fileexporter`: stability **alpha** for traces/metrics/logs, development for profiles.
  - `rotation` is "only enabled when `rotation:` is present". Sub-keys: `max_megabytes` (default 100), `max_days` ("only controls retention, it does not trigger rotation"), `max_backups` (default 100), `localtime`.
  - "Rotation is size-based only; `max_days` and `max_backups` only control how many rotated files are kept". Rotated files are renamed like `data-2022-09-14T05-02-14.173-size.json`.
  - Other keys: `format` (json|proto), `compression` (`zstd`), `flush_interval` (default 1s), `append` ("cannot be combined with `rotation`"), `group_by.resource_attribute`, `max_open_files`.
  - "Use the OTLP JSON File receiver to read the data back into the collector. It only reads uncompressed, newline-delimited OTLP JSON".
  — [fileexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/fileexporter)
- `otlpjsonfile` receiver: stability **alpha** for traces, metrics and logs. — [otlpjsonfilereceiver README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/otlpjsonfilereceiver)
- `filelog` receiver: stability **beta** (logs).
  - `start_at` default `end` (alternatively `beginning`).
  - `storage` keeps file offsets; "If no storage extension is used, the receiver will manage offsets in memory only".
  - `delete_after_read` needs the `filelog.allowFileDeletion` feature gate.
  - `exclude_older_than`, `ordering_criteria.*`, `max_log_size` (default 1MiB), `retry_on_failure.*`.
  — [filelogreceiver README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/filelogreceiver)

**Tail-sampling buffers (traces only)**
- `tail_sampling` processor: stability **beta**, traces only.
  - `decision_wait` (default 30s), `num_traces` (default 50000), `decision_cache.sampled_cache_size` / `non_sampled_cache_size`, `maximum_trace_size_bytes`, `drop_pending_traces_on_shutdown`, `sampling_strategy` (`trace-complete` default, or `span-ingest`).
  - A `tail_storage` option requires the `processor.tailsamplingprocessor.tailstorageextension` feature gate. The README says it is "under active development".
  — [tailsamplingprocessor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor)
- `pebble_tail_storage` extension: stability **alpha**. It "stores pending trace data on local disk" in a Pebble DB.
  - Keys: `directory`, `max_storage_size_mib` (0 = unlimited), `on_read_error` (`drop_trace` | `return_partial`).
  - Size limit semantics: "samples the on-disk size of the database once per second. When the last observed size is above the limit, new appends fail". "The limit is best-effort". Pebble reclaims space asynchronously through compaction.
  - The gating feature gate is alpha and disabled by default.
  — [pebbletailstorageextension README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/tailstorage/pebbletailstorageextension)
- `adaptive_tail_sampling` processor (formerly `dynamic_sampling`): stability **alpha**, traces, contrib only.
  - Spans are accumulated in memory per trace. A decision is triggered by a root span, by `trace_timeout`, or by `span_limit` (default 10000).
  - The tracking issue decided an eviction policy for when `num_traces` is full: "the oldest pending trace is evicted and receives a real decision immediately".
  — [adaptivetailsamplingprocessor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/adaptivetailsamplingprocessor); [contrib#49311](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/49311)

**Proposals and third-party work**
- Retroactive sampling in OTel: VictoriaMetrics described a prototype "retroactive sampling processor" for agents plus a sampling server. Agents buffer spans in "an on-disk FIFO queue instead of an in-memory buffer" for "a configured retention period (e.g., 1 minute)". They send 33-byte summaries centrally and forward only the sampled trace IDs. Claimed results vs tail sampling: "reduces compressed traffic by 70%", "saving 60–70% of CPU and memory". VictoriaMetrics states "no such implementation exists in the OpenTelemetry collector". — [VictoriaMetrics blog (KubeCon EU 2026)](https://victoriametrics.com/blog/kubecon-eu-2026-sampling/)
- The OTel blog post on retroactive sampling was rejected/closed on 2026-06-25. A maintainer wanted "the work done in the Collector before the blog post". Another suggested contributing it to the tail sampling processor as a mode that forwards reduced records to a sampling service. — [opentelemetry.io#10533](https://github.com/open-telemetry/opentelemetry.io/issues/10533)
- `flightrecorderreceiver` donation (opened 2026-02-14, label "Sponsor Needed", still open). It reads **Go runtime** FlightRecorder trace files (`include: /tmp/flightrecorder/*`, `collection_interval`) and turns them into OTel profiles and metrics.
  - As of 2026-07-21 a sponsor from a different company was still needed, because both proposer and sponsor are at Elastic.
  - The proposer says the conversion "is not lossless".
  - Implementation: [florianl/flightrecorderreceiver](https://github.com/florianl/flightrecorderreceiver).
  — [contrib#46089](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/46089)
- A support bundle from a running Collector via the zpages extension was proposed (opened 2026-09-24, open, "waiting-for-codeowners"). The phased plan:
  - Off by default (`support_bundle.enabled: false`), served at `GET /debug/supportbundle` as a zip.
  - A `manifest.yaml` with bundle ID, capture times, build info and "SHA-256 of each" file.
  - Running config "unexpanded and redacted; the expanded config is never written".
  - An env var allowlist the operator owns, which a request cannot extend.
  - "Remote retrieval goes only through OpAMP, not arbitrary uploads".
  - A windowed collection (`?duration=`) for internal metrics and CPU profiles.
  - It cites the Grafana Alloy PoC ([alloy#7002](https://github.com/grafana/alloy/pull/7002)), Elastic `elasticdiagnostics`, and Datadog flare.
  — [collector#16017](https://github.com/open-telemetry/opentelemetry-collector/issues/16017)
- Telemetry Policy OTEP (merged 2025-11-17). It defines declarative, dynamically sourced policies such as an example "drop-debug-logs" policy (`severity_text` regex `^(DEBUG|TRACE)$`). It says "OpAMP may serve as a policy provider through custom messages". — [OTEP 4738](https://github.com/open-telemetry/opentelemetry-specification/blob/main/oteps/4738-telemetry-policy.md)
- The implementing `telemetry_policy` processor and the `file_telemetry_policy` extension are both stability **development** ("work-in-progress"). Their donation issue is open (2026-09-14). — [telemetrypolicyprocessor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/telemetrypolicyprocessor); [contrib#50965](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/50965)

**OpAMP and log-level control**
- OpAMP spec status is **Beta**. It defines the `AcceptsRemoteConfig` capability and `ConnectionSettingsOffers.own_logs` / `own_metrics`. Several newer messages (custom messages, available components) are marked "Development". — [OpAMP specification](https://github.com/open-telemetry/opamp-spec/blob/main/specification.md)
- `opampextension`: stability **alpha** — [README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/opampextension).
- OpAMP Supervisor: stability **alpha**. It persists remote config state to disk and has a startup fallback config. `agent::collector_crash_log_snippet_kib` can add the tail of Collector logs to failure messages. It is "disabled by default because Collector logs may contain sensitive data". — [opampsupervisor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/opampsupervisor)
- Collector self-telemetry log level is `service::telemetry::logs::level` (default `INFO`; also `DEBUG`, `WARN`, `ERROR`). Logs are sampled by default: `sampling::enabled: true`, `tick 10s`, `initial 10`, `thereafter 100`. — [Collector internal telemetry docs](https://opentelemetry.io/docs/collector/internal-telemetry/)
- Other contrib components in development that are tangentially related: `remotetap` extension (development), "allows users of the collectors to visualize data going through pipelines" — [remotetapextension README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/remotetapextension).

### Inferences

**Fit of each existing piece for `flightrecorder`**

| Candidate | Maturity | Fit | Why |
|---|---|---|---|
| `fileexporter` + `rotation` → files on hostPath | alpha | **Medium (best reuse base)** | It gives a size-bounded rolling set of files (`max_megabytes` × `max_backups` ≈ ring buffer by size). It has no time-based eviction (`max_days` only, granularity of days) and no snapshot or trigger. A snapshot could be done by hard-linking or copying the rotated files into a retained directory. Read-back goes through `otlpjsonfile`, which only reads uncompressed JSON. |
| `file_storage` + persistent `sending_queue` | beta | **Low** | It is designed to drain to an exporter, and it rejects new data when full (drop-newest), which is the opposite of a ring buffer. bbolt compaction behaviour and the `fsync` trade-off (#50102) are relevant cautions. |
| `filelog` re-reading app log files | beta | **Medium for ingest** | It reads files written by apps or the kubelet. With `start_at: beginning` and no `storage` it re-reads. It could re-ingest a snapshot, but provides no retention. |
| `tail_sampling` + `pebble_tail_storage` | beta / alpha + alpha gate | **Low for logs, partial for traces** | It is traces-only. The decision window is seconds to minutes, not a 15-min/24-h retention. When the Pebble size limit is hit, *appends fail* (drop-newest). Its "keep on ERROR status" policy is the closest analogue to a trigger, but only for spans. |
| `adaptive_tail_sampling` | alpha | **Low** | Traces only. Useful as a design reference for its eviction-on-full policy. |
| `redaction` / `transform` / `filter` processors | redaction alpha (logs), beta (traces) | **High (reuse)** | Put them *before* the buffer so PII never reaches disk (see Q3). |
| OpAMP extension/supervisor + Telemetry Policy | alpha / development | **Medium (control plane)** | Can push config, including a raised log level. Neither the spec nor the READMEs reviewed show a built-in "temporary/TTL" level change, so revert logic would be custom. |
| `flightrecorderreceiver` (third party, donation pending) | not in contrib | **Complementary only** | It ingests Go *runtime* execution traces, not app DEBUG logs. Could be added later to capture Go runtime context around incidents. |
| Hypothetical zpages support bundle (#16017) | proposal | **Watch / align** | Its manifest, SHA-256, redacted-config and OpAMP-only retrieval principles are a ready-made spec for the Collector's own part of a bundle. |

- Net: the trigger detection, the time-window eviction and snapshot semantics need custom code. The likely best approach is a custom exporter or processor that writes rotating segment files and stores the snapshot as a set of frozen segments. Persistence format (OTLP JSON/proto + zstd), redaction and remote control can be reused.
- Nothing upstream evicts the oldest data by *time* for logs. This is a real gap, not a configuration problem.

### Gaps
- Not checked: whether any vendor distribution (Splunk, Elastic EDOT, Grafana Alloy, BindPlane, Honeycomb) ships a private "debug ring buffer" Collector component. GitHub issue search for "flight recorder", "ring buffer logs", "circular buffer" and "buffer logs until error" in contrib found only the items above.
- Formal stability label of the `exporterhelper` `sending_queue` in core v1.1.0: not confirmed from the README.
- No source found for a built-in TTL/auto-revert for OpAMP-pushed log levels.

## Q2. What research and industry prior art exists for retroactive ("before the error") capture?

### Takeaway
The pattern is well established: always record into a bounded buffer that overwrites the oldest data, cheaply, and persist or export a window only when a symptom fires. Hindsight (NSDI'23) is the academic reference for distributed traces. Go's `trace.FlightRecorder` (1.25), JFR continuous recording plus `JFR.dump`, Perfetto `RING_BUFFER` + `STOP_TRACING`/`CLONE_SNAPSHOT`, and `perf record --overwrite --switch-output` are runtime and OS equivalents. .NET log buffering, AWS Powertools log buffering and Sentry breadcrumbs / Replay "buffer mode" are in-process, logs-before-error equivalents. Most of these keep **seconds to a few minutes** in **memory** and are per-process. A node-wide, disk-backed, 15-min/24-h design like `flightrecorder` is at the large end of the range.

### Cited Findings

**Hindsight (NSDI'23)**
- "The Benefit of Hindsight: Tracing Edge-Cases in Distributed Systems", by Lei Zhang, Zhiqiang Xie, Vaastav Anand, Ymir Vigfusson and Jonathan Mace. It "implements a retroactive sampling abstraction: instead of eagerly ingesting and processing traces, Hindsight lazily retrieves trace data only after symptoms of a problem are detected." — [USENIX NSDI'23 page](https://www.usenix.org/conference/nsdi23/presentation/zhang-lei)
- Results: "nanosecond-scale overhead when generating trace data, can scale to 55 GB/s of data per node… coherently captures problematic traces (>99%)… within 100 ms of identifying a symptom". "We have integrated Hindsight with OpenTelemetry". — [Hindsight paper PDF](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf)
- Mechanism details (same PDF):
  - Each agent "pre-allocates a fixed-size buffer pool in shared memory", subdivided into "fixed-size buffers (default 32 kB)".
  - The agent "will evict traces when the index exceeds a threshold of buffer pool capacity (default 80%) by removing the least-recently used untriggered traceId". Eviction is "atomically at the granularity of a trace".
  - Triggers are rate-limited per `triggerId` ("if the trigger exceeds a per-triggerId rate-limit, the agent will immediately discard the trigger"). Triggered traces "can no longer be evicted".
  - Breadcrumbs let a coordinator find other nodes' data.
  - "Event horizon" = time between generating data and overwriting it. "as low as tens of seconds is reasonable".
  - They "chose a fixed-size buffer pool to better bound memory overheads".
- Open-source code: [gitlab.mpi-sws.org/cld/tracing/hindsight](https://gitlab.mpi-sws.org/cld/tracing/hindsight). The README points to the [arXiv preprint](https://arxiv.org/abs/2202.05769). The GitLab API shows the latest commits dated 2022-05-02 ("Repository cleanup"), so this is a research prototype.

**Go runtime**
- Go 1.25 flight recorder (blog by Carlos Amedee and Michael Knyszek, 2025-09-26). It buffers execution-trace data in memory to capture "the last few seconds of execution leading up to the moment a program detects there's been a problem".
  - API: `trace.NewFlightRecorder(cfg)`, `FlightRecorderConfig{MinAge, MaxBytes}`, `Start`, `Stop`, `WriteTo`, `Enabled`.
  - Guidance: MinAge about 2× the problem window. Expect "a few MB of trace data to be produced per second of execution, or 10 MB/s for a busy service".
  - The example snapshots once when a request exceeds 100 ms.
  — [go.dev blog](https://go.dev/blog/flight-recorder)
- Source docs: "At most one flight recorder may be active at any given time". "Only one goroutine may execute WriteTo at a time". `MaxBytes` "takes precedence over MinAge… Treat it as a hint". — [runtime/trace/flightrecorder.go](https://go.dev/src/runtime/trace/flightrecorder.go)

**Java (JFR)**
- `-XX:StartFlightRecording` parameters: `disk` (default true), `maxage` ("Maximum age of disk data to keep", default unlimited), `maxsize` (must be ≥ `maxchunksize`), `dumponexit` (default false), `filename`, and `settings` (`default.jfc` "suitable for continuous recording" vs `profile.jfc`).
- `-XX:FlightRecorderOptions` has `maxchunksize` (default 12 MB), `memorysize` (default 10 MB), `repository`, `preserve-repository` (default false), `threadbuffersize`, `stackdepth` (default 64).
- [java command (JDK 21)](https://docs.oracle.com/en/java/javase/21/docs/specs/man/java.html)
- `jcmd <pid> JFR.dump` writes data "while a flight recording is running". "The recording continues to run after the data is written". It supports `begin`/`end` time filters. — [jcmd (JDK 21)](https://docs.oracle.com/en/java/javase/21/docs/specs/man/jcmd.html)

**.NET**
- dotnet-monitor collection rules = Filters + Trigger + Actions + Limits. They work only in Listen mode.
  - Triggers: `Startup`, `AspNetRequestCount`, `AspNetRequestDuration`, `AspNetResponseStatus`, `EventCounter`, `EventMeter`.
  - Actions: `CollectDump`, `CollectGCDump`, `CollectTrace`, `CollectLogs`, `CollectExceptions`, `CollectStacks`, `Execute`, `LoadProfiler`, `SetEnvironmentVariable`, `GetEnvironmentVariable`.
  — [collectionrules.md](https://github.com/dotnet/dotnet-monitor/blob/main/documentation/collectionrules/collectionrules.md)
- `CollectLogs` has a `Duration` (default 30 s, max 1 day). It collects logs *after* the trigger fires; it is not retroactive.
- Limits: `ActionCount` (default 5), `ActionCountSlidingWindowDuration` (1 s to 1 day), `RuleDuration`.
- [collection-rule-configuration.md](https://github.com/dotnet/dotnet-monitor/blob/main/documentation/configuration/collection-rule-configuration.md)
- .NET log buffering (.NET 9+; packages `Microsoft.Extensions.Telemetry` and `Microsoft.AspNetCore.Diagnostics.Middleware`):
  - Buffered logs sit in "temporary circular buffers in process memory". "If the buffer is full, the oldest logs are dropped and never emitted."
  - API: `AddGlobalBuffer`, `AddPerIncomingRequestBuffer`, `GlobalLogBuffer.Flush()`. Options: `MaxBufferSizeInBytes`, `MaxLogRecordSizeInBytes`, `AutoFlushDuration`, `Rules`.
  - Limitations: order not guaranteed (timestamps preserved). Scopes are unsupported. `ActivityTraceId`/`ActivitySpanId` are empty on flushed records.
  — [Microsoft Learn: Log buffering](https://learn.microsoft.com/en-us/dotnet/core/extensions/logging/log-buffering)

**AWS Lambda Powertools (Python)**
- `LoggerBufferConfig(max_bytes=20480 default, buffer_at_verbosity, flush_on_error_log=True)`.
- "When the buffer reaches its maximum size… older logs are removed". "a warning is emitted when flushing the buffer to indicate that some logs have been dropped".
- The buffer is per invocation, and cold-start logs are never buffered.
- [Powertools Logger](https://docs.aws.amazon.com/powertools/python/latest/core/logger/)

**Sentry**
- Breadcrumbs: "a trail of events that happened prior to an issue" — [Sentry breadcrumbs](https://docs.sentry.io/product/issues/issue-details/breadcrumbs/). `maxBreadcrumbs` defaults to 100 — [Sentry JS options](https://docs.sentry.io/platforms/javascript/configuration/options/).
- Session Replay "buffer mode": it "stores the last 60 seconds of event logs in a memory ring buffer (approximately 2-5MB)". When an error is sampled, "the buffered 60 seconds _before_ the error plus everything _after_ is uploaded… and recording continues normally". — [Sentry: understanding sessions](https://docs.sentry.io/platforms/javascript/session-replay/understanding-sessions/)

**Datadog**
- Flex Logs is a storage/retention tier ("decoupling storage from compute costs"). It is not a pre-error capture feature. — [Datadog Flex Logs](https://docs.datadoghq.com/logs/log_configuration/flex_logs/)
- The Datadog Agent flare's remote "Debug mode" temporarily raises the log level: "The log level is reset to its previous configuration after you send the flare". This is forward-looking, not retroactive. — [Datadog flare](https://docs.datadoghq.com/agent/troubleshooting/send_a_flare/)

**Android / Perfetto**
- Buffers can use `RING_BUFFER` ("writes when full will wrap over and replace the oldest trace data") or `DISCARD`. `STOP_TRACING` triggers give flight-recorder mode: "the trace will be recorded in a loop and finalized when the culprit event is detected". — [Perfetto trace config](https://perfetto.dev/docs/concepts/config)
- `CLONE_SNAPSHOT` (trigger mode 4) "causes a snapshot of the current tracing session to be created after |stop_delay_ms| while the current tracing session continues undisturbed". Per-trigger `max_per_24_h` "Limits the number of traces this trigger can start/stop in a rolling 24 hour window". `skip_probability` reduces high-frequency triggers. — [perfetto trace_config.proto](https://github.com/google/perfetto/blob/main/protos/perfetto/config/trace_config.proto)

**Linux perf / eBPF**
- `perf record --overwrite`: "An overwritable ring buffer works like a flight recorder: when it gets full, the kernel will overwrite the oldest records". With `--switch-output`, perf "records and drops events until it receives a signal" (SIGUSR2) to snapshot. `--switch-max-files=N` keeps N files. — [perf-record(1)](https://man7.org/linux/man-pages/man1/perf-record.1.html)
- The BPF ring buffer (`BPF_MAP_TYPE_RINGBUF`) is an MPSC buffer with `bpf_ringbuf_reserve()`/`commit()`/`discard()`. Reservation fails when there is no space. — [kernel BPF ringbuf docs](https://docs.kernel.org/bpf/ringbuf.html)
- An overwrite mode (`BPF_F_RB_OVERWRITE`) was added in commit "bpf: Add overwrite mode for BPF ring buffer" (2025-10-27), merged with bpf-next for 6.19. — [torvalds/linux@feeaf1346f80](https://github.com/torvalds/linux/commit/feeaf1346f80)

**Log shippers and journald (eviction behaviour)**
- Fluent Bit filesystem buffering: "If an output plugin reaches its configured `storage.total_limit_size` capacity, the oldest chunk from its queue will be discarded to make room for new data", i.e. drop-oldest per output. — [Fluent Bit buffering](https://docs.fluentbit.io/manual/data-pipeline/buffering)
- Vector buffers: `memory` or `disk`, with `when_full` = `block` (default), `drop_newest`, or `overflow` ("not yet suitable for production"). Vector has no drop-oldest option. — [Vector buffering model](https://vector.dev/docs/architecture/buffering-model/)
- systemd-journald:
  - `RateLimitIntervalSec=`/`RateLimitBurst=` default to "10000 messages in 30s" per service. The burst limit is multiplied by a factor derived from free disk space.
  - `SystemMaxUse=`/`SystemKeepFree=` default to 10% / 15% of the filesystem, "capped to 4G". "only archived files are deleted".
  - `MaxRetentionSec=` gives time-based deletion (default off).
  — [journald.conf(5)](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html)

### Inferences
- Snapshot semantics in prior art fall into two families:
  - (a) Stop-and-finalize: Perfetto `STOP_TRACING`, perf `--switch-output`, Go `WriteTo` once.
  - (b) Clone-and-continue: Perfetto `CLONE_SNAPSHOT`, `JFR.dump`, Sentry Replay, Hindsight "triggered traces can no longer be evicted".
  - The requirement (keep recording, retain the pre-incident window 24 h) matches family (b). Perfetto's `max_per_24_h` and Hindsight's per-trigger rate limit are direct prior art for capping snapshot storms.
- dotnet-monitor `CollectLogs`, Datadog flare "Debug mode" and Mattermost's "set DEBUG before generating" (Q4) are all *forward-looking*. They miss the pre-incident window, which is exactly the gap `flightrecorder` targets. In-process buffers (.NET, Powertools, Sentry) solve it per process and in memory only, so they lose data on crash and offer no node-level 15-min window.
- Runtime recorders could feed `flightrecorder` as extra snapshot sources: Go FlightRecorder, JFR with `disk=true,maxage=15m`, and dotnet-monitor `CollectDump`/`CollectTrace` actions fired by the same trigger. That is reuse rather than build.

### Gaps
- Not found: an official Hindsight–OpenTelemetry Collector integration beyond the paper's "Hindsight's OpenTelemetry tracer"; the repo shows no activity since 2022.
- Not verified: whether JFR writes an emergency dump on JVM crash. The JDK 21 `java`/`jcmd` pages reviewed do not mention it.
- Chrome-specific "background tracing" and Honeycomb/Splunk "logs before the error" features were not researched or verified. Only Sentry and Datadog were checked.

## Q3. What design concerns does the prior art document (sizing, eviction metrics, triggers and snapshots, crash safety, disk IO, PII redaction, encryption)?

### Takeaway
Prior art converges on four rules:
1. Bound the buffer by bytes first, with time as a hint (Go, Hindsight, JFR, .NET).
2. Evict at a coarse granularity (whole trace, chunk or file) and *report* what was evicted (Fluent Bit metrics, Powertools warning).
3. Rate-limit triggers per trigger ID or per 24 h (Hindsight, Perfetto, dotnet-monitor).
4. Accept that durability costs IO: fsync per write is optional and often off by default, so crash windows of 0.5 s (Vector) to 5 min (journald) are normal.

Redaction must happen before persistence, because neither `file_storage` nor `fileexporter` offers encryption at rest. Kubernetes node-pressure eviction (`nodefs.available<10%`) and kubelet log rotation (10 MiB × 5) are hard constraints on a 2 GiB per-node buffer.

### Cited Findings

**Sizing**
- Go: "MinAge should be approximately double the anticipated problem window". Busy services produce about 10 MB/s of execution trace. — [go.dev blog](https://go.dev/blog/flight-recorder)
- Hindsight lists three factors that set the event horizon: "(i) the buffer pool size… (ii) the rate of new trace data… (iii) the time between a request completing and a trigger firing". "The global event horizon… is dictated by the shortest event horizon among the constituent processes". It offers a trace-percentage knob: "50% trace percentage will halve the trace data throughput and double the event horizon". — [Hindsight PDF](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf)
- journald: `SystemMaxFileSize=` defaults to "one eighth of the values configured with SystemMaxUse=… capped to 128M, so that usually seven rotated journal files are kept as history". This means rotation granularity sets eviction granularity. — [journald.conf(5)](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html)
- Vector disk buffers have a "minimum size for all buffers… currently ~256MiB". — [Vector buffering model](https://vector.dev/docs/architecture/buffering-model/)

**Eviction metrics and visibility**
- Fluent Bit exposes `fluentbit_output_dropped_records_total`, `fluentbit_input_storage_chunks`, `..._chunks_up`, `..._chunks_down`, `..._chunks_busy_bytes` and others. — [Fluent Bit monitoring](https://docs.fluentbit.io/manual/administration/monitoring)
- Powertools emits a warning on flush when buffered logs were evicted — [Powertools Logger](https://docs.aws.amazon.com/powertools/python/latest/core/logger/).
- journald logs "A message about the number of dropped messages" when rate limiting applies — [journald.conf(5)](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html).

**Triggers and snapshots**
- Hindsight isolates triggers "based on a trigger ID… ensuring that a symptom detector that fires infrequently is not affected by one that fires too often". Its autotriggers include `PercentileTrigger` and `TriggerSet` (a sliding window of the N most recent trace IDs). — [Hindsight PDF](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf)
- Perfetto: `stop_delay_ms` (the delay between trigger and snapshot, so post-trigger context is included), `max_per_24_h`, `skip_probability` — [trace_config.proto](https://github.com/google/perfetto/blob/main/protos/perfetto/config/trace_config.proto).
- dotnet-monitor `ActionCount` defaults to 5 per rule, optionally over a sliding window — [collection-rule-configuration.md](https://github.com/dotnet/dotnet-monitor/blob/main/documentation/configuration/collection-rule-configuration.md).
- Go allows only one concurrent `WriteTo`; "If the caller of WriteTo sees this error, they should use the result from the other call" — [flightrecorder.go](https://go.dev/src/runtime/trace/flightrecorder.go).

**Crash safety and disk IO**
- `file_storage` `fsync` is off unless set ("at the cost of performance"). `recreate` handles bbolt corruption by renaming the file to `.backup`. — [filestorage README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/storage/filestorage)
- Data loss after restart with `fsync: false` is an open bug — [contrib#50102](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/50102).
- Fluent Bit `storage.sync` is `normal` (default) or `full`. "On Linux, `full` corresponds with the `MAP_SYNC` option for memory mapped files". `storage.checksum` uses CRC32. — [Fluent Bit service section](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/yaml/service-section)
- Vector disk buffers "synchronize on an interval (500 milliseconds)" and Vector "will forcefully stop itself" on disk write errors — [Vector buffering model](https://vector.dev/docs/architecture/buffering-model/).
- journald `SyncIntervalSec=` defaults to 5 minutes, but "syncing is unconditionally done immediately after a log message of priority CRIT, ALERT or EMERG". This is a precedent for "fsync on FATAL". — [journald.conf(5)](https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html)
- The Pebble tail storage size check runs "once per second", so the DB "can exceed the limit by the amount written in one second". Compaction reclaims space asynchronously. — [pebbletailstorageextension README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/tailstorage/pebbletailstorageextension)

**Kubernetes node constraints**
- Default kubelet hard eviction thresholds include `memory.available<100Mi` (Linux), `nodefs.available<10%`, `imagefs.available<15%` and `nodefs.inodesFree<5%`. Node-pressure accounting covers "emptyDir volumes not backed by memory, log storage, ephemeral storage". — [Node-pressure eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)
- Kubelet rotates container logs with `containerLogMaxSize` (default 10Mi) and `containerLogMaxFiles` (default 5). "Only the contents of the latest log file are available through `kubectl logs`". — [Kubernetes logging architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

**PII redaction and encryption**
- OTel guidance: implementers are "responsible for… Protecting sensitive information"; follow data minimization; use the `attributes`, `filter`, `redaction` and `transform` processors. — [OTel: Handling sensitive data](https://opentelemetry.io/docs/security/handling-sensitive-data/)
- The `redaction` processor is **alpha** for logs/metrics and **beta** for traces. Keys: `allow_all_keys`, `allowed_keys` ("designed to fail closed"), `ignored_keys`, `blocked_key_patterns`, `blocked_values`, `allowed_values`, `redact_all_types`. — [redactionprocessor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/redactionprocessor)
- The OpAMP Supervisor keeps crash log snippets off by default "because Collector logs may contain sensitive data" — [opampsupervisor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/cmd/opampsupervisor).
- Encryption at rest: the `file_storage`, `fileexporter` and `pebble_tail_storage` READMEs list no encryption options. A GitHub search of collector/contrib issues for "encryption at rest", "encrypt persistent queue" and "encrypted storage extension" found no proposal for encrypting local buffers. Hits were unrelated, e.g. CloudWatch KMS. — [filestorage README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/storage/filestorage); [fileexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/fileexporter)
- sos does offer archive encryption: `--encrypt-key KEY` (GPG recipient) or `--encrypt-pass PASS` (symmetric) — [sos-report(1)](https://github.com/sosreport/sos/blob/main/man/en/sos-report.1).

### Inferences
- **Sizing check (rough):** at 2 GiB / 15 min the sustainable ingest is about 2.3 MB/s per node of *stored* bytes. That budget is below one "busy" Go service's execution-trace rate (10 MB/s per the Go blog), so traces or runtime traces should be optional or sampled.
- Per Hindsight, the effective window is set by the busiest node or process. A per-service byte quota inside the 2 GiB would stop one noisy pod from shrinking everyone's window. That is the "weighted fair sharing" idea in Hindsight.
- A 2 GiB buffer on a hostPath or emptyDir counts toward `nodefs` pressure. On small edge or air-gapped nodes it could push the node toward the 10% eviction threshold. A dedicated volume or a free-space guard (like journald `SystemKeepFree=`) is advisable.
- Recommended semantics drawn from prior art:
  - Drop-oldest by segment file (Fluent Bit and journald style).
  - Freeze on trigger by moving or hard-linking segments into a retained snapshot directory (clone-and-continue).
  - Wait N seconds after the trigger before freezing (Perfetto `stop_delay_ms`).
  - Cap snapshots per 24 h (Perfetto) and per trigger ID (Hindsight).
  - Fsync immediately on FATAL (journald precedent); otherwise use interval sync.
- Because no OTel storage component encrypts at rest, encryption must come from node disk encryption, a custom exporter (e.g. per-snapshot age/GPG/AES envelope), or redact-before-write. Redact-before-write via the `redaction`/`transform` processors in the pipeline ahead of the buffer is reusable today.

### Gaps
- No published measurements of disk IO impact (IOPS, write amplification) were found for `fileexporter` rotation or `file_storage` at about 2 MB/s sustained. A benchmark would be needed.
- No prior art found on time-based (rather than size-based) eviction for OTel logs.

## Q4. What support-bundle tools exist for Kubernetes and on-prem / air-gapped products, what do they collect, how do they redact, and how do bundles leave air-gapped sites?

### Takeaway
Replicated **troubleshoot** is the most directly reusable tool:
- Apache-2.0, actively released (v0.134.1, 2026-09-14), client-side, and usable standalone without the Replicated platform.
- Declarative `SupportBundle` and `Redactor` specs can ship in-cluster as Secrets/ConfigMaps (`--load-cluster-specs`).
- It has built-in plus custom regex/yamlPath redactors and host collectors.
- `copyFromHost` copies node directories via a DaemonSet, which is how per-node `flightrecorder` snapshots could be gathered.

`sos clean` and OpenShift `must-gather-clean` show the stronger redaction model: *consistent* obfuscation with a private mapping file, plus reports. sos adds GPG encryption.

For air-gapped sites, every tool reviewed assumes a manual flow: generate a local archive (tar/zip), carry it out, then upload via a vendor portal or support case. No tool documents a dedicated offline transport, signing or chain-of-custody protocol. The OTel Collector proposal's per-file SHA-256 manifest is the closest.

### Cited Findings

**Replicated troubleshoot**
- License Apache-2.0 (GitHub license API). "a framework for collecting, redacting, and analyzing highly customizable diagnostic information about a Kubernetes cluster".
- It ships the kubectl plugins `kubectl preflight` and `kubectl support-bundle` via Krew, and `sbctl` to browse bundles with kubectl.
- Releases include a signed SBOM and SLSA provenance (cosign).
- [replicatedhq/troubleshoot](https://github.com/replicatedhq/troubleshoot)
- "This does not deploy anything to the cluster, it's all client-side code". Bundles always include the `clusterInfo` and `clusterResources` collectors.
- Custom redactors come via `--redactors`: a file, URL, `oci://`, `configmap/<ns>/<name>` or `secret/<ns>/<name>`.
- [Collecting a support bundle](https://troubleshoot.sh/docs/support-bundle/collecting/)
- `--load-cluster-specs` discovers specs in Secrets/ConfigMaps labelled `troubleshoot.sh/kind: support-bundle` with data key `support-bundle-spec` or `redactor-spec`. Introduced in v0.47.0. — [Discover cluster specs](https://troubleshoot.sh/docs/support-bundle/discover-cluster-specs/)
- Built-in redactors:
  - Regex for AWS keys, env vars beginning with password/token/database/user, connection strings and DB-string fields.
  - Multi-line JSON variants.
  - yamlPath for kURL tokens.
  - IP address masking only for KOTS.
  - Caveat: "The built-in redactors cover common patterns but are not exhaustive".
  — [Built-in redactors](https://troubleshoot.sh/docs/redact/built-in/)
- Custom `Redactor` spec: `fileSelector` (`file`/`files` globs) plus `removals` (`values`, `regex` with `selector`/`redactor` and `mask` capture groups, `yamlPath`). Values become `***HIDDEN***`. "Do not include sensitive data in redactor specifications. Redactor specs are passed… in plain text". — [Redactors](https://troubleshoot.sh/docs/redact/redactors/)
- Host collectors (since v0.40.0) "do not have Kubernetes as a dependency". Examples include `cpu`, `memory`, `journald`, `run`, `copy`, `diskUsage`, `filesystemPerformance`. Run with `./support-bundle --interactive=false support-bundle.yaml`. Output can be per node with `runHostCollectorsInPod`. — [Host collectors overview](https://troubleshoot.sh/docs/host-collect-analyze/overview/)
- `copyFromHost` "will collect files from all hosts in the cluster" using a DaemonSet. Params: `image` (must have `sleep` and `tar`), `hostPath`, `extractArchive`, `timeout`, `imagePullSecret`. — [copyFromHost](https://troubleshoot.sh/docs/collect/copy-from-host/)
- The `logs` collector defaults to `maxLines: 10000` and `maxBytes` 5000000 (5 MB), with `maxAge` as an option — [Pod logs collector](https://troubleshoot.sh/docs/collect/logs/).
- Air gap: the plugin is installed manually from the release tarball (`support-bundle_linux_amd64.tar.gz`). After generating, users can "upload it to the Vendor Portal for analysis" or inspect locally with sbctl. — [Replicated: generating support bundles](https://docs.replicated.com/vendor/support-bundle-generating)
- Replicated air gap telemetry: the Replicated SDK keeps telemetry in a Kubernetes Secret, "capped at 4,000 events or 1MB per Secret". "the oldest events are purged". It is "collected when a support bundle is generated" and linked to the customer when uploaded. — [Replicated: air gap telemetry](https://docs.replicated.com/vendor/telemetry-air-gap)

**sos / sosreport**
- License GPL-2.0 (GitHub license API); latest 4.12.0. — [sosreport/sos](https://github.com/sosreport/sos)
- `sos clean` / `sos mask`:
  - Obfuscates hostnames, IPs, IPv6, MACs, keywords and usernames "consistently" (the same input maps to the same output across the report).
  - Mappings persist in `/etc/sos/cleaner/default_mapping`. "This mapping file should be kept private".
  - `--treat-certificates` (obfuscate/keep/remove); "Files identified as private keys are always removed".
  - Can run inline with `sos report --clean`.
  — [sos-clean(1)](https://github.com/sosreport/sos/blob/main/man/en/sos-clean.1)
- `sos report`: `--log-size` (default 25 MiB, captures "the last X amount"), `--since`, `--encrypt-key`/`--encrypt-pass` (GPG), `--upload` / `--upload-url` (HTTPS, SFTP, FTP). — [sos-report(1)](https://github.com/sosreport/sos/blob/main/man/en/sos-report.1)

**Rancher / Harvester support-bundle-kit**
- Apache-2.0, README says "**working in progress**".
- A `manager` collects cluster YAMLs, pod logs and external bundles such as Longhorn, and "starts a daemonset on each node. The agents… collect node bundles and push them back to the manager".
- A `simulator` loads a bundle into an embedded etcd plus minimal apiserver/kubelet for browsing.
- [rancher/support-bundle-kit](https://github.com/rancher/support-bundle-kit)

**crashd (VMware Tanzu)**
- Apache 2.0 (LICENSE.txt). Starlark scripts; can "Interact and capture information from compute resources such as machines (via SSH)" and from the API server, including Cluster-API clusters.
- Last release v0.4.3, 2025-05-22.
- [vmware-tanzu/crash-diagnostics](https://github.com/vmware-tanzu/crash-diagnostics)

**kubectl cluster-info dump**
- Dumps cluster info and "the logs of all of the pods". By default only the current and `kube-system` namespaces.
- Flags: `--all-namespaces`, `--namespaces`, `--output-directory`, `-o` (default json), `--pod-running-timeout` (20s).
- The reference page does not mention redaction.
- [kubectl cluster-info dump](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cluster-info/kubectl_cluster-info_dump/)

**OpenShift must-gather**
- `oc adm must-gather` collects "Resource definitions" and "Service logs" into `./must-gather.local`. Feature-specific images are passed via `--image`.
- Flags: `--since`/`--since-time` ("Plugins are encouraged but not required to support this"), `--timeout` (default 10 min), `--volume-percentage` (default 30%).
- "If you are in a disconnected environment, use the --image flag… and point to the payload image". You then compress the directory and provide it to Red Hat Support.
- [OCP 4.19: Gathering data about your cluster](https://docs.redhat.com/en/documentation/openshift_container_platform/4.19/html/support/gathering-cluster-data)
- Obfuscation is delegated to `must-gather-clean`: IPs, MACs, DNS; "Replace confidential information consistently to preserve debuggability"; "Comprehensive reporting and reproducible obfuscation"; config-driven omission. — [openshift/must-gather](https://github.com/openshift/must-gather); [openshift/must-gather-clean](https://github.com/openshift/must-gather-clean)

**GitLab gitlabsos / kubesos**
- gitlabsos has been in the GitLab Linux package since 18.3. It "only grabs the last 30MB of each latest log file version". It includes a sanitized `gitlab.rb` (`--skip-config` omits it). It works on Omnibus/Docker only, not on k8s chart deployments. — [gitlabsos](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos)
- KubeSOS is a `kubectl`/`helm` wrapper with default max 10000 lines per log, `-s`/`-t` time filters, and output `kubesos-<timestamp>.tar.gz` — [kubesos](https://gitlab.com/gitlab-com/support/toolbox/kubesos).

**Elastic support-diagnostics**
- Elastic License 2.0 (LICENSE.txt); v9.4.1.
- The `scrub` utility "will automatically obfuscate all node id's node names, IPv4, IPv6 and MAC addresses" consistently within a run. Token or regex rules go in `config/scrub.yml`. Output is a `scrubbed-` archive.
- `--bypassDiagVerify` is "Useful in air gapped environments".
- [elastic/support-diagnostics](https://github.com/elastic/support-diagnostics)

**Mattermost Support Packet**
- A zip with config, logs, plugin diagnostics, DB schema info and pprof profiles. "Confidential data, such as passwords, are automatically stripped". "Plugins may not be sanitized during packet generation" unless they mark config hidden.
- Prerequisite: set "**File Log Level** to **DEBUG**". From v11.4, generation is recorded in the audit log.
- [Mattermost Support Packet](https://docs.mattermost.com/administration-guide/manage/admin/generating-support-packet.html)

**Grafana Alloy support bundle**
- `/-/support?duration=N` covers components, env vars, logs during the window, metrics, pprof and config. "The support bundle contains all information in plain text, so you can inspect it before sharing".
- Disable it with `--server.http.disable-support-bundle`. Not available on v1.4 and older.
- [Grafana Alloy support bundle](https://grafana.com/docs/alloy/latest/troubleshoot/support_bundle/)

**Datadog Agent flare**
- "removes sensitive information, including passwords, API keys, Proxy credentials, and SNMP community strings". It can be sent remotely via Fleet Automation or created with `agent flare <CASE_ID> [--local]`. — [Datadog flare](https://docs.datadoghq.com/agent/troubleshooting/send_a_flare/)

**Sourcegraph**
- `src debug` "gathers and bundles debug data from a Sourcegraph deployment" with `kube`, `compose` and `server` subcommands. — [Sourcegraph src debug](https://sourcegraph.com/docs/cli/references/debug)

### Inferences

**Fit for the vendor's bundle**

| Tool | License / maturity | Fit | Notes |
|---|---|---|---|
| Replicated troubleshoot (`support-bundle` binary, specs in Secrets) | Apache-2.0, very active | **High (reuse)** | Standalone binary for air gap. `copyFromHost` or `runDaemonSet`/host collectors can grab `flightrecorder` snapshot directories on each node. Analyzers give local triage. The Vendor Portal is optional. Redaction is pattern-based and not consistent-mapping, so pair it with a custom redactor set. |
| sos (`sos report` / `sos clean`) | GPL-2.0, active | **Medium (host level, reference design)** | The best model for consistent obfuscation plus a private mapping file and GPG encryption. GPL-2.0 matters if embedding or modifying, less so if it is invoked as a separate tool on RHEL-family hosts. |
| must-gather + must-gather-clean | Apache-2.0, OpenShift-centric | **Medium (pattern)** | The "plugin image per component" pattern fits a 20–100-service product: each team ships a gather script. In disconnected sites the image must be mirrored. |
| Rancher support-bundle-kit | Apache-2.0, "working in progress" | **Low–Medium** | Its in-cluster manager plus node-agent DaemonSet and its simulator are useful ideas. Maturity is low. |
| crashd | Apache-2.0, low activity | **Low** | SSH-based; suits clusters where the API server is down. |
| `kubectl cluster-info dump` | upstream | **Low (fallback)** | No redaction documented; logs only as far back as kubelet retains them. |

- Pod logs collected through the API (troubleshoot `logs`, kubesos, cluster-info dump) only reach back as far as the kubelet keeps them. Only the latest file, 10 MiB by default, is available through `kubectl logs`, and pre-incident DEBUG is absent unless it was emitted. This is the concrete reason a node-local `flightrecorder` snapshot directory, collected via `copyFromHost`, adds value to a troubleshoot-based bundle.
- Air-gapped transport practice in every tool reviewed amounts to "write an archive locally, then a human moves it". For hand-carry, a vendor could combine:
  - sos-style GPG encryption to a vendor public key,
  - the OTel #16017 manifest idea (bundle ID, capture window, SHA-256 per file),
  - a redaction report like must-gather-clean's, so the customer's security team can review before release.

### Gaps
- `kubectl cluster-info dump` handling of Secret objects is not stated on the reference page; not verified.
- Sourcegraph `src debug` contents and redaction details were not retrievable from the fetched page.
- VMware Tanzu product-level support bundles (beyond crashd) were not researched in depth.
- No source found describing a standardized, signed or encrypted "sneakernet" bundle format used across vendors.

## Q5. What have companies that ship on-prem Kubernetes products published about lessons learned?

### Takeaway
Published lessons centre on the support burden and lack of visibility in customer-run Kubernetes: PostHog and Gitpod both retreated from self-hosted K8s. Vendors respond by:
- shipping declarative, in-cluster bundle specs (Replicated),
- piggy-backing telemetry on bundles for air-gapped sites and asking customers to send bundles regularly (Replicated),
- telling customers to collect *during or just after* the issue, because logs are size-limited (GitLab),
- asking for DEBUG to be enabled *before* reproducing (Mattermost).

All of these confirm the pre-incident-context gap that `flightrecorder` addresses. Engineering-blog material that is specifically about pre-incident DEBUG capture in on-prem K8s is scarce.

### Cited Findings
- PostHog (CTO Tim Glaser, 2023-02-08):
  - "our small infrastructure team is spending an outsized amount of time supporting the 3.5% of users who haven't moved to PostHog Cloud".
  - "issues crop up in every part of the stack".
  - "Even something as simple as a full disk would cause their instance of PostHog to be down for hours or days".
  - "we would have to vet their engineering team for Kubernetes experience".
  - "the tools to do that automation just don't exist. We kept finding new failure modes".
  — [PostHog: Sunsetting Kubernetes support](https://posthog.com/blog/sunsetting-helm-support-posthog)
- Gitpod ended self-hosted (Dec 2022): "self-hosted Gitpod has been increasingly difficult for us to support and it has shown to be a burden for our clients to manage and operate their own Gitpod instances". — [DevClass on Gitpod](https://devclass.com/2022/12/09/gitpod-abandons-self-hosted-product-in-favor-of-dedicated-cloud)
- Replicated (2024-06-07) called air-gapped instances "blind spots". Its recommendation is to "collect support bundles from air gap customers regularly (monthly or quarterly)" so the support bundle doubles as a telemetry carrier. — [Replicated blog: Air Gap Telemetry](https://www.replicated.com/blog/bridging-the-air-gap-announcing-replicateds-air-gap-telemetry-beta)
- GitLab's gitlabsos guidance: for degraded performance "the script works best if you run it _while_ you're experiencing the issue". For a software error, "just _after_ the issue". The archive is size-limited to the last 30 MB per log. — [gitlabsos](https://gitlab.com/gitlab-com/support/toolbox/gitlabsos)
- Mattermost requires admins to set file log level to DEBUG before generating a Support Packet — [Mattermost Support Packet](https://docs.mattermost.com/administration-guide/manage/admin/generating-support-packet.html).
- OTel Collector maintainers on an in-process support-bundle endpoint:
  - "I can see the DoS security reports coming… (e.g. must not be exposed to the open Internet)".
  - A contributor raised "snapshot coherence": artifacts should be bound to one "bundle generation" (`bundle_id | capture_start | capture_end | collector_instance_id | config_generation…`).
  — [collector#16017](https://github.com/open-telemetry/opentelemetry-collector/issues/16017)
- KubeCon EU 2026: VictoriaMetrics presented retroactive sampling with OTel Collectors (a node-local disk buffer plus central decision) — [VictoriaMetrics blog](https://victoriametrics.com/blog/kubecon-eu-2026-sampling/). A Replicated-hosted KubeCon NA 2021 session, "Advanced Kubernetes Troubleshooting Made Simple with Open Source Tools", appears in search results only — [sched listing](https://kccncna2021.sched.com/event/nCVe/advanced-kubernetes-troubleshooting-made-simple-with-open-source-tools-hosted-by-replicated-complimentary-registration-required) (not opened; content not verified).

### Inferences
- Vendor advice like "run it while it's happening", "set DEBUG first" and "send bundles monthly" is a manual workaround for missing pre-incident context and missing connectivity. An always-on node-local recorder whose snapshot is collected by the bundle tool removes the timing dependency.
- PostHog's "full disk" anecdote and Kubernetes `nodefs` eviction (Q3) suggest the recorder must enforce hard disk-usage limits and must never be the cause of an outage. That means fail-open, with drop-oldest and a free-space floor.
- Support bundles in air-gapped sites are released by the customer's security team. Consistent obfuscation with a customer-held mapping file (sos, must-gather-clean) plus a reviewable redaction report is the practice most likely to be accepted. This is an inference from the tools' design, not a published survey.

### Gaps
- No engineering blog or KubeCon talk was found that specifically describes an always-on, node-local DEBUG flight recorder for an on-prem K8s product. Searches surfaced only general air-gap and support-bundle material.
- No quantitative data found (for example how often bundles lacked needed context) from any vendor.
- Lessons from security vendors shipping on-prem K8s (the closest peer group) were not found in public sources during this search.
