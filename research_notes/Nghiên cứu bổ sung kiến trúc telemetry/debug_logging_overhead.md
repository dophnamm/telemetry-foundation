# Performance overhead of always-on DEBUG logging and log export paths (OTLP vs stdout+filelog), per language

Scope: an OTel-based platform on Kubernetes (20–100 services; Go, C/C++/Rust, Java/.NET, Node.js) that wants to ALWAYS emit DEBUG into a node-local Collector ring buffer ("flight recorder", 2 GiB/node, ~15 min). Target <5% CPU. Path A = SDK OTLP log exporter → node Collector; Path B = stdout JSON → CRI log files → Collector `filelog`. Research date: 2026-10-07. All numbers below come from the cited page as fetched. Where a benchmark comes from the library's own authors or from a vendor selling a competing product, it is flagged **[self/vendor-authored]**.

---

## Q1. Logging library throughput/latency/allocation benchmarks at DEBUG volume (Go, Java, .NET, Node.js, C++, Rust)

### Takeaway
At realistic per-node DEBUG rates (thousands to low tens of thousands of lines/s), the cost of *formatting* in a modern structured logger is small: roughly 30 ns to 2.5 µs per line in Go, about 100–300 ns per record in .NET with OTel, and 6–300 ns on the hot path in async C++. What makes it expensive is the wrong API (reflection-heavy loggers, string interpolation, caller location capture), synchronous I/O, and the blocking or dropping behaviour of async queues. Nearly all published numbers are microbenchmarks run by the library's own authors on different hardware and versions. They are useful for ranking libraries, not for predicting production % CPU.

### Cited Findings

**Go (zap, zerolog, slog, logrus)**
- zap README (versions pinned in `benchmarks/go.mod`; no Go version or hardware stated; "take these with a grain of salt") **[self-authored by zap]**. "Log a message and 10 fields": zap 656 ns/op, 5 allocs; zap sugared 935 ns, 10 allocs; zerolog 380 ns, 1 alloc; go-kit 2249 ns, 57 allocs; slog (LogAttrs) 2479 ns, 40 allocs; slog 2481 ns, 42 allocs; apex/log 9591 ns; log15 11393 ns; logrus 11654 ns, 79 allocs — [uber-go/zap README](https://github.com/uber-go/zap)
- zap README, logger that already carries 10 context fields: zap 67 ns, 0 allocs; zerolog 35 ns, 0 allocs; slog 193 ns, 0 allocs; logrus 10521 ns, 68 allocs. Static string: zap 63 ns, zerolog 32 ns, stdlib `log` 124 ns, slog 196 ns, logrus 1439 ns — [uber-go/zap README](https://github.com/uber-go/zap)
- zerolog README **[self-authored]**: disabled level 4.07 ns/op, 0 allocs; empty log 19.1 ns; Info 42.5 ns; 0 B/op on its core paths. In its own comparison, "message with 10 fields" gives zerolog 767 ns/552 B/6 allocs, zap 848 ns/704 B/2 allocs, zap sugared 1363 ns, logrus 5661 ns/78 allocs — [rs/zerolog README](https://github.com/rs/zerolog). **Conflict:** zap's README puts zerolog at 380 ns/1 alloc and zap at 656 ns/5 allocs for the "same" test. Hardware and versions differ and neither page states them.
- zerolog has built-in sampling and a `diode.Writer` described as "thread-safe, lock-free, non-blocking" for slow writers, plus `SetGlobalLevel` — [rs/zerolog README](https://github.com/rs/zerolog)
- slog design (Jonathan Amsterdam, Go blog, 22 Aug 2023): "The greatest gains came from paying careful attention to memory allocation". `Enabled` "is called at the beginning of every log event, giving the handler a chance to drop unwanted log events quickly". `WithAttrs`/`WithGroup` pre-format attributes once. "over 95% of calls to logging methods pass five or fewer attributes" — [go.dev/blog/slog](https://go.dev/blog/slog)

**Java (Log4j2, Logback)**
- Current Log4j docs (2.25.x) give **no numbers**, only trade-offs. Async loggers give "higher peak throughput" and "lower logging latency" but "lower sustainable throughput". When the queue fills, "the application will end up logging at the speed of the slowest appender". If benchmarks show no significant difference, synchronous logging "is recommended". On a "VM with a single vCPU, starting another thread is not likely to give better performance" — [Log4j async loggers manual](https://logging.apache.org/log4j/2.x/manual/async.html); [Log4j performance page](https://logging.apache.org/log4j/2.x/manual/performance.html)
- Log4j async defaults: the queue-full policy **blocks** the caller by default. The alternative "Discard" policy drops events at or below a threshold level (default `INFO`). Ring buffer is 256×1024 slots (4×1024 in garbage-free mode), pre-allocated and never resized — [Log4j async manual](https://logging.apache.org/log4j/2.x/manual/async.html)
- Historical Log4j table (2.12.x docs; measurements on JDK 1.7, Solaris 10, 2×4-core Xeon X5570, i.e. very old) **[self-authored]**. Throughput in msgs/s, 1 thread / 64 threads: Log4j2 all-async 2,652,412 / 288,997; Log4j2 AsyncAppender 1,713,429 / 23,980; Logback AsyncAppender 2,206,907 / 21,303; Log4j2 sync 273,536 / 4,253; Logback sync 178,063 / 1,967 — [Log4j 2.12.x async page](https://logging.apache.org/log4j/2.12.x/manual/async.html)
- Log4j 2.6-era performance page (Xeon E5-2660 v3, JDK 1.8.0_45): capturing caller location "slows down asynchronous logging by about 30-100x". Under 128,000 msgs/s across 16 threads, Logback 1.1.7 and Log4j 1.2.17 showed latency spikes "orders of magnitude larger than Log4j 2", and "garbage-free async loggers have the best response time behaviour" — [Log4j 2.12.x performance](https://logging.apache.org/log4j/2.12.x/performance.html); [Log4j 2.12.x async](https://logging.apache.org/log4j/2.12.x/manual/async.html)
- Logback performance page **[self-authored by Logback's author; contradicts Log4j's claims]**. Versions: log4j 1.2.17, log4j 2.14.1, logback 1.3.0-alpha10, JDK 16, Windows 10, i7-6770HQ, NVMe. Results in ops/ms, 1 thread: Logback sync 2,139.83 / async 1,760.30; Log4j2 sync 884.33 / async 844.67. At 64 threads: Logback sync 1,740.27; Log4j2 sync 1,236.37 / async 726.15. "logback's FileAppender is generating output at 474 MB/sec" (2.2M events/s × 209 B) — [logback.qos.ch/performance.html](https://logback.qos.ch/performance.html)

**.NET (ILogger + source-generated LoggerMessage, OpenTelemetry.Extensions.Logging, NLog, Serilog)**
- Microsoft docs (ms.date 2026-02-02): source-generated `[LoggerMessage]` "eliminat[es] boxing, temporary allocations, and message template parsing at runtime". `IsEnabled` guards avoid calling `ILogger.Log`, "value-type boxing and an allocation of `object[]`" — [High-performance logging in .NET](https://learn.microsoft.com/en-us/dotnet/core/extensions/high-performance-logging)
- OpenTelemetry .NET `LogBenchmarks.cs` (BenchmarkDotNet 0.13.10, .NET 8.0.7, i7-1185G7) **[self-authored by OTel .NET]**. Results (mean, allocated): NoListener (source-generated, no provider) 1.930 ns, 0 B. UnnecessaryIsEnabledCheck 1.531 ns. NoListenerExtensionMethod (`LogInformation(...)`) 40.218 ns, 64 B. NoListenerStringInterpolation 135.503 ns, 72 B. OneProcessor 111.558 ns, 40 B. **BatchProcessor 263.650 ns, 128 B**. CreateLoggerRepeatedly 53.797 ns — [opentelemetry-dotnet LogBenchmarks.cs](https://raw.githubusercontent.com/open-telemetry/opentelemetry-dotnet/main/test/Benchmarks/Logs/LogBenchmarks.cs)
- NLog wiki (edited June 2026; no version or baseline stated): NLog "can easily handle 500.000 messages/sec" depending on config. AsyncWrapper defers formatting to a background thread. For non-network targets it advises `overflowAction="Block"`. `${callsite}`/`${stacktrace}` are "very expensive". `Logger.ConditionalDebug()` is compiled out in non-DEBUG builds — [NLog performance wiki](https://github.com/NLog/NLog/wiki/performance)

**Node.js (pino, winston)**
- pino benchmarks **[self-authored by pino]**, wall time for the same workload (Node version, hardware and iteration count not stated in the doc). `info('hello world')`: pino 114.801 ms, pino minLength (async buffered) 70.968 ms, winston 270.249 ms, bunyan 377.434 ms. Object: pino 119.315 ms vs winston 273.120 ms. Deep object: pino 2.256 ms vs winston 5.604 ms (bunyan 1.839 ms is faster here) — [pino docs/benchmarks.md](https://github.com/pinojs/pino/blob/main/docs/benchmarks.md)
- pino transports (v7+) run "in a separate worker thread". It is "recommended that any log transformation or transmission is performed either in a separate thread or a separate process". In-process transports "slow down Node's single-threaded event loop". Transports boot asynchronously, so `process.exit()` before boot loses logs. `pino-opentelemetry-transport` exists for OTLP — [pino docs/transports.md](https://github.com/pinojs/pino/blob/main/docs/transports.md)
- pino async mode (`sync:false`, `minLength: 4096`) "enables the minimum overhead of Pino", but "the most recently buffered log messages [may be] lost in case of a system failure" — [pino docs/asynchronous.md](https://github.com/pinojs/pino/blob/main/docs/asynchronous.md)

**C/C++ (spdlog, quill, glog)**
- Quill README **[self-authored by Quill]**: Quill v13.0.0, RHEL 9.4, i5-12600 @4.8 GHz, GCC 14.2. Hot-path latency in ns, 1 thread, p50/p99/p99.9: Quill unbounded 6/8/10; Quill bounded-dropping 6/8/9; fmtlog 6/7/10; spdlog (async) 271/337/360; g3log 1066/1120/1143; Boost.Log 3093/3464/3621. At 4 threads: Quill 8/11/17 vs spdlog 557/741/1106. Throughput for 4M msgs: Quill 6.44 M msgs/s, spdlog 2.57 M, Boost.Log 0.33 M. Caveats: each sample averages 20 calls with about 2 ms between samples; binary-format loggers are not comparable — [odygrd/quill README](https://github.com/odygrd/quill)
- spdlog README **[self-authored]** (Ubuntu, i7-4770 @3.4 GHz, old hardware). Sync single-thread `basic_st` 5,777,626 msgs/s; 10 threads `basic_mt` 1,659,613 msgs/s. **Async with 10 threads and an 8,192-slot queue: block policy ≈585,535 msgs/s vs overrun_oldest ≈2,660,000 msgs/s.** `SPDLOG_ACTIVE_LEVEL` compiles calls out — [gabime/spdlog README](https://github.com/gabime/spdlog)

**Rust (tracing, tracing-subscriber, log)**
- `tracing` compile-time filters: `max_level_*` / `release_max_level_*` features. Instrumentation at disabled levels "will not even be present in the resulting binary". Caveat: with the `log` feature on, some code may still be generated (tracing 0.1.44 docs) — [docs.rs tracing level_filters](https://docs.rs/tracing/latest/tracing/level_filters/index.html)
- instrument-bench (community; README says results were "not obtain[ed] in a controlled environment", ±50–100% variance, versions and hardware not given). Disabled `log::debug!` at Level::Info costs 1.6 ns (env_logger and tracing-subscriber). `tracing::debug!` costs 2.6–3.8 ns. With an active span, a tracing-subscriber fmt event costs about 600 ns — [Imberflur/instrument-bench](https://github.com/Imberflur/instrument-bench)
- OTel Rust stress test **[self-authored by OTel Rust]**, `tracing` appender into the OTel Logs SDK with a **no-op processor** (no export or serialization), macOS on an Apple M4 Pro (14 cores): "~27 M /sec" enabled and "~1.4 B /sec (when disabled)" — [opentelemetry-rust stress/src/logs.rs](https://raw.githubusercontent.com/open-telemetry/opentelemetry-rust/main/stress/src/logs.rs)

### Inferences
- Rough cost model: app logging CPU (cores) ≈ lines/s × CPU-seconds per line. For example, 5,000 DEBUG lines/s/pod at ~0.65 µs (zap, 10 fields) ≈ 0.003 cores. At ~2.5 µs (slog JSONHandler) ≈ 0.0125 cores. At ~11.6 µs (logrus) ≈ 0.058 cores. So **library choice only matters by an order of magnitude when emission rates are high or the library is reflection-heavy** (logrus, apex, log15, winston, Boost.Log, g3log). Real per-line cost is higher than microbenchmarks because of I/O, cache misses, GC and lock contention.
- The real risks in always-on DEBUG are (a) the async queue-full policy (Log4j default = block, spdlog block mode is ~4.5× slower than overrun), (b) caller or location capture (30–100× in Log4j, "very expensive" in NLog), and (c) argument evaluation in disabled or "cheap" call sites (.NET string interpolation still costs 135 ns with no listener).
- For a flight recorder, a **dropping** policy for DEBUG is the right semantic: Log4j Discard ≤ DEBUG/INFO, spdlog `overrun_oldest`, Quill bounded-dropping, zerolog diode. App latency matters more than completeness of debug context.
- Go: prefer zap, zerolog, or slog with a fast handler (slog's built-in handler is ~3–4× slower than zap in zap's own benchmark). Java: Log4j2 async loggers or Logback, with no location info; the vendors contradict each other, so measure in Phase 0. .NET: mandate `[LoggerMessage]` source generation. Node: pino, with work off the main thread. C++: an async logger (Quill/spdlog) with a dropping queue. Rust: `tracing` with `release_max_level_debug` (keep DEBUG, compile out TRACE).

### Gaps
- No independent (non-author) cross-library benchmark from 2023–2026 was found for Go, Java, .NET or Node. All numbers above come from library authors on undisclosed or old hardware.
- No Serilog numbers from a primary source were found (search hits were blog/SEO content). No glog numbers were found (Quill's table includes g3log, not glog).
- No published benchmark for Logback or Log4j2 *JSON* layouts (the relevant format for Path B) was found in this pass.
- The Log4j table in the 2.12.x docs dates from JDK 7 / Solaris and is not representative of JDK 21+ on modern x86/ARM.

---

## Q2. OTel SDK log-export overhead (OTLP exporter, batch processor, bridges/appenders) vs stdout; OTLP vs stdout+filelog CPU, memory, p99, failure modes

### Takeaway
No published head-to-head study of OTLP log export vs stdout+filelog (CPU, memory, p99) was found. What exists: (1) SDK microbenchmarks showing a batch processor adds about 100–260 ns per record (.NET), (2) spec and SDK defaults showing the batch processor **drops** when its 2048-record queue is full and never blocks the app, (3) container-runtime docs showing stdout is **blocking by default** in Docker and can stall the app when the log pipe backs up, and (4) a Coroot study where enabling OTel *tracing* in Go cost +35% CPU and +50% p99 at 10k RPS. So the failure-mode trade-off is clear: Path A loses data under pressure, while Path B can block the app or lose data at rotation. The CPU trade-off has to be measured in Phase 0.

### Cited Findings
- OTel Logs SDK spec, Batching LogRecordProcessor defaults: `maxQueueSize` 2048, `scheduledDelayMillis` 1000, `exportTimeoutMillis` 30000, `maxExportBatchSize` 512. "After the size is reached logs are dropped". Export "MUST NOT block indefinitely". `Logger.Enabled` returns false when no processors, logger disabled, severity below `minimum_severity`, or `trace_based` filtering is on for unsampled traces. LoggerConfig features are marked Development — [OTel Logs SDK spec](https://opentelemetry.io/docs/specs/otel/logs/sdk/)
- OTel Go `sdk/log` (v1.47.0, published 2 Oct 2026): BatchProcessor defaults are the same (2048 / 1 s / 512 / 30 s, settable via `OTEL_BLRP_*`). `OnEmit` "batches records without blocking". When the queue is full, "log records are dropped". SimpleProcessor is "not recommended for production use" — [pkg.go.dev go.opentelemetry.io/otel/sdk/log](https://pkg.go.dev/go.opentelemetry.io/otel/sdk/log)
- OTel .NET via ILogger: OTel provider with one simple processor costs 111.6 ns/40 B per log; with the **BatchProcessor 263.7 ns/128 B**; with no listener 1.9 ns (.NET 8, i7-1185G7) **[self-authored]** — [opentelemetry-dotnet LogBenchmarks.cs](https://raw.githubusercontent.com/open-telemetry/opentelemetry-dotnet/main/test/Benchmarks/Logs/LogBenchmarks.cs)
- OTel Rust: `tracing` → OTel Logs SDK with no-op processor ≈27 M/s on 14 cores (excludes export) **[self-authored]** — [opentelemetry-rust stress logs.rs](https://raw.githubusercontent.com/open-telemetry/opentelemetry-rust/main/stress/src/logs.rs)
- Coroot (Nikolay Sivko, 13 Jun 2025) **[vendor: Coroot sells eBPF-based observability]**. Go app, wrk2 at a fixed 10,000 RPS for 20 min, four 4-vCPU nodes, OTel tracing with OTLP HTTP export (logs NOT tested). CPU 2 → 2.7 cores (+35%); memory ~10 MB → 15–18 MB; p99 10 ms → 15 ms; 4 MB/s new network traffic. ~10% of total CPU went to the BatchSpanProcessor/export path — [Coroot: OpenTelemetry for Go: measuring the overhead](https://coroot.com/blog/opentelemetry-for-go-measuring-the-overhead/)
- Docker logging: default is "direct, blocking delivery from container to driver". `non-blocking` uses a per-container buffer (`max-buffer-size` default 1 MB). "When the buffer is full, new messages will not be enqueued." "Applications are likely to fail in unexpected ways when STDERR or STDOUT streams block" — [Docker: configure logging drivers](https://docs.docker.com/engine/logging/configure/)
- AWS shim-loggers-for-containerd: in non-blocking mode "log events are buffered and the application continues to execute even if these logs can't be drained"; buffer is 1 MiB by default; "Logs could also be lost when the buffer is full" — [aws/shim-loggers-for-containerd](https://github.com/aws/shim-loggers-for-containerd)
- containerd 1.4's first patch release fixed v1 shims "hanging on exit and exec when the log pipe fills up" (from search results; summary only, primary release note not fetched) — [search hit: containerd runtime/v2 pkg docs](https://pkg.go.dev/github.com/containerd/containerd@v1.6.35/runtime/v2)
- pino transports run in worker threads, which keeps OTLP serialization off the event loop. `pino-opentelemetry-transport` exists — [pino transports.md](https://github.com/pinojs/pino/blob/main/docs/transports.md)
- The OTel blog on Java logs from files (2024) recommends writing OTLP-JSON logs to stdout/files and collecting with filelog for "No code or dependency changes", and includes a Kubernetes config. It gives **no performance or failure-mode comparison** with SDK OTLP export — [OTel blog: Collecting OTel-compliant Java logs from files](https://opentelemetry.io/blog/2024/collecting-otel-compliant-java-logs-from-files/)
- Collector side at 10k logs/s (see Q3): the OTLP gRPC receiver pipeline costs ~23% of a core and OTLP-HTTP ~17%, vs `filelog` ~18% and filelog with the k8s CRI-containerd parser ~33% — [OTel contrib load-test data](https://open-telemetry.github.io/opentelemetry-collector-contrib/benchmarks/loadtests/data.js)

### Inferences
- **Path A (SDK OTLP)** app-side cost = bridge/appender + LogRecord allocation + batch enqueue (~0.1–0.3 µs/record in .NET) + protobuf serialization and gRPC/HTTP send on a background thread (not measured in any found source; Coroot's tracing result suggests the export path can be a significant share at high event rates). Failure mode: **never blocks the app; drops silently** once 2048 records are queued (≈0.2 s of buffering at 10k records/s/process). This suits a flight recorder only if `otelcol_exporter_*`/SDK drop counters are monitored and `OTEL_BLRP_MAX_QUEUE_SIZE` is raised for DEBUG bursts. In-flight records are lost on app crash.
- **Path B (stdout JSON)** app-side cost = JSON encode + `write(2)` to a pipe. containerd then copies it to `/var/log/pods/...` with the CRI prefix, which costs node CPU and disk I/O outside the pod's cgroup (not attributed to the app). Failure modes: the app **blocks** if the runtime cannot drain the pipe (Docker default blocking; containerd shim history). There is **silent loss** if filelog falls behind kubelet rotation (see Q3). Lines over 16 KiB are split into partial `P` lines. Advantages: logs survive app crash (already in the kernel pipe or on disk) and survive Collector restarts (file plus filelog `storage` checkpoints).
- At 10k lines/s, the Collector ingest cost of Path B (CRI parse ≈33–37% core) is roughly 1.5–2× Path A (OTLP ≈17–23% core). Path A moves serialization cost into each app instead. Both are of similar order, so the decision should rest on failure semantics and per-language SDK maturity as much as on CPU.
- Per-language view (inference): .NET has a measured, cheap OTel path (ILogger → OTel), so Path A is low-risk. Go `otelslog` → `sdk/log` is non-blocking with drop. Rust `tracing` → OTel is cheap until export. Node should use a worker-thread transport for either path. C++ has no measured data (treat Path B with an async logger as the default). Java's appender path is unmeasured (see Gaps).

### Gaps
- **No benchmark found** comparing OTLP export vs stdout+filelog for logs (CPU, RSS, p99, or under Collector slowness) in any language. This is the main item Phase 0 must produce.
- No published overhead numbers for `opentelemetry-appender-log4j`/`logback` (Java), `otelslog` (Go), `@opentelemetry/instrumentation-pino`/`winston` or `pino-opentelemetry-transport` (Node), or the OTel C++ logs SDK.
- No source found on OTel SDK OTLP exporter retry/backoff behaviour for logs when the node Collector is down, or on whether drops are exposed as SDK self-metrics in each language.
- containerd CRI behaviour when the log disk is slow (does the app block on a full pipe in CRI mode, and after how many KiB?) was only found indirectly (Docker docs, AWS shim-logger docs, a containerd 1.4 shim fix). No primary containerd CRI doc on this was fetched.

---

## Q3. Throughput and resource cost of the Collector `filelog` receiver and container log handling; MB/s or lines/s per core

### Takeaway
On official OTel testbed hardware, the Collector ingests 10k logs/s for about 18% of a core with plain `filelog` and 33–37% of a core with Kubernetes CRI/container parsing. Independent and vendor benchmarks put the Collector at about 0.5 cores per 10k logs/s and about 20k logs/s per core with ~216 B lines (~4–5 MB/s per core) in a realistic 100-pod setup. Fluent Bit is 1.5–2× cheaper per log. CPU grows with the number of files watched, and multiline regex caps throughput at ~49 MiB/s. Kubelet keeps only 5×10 MiB per container by default, which bounds how far the agent can fall behind before data is lost.

### Cited Findings
- **OTel contrib load-test dashboard** (98 runs from 2026-07-23 to 2026-09-30, each at 10,000 logs/s through a batch processor to a mock OTLP backend; tests run on "community-owned bare metal machines" since 2023). CPU is process CPU % where 100% = 1 core. Median avg-CPU / median max-RAM:
  - `Log10kDPS/file_log`: 18.33% CPU, 104 MiB
  - `file_log_checkpoints` (with storage): 18.20%, 104.5 MiB
  - `CRI-Containerd`: 20.46%, 110 MiB
  - `k8s_CRI-Containerd`: 33.53%, 117 MiB
  - `kubernetes_containers`: 37.03%, 119 MiB
  - `kubernetes_containers_parser`: 39.09%, 104 MiB
  - `OTLP` (gRPC): 23.33%, 104 MiB
  - `OTLP-HTTP`: 17.03%, 98 MiB
  - `FluentForward-SplunkHEC`: 40.86%
  - `tcp-batch-1`: 29.33% vs `tcp-batch-100`: 9.50% (batching matters)
  - Dropped count was 0 in all of them. An arm64 runner showed lower % (e.g., file_log 7.73%), so hardware matters.
  - Sources: [Collector load-test data.js](https://open-telemetry.github.io/opentelemetry-collector-contrib/benchmarks/loadtests/data.js) (dashboard: [loadtests](https://open-telemetry.github.io/opentelemetry-collector-contrib/benchmarks/loadtests/)); [OTel blog: component performance benchmarks (2023)](https://opentelemetry.io/blog/2023/perf-testing/)
- Testbed CI ceilings (`ExpectedMaxCPU` / `ExpectedMaxRAM` MiB) at 10k logs/s: OTLP 30/120, file_log 50/120, k8s CRI-Containerd 100/150, kubernetes containers 110/150 — [testbed/tests/log_test.go](https://raw.githubusercontent.com/open-telemetry/opentelemetry-collector-contrib/main/testbed/tests/log_test.go)
- **VictoriaMetrics, March 2026** **[vendor-authored: VictoriaMetrics sells vlagent, which "wins"; harness is open source]**. Single-node kind cluster on GCP n2-highcpu-32, 100 log-generator pods, ~216 B JSON records, each collector limited to 1 CPU/1 GiB. Max throughput: OTel Collector v0.146.1 20,500 logs/s; Vector v0.53.0 25,000; Fluent Bit v4.2.3 31,300; Alloy 15,700; Promtail 13,400; Filebeat 5,250; Fluentd 5,100; vlagent 143,000. At ~10k logs/s: OTel Collector 0.491 cores/106.83 MiB; Vector 0.412 cores/153.50 MiB; Fluent Bit 0.260 cores/78.10 MiB. During rotation, Fluent Bit produced 34 incomplete records/hour and Vector 2; none were reported for the OTel Collector. Vector's default `glob_minimum_cooldown_ms` (60 s) caused silent loss on new pod files — [VictoriaMetrics log collectors benchmark 2026](https://victoriametrics.com/blog/log-collectors-benchmark-2026/); harness [github.com/VictoriaMetrics/log-collectors-benchmark](https://github.com/VictoriaMetrics/log-collectors-benchmark)
- **Sumo Logic** **[vendor docs]**, filelog receiver on AWS m4.large (2 vCPU). At 5% CPU: ~2000 EPS @100 B, 1100 EPS @512 B, 150 EPS @5 KB. Max 19,100 EPS at 90% CPU @512 B. Memory ~113–145 MB. Collector version not stated — [Sumo Logic OTel Collector performance benchmarks](https://www.sumologic.com/help/docs/send-data/opentelemetry-collector/performance-benchmarks/)
- filelog CPU scales with files watched (v0.86.0): ~5% of a core at 100 files and ~110% of a core at 1,000 files. Profile was dominated by GC. The issue was marked required-for-GA and is now closed — [collector-contrib #27404](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/27404)
- Multiline parsing with Go `regexp` plateaus at ~25K records/s (~49 MiB/s) "regardless of allocated CPU or memory". With go-re2 it reaches ~45K/s (~88 MiB/s). The issue is open — [collector-contrib #43040](https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/43040)
- filelog defaults: `poll_interval` 200ms, `max_concurrent_files` 1024, `max_log_size` 1MiB, `fingerprint_size` 1000 (bytes), `start_at` end, `storage` none. Stability: beta for logs. It handles move/create and copy/truncate rotation. Even with storage, logs "are dropped while moving downstream through other components" without extra resiliency config — [filelogreceiver README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/receiver/filelogreceiver/README.md)
- Kubelet log rotation: `containerLogMaxSize` default **10Mi**, `containerLogMaxFiles` default **5**. `containerLogMaxWorkers` and `containerLogMonitorInterval` tune rotation concurrency and interval. "if a Pod writes 40 MiB of logs and the kubelet rotates logs after 10 MiB, running `kubectl logs` returns at most 10MiB" — [Kubernetes: Logging architecture](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
- containerd `max_container_log_line_size` defaults to 16384 bytes. Longer lines are split, and CRI flags mark partial lines that must be rejoined (from search results citing containerd v1.1.2 notes and Filebeat docs; not fetched as a primary doc) — [Filebeat docker input docs](https://www.elastic.co/guide/en/beats/filebeat/7.9/filebeat-input-docker.html)
- GKE managed logging agent (Fluent Bit-based) **[cloud vendor docs]**: "at least 100 KiB per second log throughput per node" (up to ~500 KiB/s or more if the node is underutilized). The high-throughput mode reaches "as high as 10 MiB per second on nodes that have at least 2 unused CPU cores". "At higher throughputs, some logs might be lost... Fluent Bit's behavior becomes undefined... system freezes or Out-of-Memory (OOM) kills" — [GKE: Adjust log throughput](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/adjust-log-throughput)
- Parseable (Aug 2025) **[vendor-authored; t3.small; telemetry was node-exporter metrics, not file logs]**: sustained per-core CPU of Fluent Bit 27–28% vs OTel Collector 41–42% for the same ~1.04M records — [Parseable: Fluent Bit vs OTel Collector profiling](https://www.parseable.com/blog/observability-agent-profiling-fluent-bit-vs-opentelemetry-collector-performance-analysis)

### Inferences
- Planning number for the node agent (Path B, k8s CRI parsing plus k8sattributes): **about 0.35–0.5 cores per 10k lines/s**, i.e. roughly 20–30k lines/s, or about 4–6 MB/s at ~200 B lines, per core. Larger lines are cheaper per byte and dearer per line (Sumo). Path A (OTLP-in) costs about 0.17–0.25 cores per 10k/s on testbed hardware.
- The ring-buffer exporter (in-memory retention of 2 GiB) is not in any benchmark. Its own CPU (copying, eviction) and RAM overhead (pdata in-memory size vs wire bytes) must be measured. GOMEMLIMIT and memory_limiter interplay with a 2 GiB buffer is a real risk (inference, not sourced).
- Kubelet defaults bound Path B buffering at 50 MiB per container. At 80 KB/s per container that is ~10 minutes of on-disk slack, so an agent stall longer than that, or a burst, loses logs before filelog reads them. This is less than the 15-minute flight-recorder target, so raise `containerLogMaxSize` or accept the risk.
- On a 100-pod node, `filelog` watches ≥100 files plus rotated ones. Per #27404, file count rather than bytes may dominate agent CPU.

### Gaps
- No published measurement of **containerd/CRI's own CPU** cost per MB of stdout (the copy from pipe to file with the CRI prefix), nor of kubelet rotation cost. These fall outside both the app's and the Collector's cgroups.
- The OTel testbed's log record size and attribute count were not determined from the fetched sources, so its % CPU cannot be converted to MB/s.
- Splunk docs reportedly give file-count vs lines/s vs CPU sizing (search snippet: "0.5 to 2 cores", "10,000 to 135,000 lines per second"). This was not verified by fetch and is not used here.
- Numbers for the 2026 Collector (v0.13x–0.14x) filelog on arm64 vs x86 at k8s-scale file counts were not found beyond the two arm64 testbed runs.

---

## Q4. Typical DEBUG log volume (bytes/s per service/pod); sanity check of "2 GiB/node for 15 min"

### Takeaway
No vendor publishes a reliable "DEBUG bytes/s per pod" figure. The available anchors: typical event sizes of 200 B to 3 KB, GKE's default agent sized at ≥100 KiB/s per node, and its high-throughput mode at up to 10 MiB/s per node. "2 GiB per 15 min" means a sustained ≈2.39 MB/s (≈2.28 MiB/s) per node. That is ~23× GKE's default per-node guarantee but well under the 10 MiB/s high-throughput ceiling, which makes it a plausible but not generous budget for 20–100 services emitting DEBUG. Phase 0 must measure actual per-service DEBUG rates.

### Cited Findings
- Datadog BYOC Logs sizing **[vendor]**: "Typical log event sizes range from 500 bytes (short syslog) to 2-3 KB (JSON with Kubernetes tags)". "Compression is typically 5x to 8x" — [Datadog BYOC Logs sizing](https://docs.datadoghq.com/es/byoc-logs/operate/sizing)
- VictoriaMetrics benchmark JSON log generator: "Average record size is ~216 bytes" — [VictoriaMetrics benchmark](https://victoriametrics.com/blog/log-collectors-benchmark-2026/)
- GKE logging agent: ≥100 KiB/s per node default (≈500 KiB/s or more possible), up to 10 MiB/s in high-throughput mode with ≥2 spare cores — [GKE: Adjust log throughput](https://docs.cloud.google.com/kubernetes-engine/docs/how-to/adjust-log-throughput)
- Analog for always-on recorders: the Go 1.25 runtime flight recorder (Amedee & Knyszek, 26 Sep 2025) is configured by `MinAge` and `MaxBytes` (set MinAge to ~2× the problem window). "On average, you can expect a few MB of trace data to be produced per second of execution, or 10 MB/s for a busy service" — [go.dev/blog/flight-recorder](https://go.dev/blog/flight-recorder)
- Yan Cui (Apr 2018): debug is usually off in prod for cost reasons (CloudWatch $0.50/GB ingest at the time). He recommends sampling DEBUG for a small percentage of invocations and propagating the decision via correlation IDs so whole call chains are captured — [theburningmonk: You need to sample debug logs in production](https://theburningmonk.com/2018/04/you-need-to-sample-debug-logs-in-production/)
- Kubelet keeps 5 × 10 MiB per container by default — [Kubernetes logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/)

### Inferences
- Arithmetic: 2 GiB / 900 s = 2,386,093 B/s ≈ 2.39 MB/s per node.
  - At ~216 B/line that is ≈11,000 lines/s per node. At 1 KB/line ≈2,300 lines/s. At 2.5 KB (JSON plus k8s attributes as stored) ≈950 lines/s.
  - With 30 pods/node, that is ≈80 KB/s (≈370 lines/s @216 B) per pod. With 100 pods/node, ≈24 KB/s per pod.
- A request-serving service that emits even 10 DEBUG lines per request at 500 RPS produces 5,000 lines/s, ≈1–5 MB/s alone depending on line size. One chatty service can therefore consume the whole node budget and shrink the window well below 15 min. **Per-service quotas or rate limits in the ring buffer (or the SDK) are needed** so one service cannot evict everyone else's context.
- What is stored in the ring buffer is not the wire size: enrichment (k8sattributes, resource attrs) and in-memory pdata structures can inflate 216 B lines several-fold (inference; no source measured pdata overhead). Measure "effective bytes per retained record" in Phase 0.
- The node agent CPU needed for ≈11k lines/s is ≈0.2–0.5 cores (Q3). On an 8-vCPU node that alone is 2.5–6% of node CPU. **The <5% target must say whether agent CPU counts**; if it is per-node, the agent could consume most of the budget.

### Gaps
- No published case study (Datadog, Elastic, Grafana, Honeycomb or others) giving DEBUG vs INFO volume multipliers or per-pod DEBUG bytes/s was found. Blog claims such as "5×–10× cost increase" ([pointfive hub](https://hub.pointfive.co/inefficiencies/excessive-cloudwatch-log-volume-from-persistently-enabled-debugging)) and "performance drop of up to 30%" with DEBUG on (from a dev.to post surfaced by search) are unsourced or anecdotal and should not be used as data.
- A Red Hat OpenShift Logging doc snippet ("a single pod can produce 100 GB/day") surfaced in search, but the page returned 404 on fetch, so it is unverified.

---

## Q5. Phase 0 methodology (load generation, coordinated omission, on/off at fixed load, CFS throttling, SPEC/ICPE, OTel benchmark spec) and techniques to cut DEBUG cost

### Takeaway
Measure overhead as the *difference* between telemetry-off and telemetry-on configurations **at a fixed, open-model request rate** (not max throughput). Record latency from intended send time to avoid coordinated omission, collect both app-cgroup and node-level CPU (agent, containerd), watch CFS throttling, and repeat runs with statistics (SPEC RG principles; OTel suggests ≥10 runs). Reduce DEBUG cost with level guards or Enabled checks, lazy evaluation, compile-time elimination of TRACE, dynamic levels, per-key sampling, and drop-not-block queues.

### Cited Findings

**Benchmark design and statistics**
- OTel performance-benchmark guideline: measure throughput per logical core, plus CPU (avg and peak) and memory at a default 10,000 spans/s for at least 15 s. The OTLP receiver runs out-of-process and discards data. Warm-up for JIT languages. Measurements "measured multiple times (suggest 10 times at least)". The spec targets spans, not logs, and sets no target thresholds — [OTel spec: Performance Benchmark](https://opentelemetry.io/docs/specs/otel/performance-benchmark/)
- OTel Java instrumentation overhead harness: k6 load (`basic.js`), configurable VUs/iterations and `maxRequestRate`, 30 s warm-up. Collects startup time, mean and p95 latency, heap min/max, total allocated memory, GC pause time, peak threads, context-switch rate, user and machine CPU, and network read/write. Compares no-agent vs release vs snapshot, nightly, with CSV results committed — [opentelemetry-java-instrumentation/benchmark-overhead](https://github.com/open-telemetry/opentelemetry-java-instrumentation/tree/main/benchmark-overhead)
- Coroot's Go overhead study is a template: baseline vs SDK on, wrk2 at a fixed 10k RPS for 20 min, with app, dependency, load generator and observability stack on separate nodes. It reported CPU, memory, p99 and network — [Coroot](https://coroot.com/blog/opentelemetry-for-go-measuring-the-overhead/)
- Collector maintainers: "the best way to measure performance is in the context of the specific application by running a load test" — [OTel blog 2023 perf testing](https://opentelemetry.io/blog/2023/perf-testing/)

**Coordinated omission and load generation**
- wrk2: closed-loop generators let "high latency responses result in the load generator coordinating with the server to avoid measurement during high latency periods". wrk2 produces a constant throughput (`-R`), measures latency "from the time the transmission _should_ have occurred", and records into HdrHistogram. In its example with a 1.4 s server stall, p99 is 1.27 s with correction vs 6.04 ms without (~200×) — [giltene/wrk2](https://github.com/giltene/wrk2)
- Log4j's latency study distinguishes service time from response time under a fixed 128k msgs/s load, and notes that response-time graphs show "many more events are impacted by these delays than the service time numbers alone would suggest" — [Log4j 2.12.x performance](https://logging.apache.org/log4j/2.12.x/performance.html)

**CFS throttling**
- Twitter (Dan Luu & David Mackey, 2019, updated 2021): with CFS bandwidth control (100 ms period), services "start falling over at around 50% reserved container CPU utilization". Thread pools larger than reserved cores burn quota quickly, so a "subsecond stop-the-world GC pause could take many seconds of wallclock time". Throttling can cause a "metastable" death spiral. Fixes (thread-pool sizing, offload filters, kernel changes) gave 15–60% cost reductions — [danluu.com/cgroup-throttling](https://danluu.com/cgroup-throttling/)
- Log4j: extra async threads may not help on a single-vCPU VM — [Log4j async manual](https://logging.apache.org/log4j/2.x/manual/async.html)

**SPEC RG methodology (cloud)**
- SPEC RG Cloud WG, "Methodological Principles for Reproducible Performance Evaluation in Cloud Computing" (SPEC-RG-2019-03; Papadopoulos, Versluis, Bauer, Herbst et al.; later IEEE TSE, presented at ICSE 2020). The principles are:
  - P1 Repeated experiments (decide repetitions, "quantify the confidence")
  - P2 Workload and configuration coverage ("different (possibly randomized) configurations")
  - P3 Experimental setup description (hardware/software and versions)
  - P4 Open access artifact
  - P5 Probabilistic result description of measured performance ("full characterization of the empirical distribution")
  - P6 Statistical evaluation (significance when comparing)
  - P7 Measurement units
  - P8 Cost
  - Their survey found that "more than two-thirds of the analyzed papers do not execute any repeated experiments or long runs, and only 21% do both."
  - Sources: [SPEC RG technical report PDF](https://research.spec.org/fileadmin/user_upload/documents/rg_cloud/endorsed_publications/SPEC_RG_2019_Methodological_Principles_for_Reproducible_Performance_Evaluation_in_Cloud_Computing.pdf); [ICSE 2020 page](https://www.idt.mdu.se/~aps01/papadopoulos-ICSE/)

**Techniques to cut DEBUG cost**
- Go slog: "The arguments to a log call are always evaluated, even if the log event is discarded". Use `LogValuer` to defer work and `Logger.Enabled` ("called early, before any arguments are processed"). `LevelVar` is "a Level variable, to allow a Handler level to change dynamically... safe for use by multiple goroutines" — [pkg.go.dev log/slog](https://pkg.go.dev/log/slog)
- zap sampling: "logging the first N entries with a given level and message each tick. If more Entries with the same level and message are seen during the same interval, every Mth message is logged and the rest are dropped". It is "optimized for speed over absolute precision" and offers a `SamplerHook` for drop metrics — [zapcore NewSamplerWithOptions](https://pkg.go.dev/go.uber.org/zap/zapcore#NewSamplerWithOptions)
- zerolog: disabled level 4.07 ns, sampling, `SetGlobalLevel`, non-blocking diode writer — [rs/zerolog](https://github.com/rs/zerolog)
- Rust tracing: `release_max_level_*` removes disabled callsites from the binary (`STATIC_MAX_LEVEL`) — [tracing level_filters](https://docs.rs/tracing/latest/tracing/level_filters/index.html). Disabled `log`/`tracing` events cost 1.6–3.8 ns (uncontrolled measurements) — [instrument-bench](https://github.com/Imberflur/instrument-bench)
- C++: `SPDLOG_ACTIVE_LEVEL` compile-time elimination — [spdlog](https://github.com/gabime/spdlog). Quill bounded-dropping queue keeps p99.9 at 9–18 ns — [quill](https://github.com/odygrd/quill)
- .NET: `[LoggerMessage]` source generation. Disabled source-generated call ≈1.9 ns vs extension-method call 40 ns/64 B vs string interpolation 135 ns/72 B, even with no listener — [MS docs](https://learn.microsoft.com/en-us/dotnet/core/extensions/high-performance-logging); [OTel .NET LogBenchmarks](https://raw.githubusercontent.com/open-telemetry/opentelemetry-dotnet/main/test/Benchmarks/Logs/LogBenchmarks.cs). NLog `ConditionalDebug()` is compiled out; avoid `${callsite}` — [NLog wiki](https://github.com/NLog/NLog/wiki/performance)
- Java: suppliers/lambdas for lazy evaluation. Location info is 30–100× slower. The Discard queue-full policy drops ≤ threshold level instead of blocking — [Log4j performance](https://logging.apache.org/log4j/2.x/manual/performance.html); [Log4j 2.12.x performance](https://logging.apache.org/log4j/2.12.x/performance.html); [Log4j async](https://logging.apache.org/log4j/2.x/manual/async.html)
- Node: pino worker-thread transports; async `minLength` buffering, with crash-loss caveat — [pino transports](https://github.com/pinojs/pino/blob/main/docs/transports.md); [pino asynchronous](https://github.com/pinojs/pino/blob/main/docs/asynchronous.md)
- OTel Logs SDK: `Enabled` / `minimum_severity` / `trace_based` filtering (Development status) — [OTel Logs SDK spec](https://opentelemetry.io/docs/specs/otel/logs/sdk/)
- Request-scoped DEBUG sampling with decision propagation via correlation IDs — [theburningmonk](https://theburningmonk.com/2018/04/you-need-to-sample-debug-logs-in-production/)

### Inferences (proposed Phase 0 protocol)
- **Matrix:** for each language, a representative service × {telemetry off; INFO only; DEBUG → stdout JSON (Path B); DEBUG → OTLP SDK (Path A); DEBUG with guards/sampling}. Use the same image and the same node type, and pin the Collector and ring-buffer config.
- **Load:** open-model fixed rate at roughly 50% and 80% of measured capacity (wrk2 `-R`; k6 constant-arrival-rate; ghz `--rps` for gRPC; Gatling open injection). Warm up ≥30 s (longer for JVM/.NET tiered JIT). Run ≥10–20 min, ≥10 repetitions, with randomized order across configs (SPEC P1/P2).
- **Metrics:**
  - App cgroup CPU (cpu.stat usage), throttled periods and throttled time (cAdvisor `container_cpu_cfs_throttled_*`), RSS and heap, GC pause, allocation rate.
  - p50/p99/p99.9 corrected for coordinated omission (HdrHistogram).
  - Node-level CPU of the Collector, containerd, and kubelet separately. Disk write bytes.
  - Ring-buffer effective retention (minutes actually held) and dropped-record counters on both SDK and Collector sides.
- **Report:** overhead as Δ vs off with confidence intervals (SPEC P5/P6) and in $ per node (P8).
- **Failure-injection runs (essential for path choice):**
  - Collector paused (SIGSTOP) or CPU-limited to 0.25 core.
  - Slow disk / `/var/log` near full.
  - Burst at 10× DEBUG.
  - Collector restart.
  - For each, measure whether app p99 degrades (blocking, the Path B risk) or data is dropped (the Path A risk), and how much.
- **CFS:** Test with production-like CPU limits, because an added logging thread (async appender, worker transport, BatchProcessor goroutine) can push a pod into throttling even at low average CPU (Twitter result). Consider the same test without limits to separate the throttling effect from pure CPU.
- **Cost-reduction defaults to evaluate:** keep DEBUG on but compile out TRACE. Mandate guard/Enabled/lazy APIs and source-gen (.NET). Use per-message-key sampling for hot-loop debug lines (zap/zerolog-style). Prefer drop-not-block queues for DEBUG. Add per-service rate limits in front of the ring buffer. Provide `LevelVar`-style runtime level control to drop to INFO if overhead exceeds budget.

### Gaps
- The OTel performance-benchmark spec covers spans only. No official OTel benchmark methodology or published results exist specifically for *logs* SDK overhead.
- No ICPE paper was found (in this pass) that quantifies logging overhead of specific libraries in microservices on Kubernetes. Only the general SPEC RG methodology was verified. (MooBench/Kieker-style monitoring-overhead work exists in the SPEC RG community but was not fetched and verified here.)
- No primary source was fetched for k6 constant-arrival-rate, ghz `--rps`, or Gatling open-model injection semantics. They are listed as recommendations, not cited facts.
- Specific practitioner claims that removing CPU limits cut p99/p999 from 60/100 ms to ~5 ms (seen in search snippets) were not traced to a primary source and are excluded.
