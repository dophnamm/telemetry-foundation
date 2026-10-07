# OpenTelemetry SDK maturity per language (state as of 2026-10-07): signal status, logs bridges, declarative config, Operator injection, and verification of four spec claims

Research method: opentelemetry.io pages were fetched live, and GitHub repo files, releases and PRs were read through the authenticated GitHub API (`gh api`) on 2026-10-07. Package registries (Maven Central metadata, npm registry, PyPI JSON, NuGet flat-container) were also queried. Release dates come from GitHub release `published_at` timestamps (UTC). Every URL cited below returned HTTP 200 on 2026-10-07. npmjs.com web pages returned 403 to scripted fetches, so npm facts cite registry.npmjs.org instead.

**Main caveat: opentelemetry.io/status lags the repos.** The site table is older than repo READMEs and CHANGELOGs for Go (logs) and Rust (logs and metrics). Where they disagree, both are cited below, and the repo is treated as the more current primary source.

---

## Q1. API/SDK stability per signal (traces / metrics / logs) per language, plus the Go, .NET, C++ and Rust logs specifics, logs bridges, and latest releases

### Takeaway
As of 2026-10-07:
- **Traces and metrics** are Stable in Go, C++, Java, .NET, JS and Python.
- **Logs** are Stable in C++, Java and .NET (via ILogger), and in Go since v1.47.0 (2026-10-02, very recent).
- **JS and Python logs** are still "Development".
- **Rust** is a mixed case. Logs and metrics API/SDK are "Stable" per its README, but traces are still Beta and all crates are still 0.x (0.33.0).
- **.NET:** the public Logs Bridge API (`LoggerProvider.GetLogger`/`Logger`) is still experimental and only in pre-release builds. The ILogger path is the stable route.
- **Logs bridges/appenders** for the common logging libraries are nearly all alpha, beta or 0.x. The exceptions are Rust's `opentelemetry-appender-tracing` (marked Stable) and .NET's built-in ILogger integration.

### Cited Findings

#### Matrix A: Signal status (API / SDK)

| Language | Traces (API / SDK) | Metrics (API / SDK) | Logs (API / SDK) |
|---|---|---|---|
| **Go** | Stable / Stable ([site status](https://opentelemetry.io/status/); [Go README](https://github.com/open-telemetry/opentelemetry-go/blob/main/README.md)) | Stable / Stable ([site status](https://opentelemetry.io/status/); [Go README](https://github.com/open-telemetry/opentelemetry-go/blob/main/README.md)) | **Stable / Stable since v1.47.0 (2026-10-02)** ([Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md); [release v1.47.0](https://github.com/open-telemetry/opentelemetry-go/releases/tag/v1.47.0); [Go README](https://github.com/open-telemetry/opentelemetry-go/blob/main/README.md)). Site still says "Release candidate" ([site status](https://opentelemetry.io/status/); [Go docs page](https://opentelemetry.io/docs/languages/go/)). OTLP log exporters (`otlploggrpc`, `otlploghttp`) and `stdoutlog` are still in the experimental module set v0.23.0 ([versions.yaml](https://github.com/open-telemetry/opentelemetry-go/blob/main/versions.yaml)) |
| **C++** | Stable ([site status](https://opentelemetry.io/status/); [C++ README](https://github.com/open-telemetry/opentelemetry-cpp/blob/main/README.md): "Stable across all 3 signals") | Stable (same sources) | Stable (same sources; [C++ docs page](https://opentelemetry.io/docs/languages/cpp/)) |
| **Rust** | **Beta / Beta** ([Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md)); Traces-OTLP exporter Beta | **Stable / Stable** ([Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md)); Metrics-SDK stable since 0.30.0, 2025-05-23 ([release opentelemetry-0.30.0](https://github.com/open-telemetry/opentelemetry-rust/releases/tag/opentelemetry-0.30.0)); Metrics-OTLP exporter RC; Prometheus exporter Beta | **Stable (bridge API) / Stable** ([Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md)); Logs-SDK stable since 0.29.0, 2025-03-25 ([release opentelemetry-0.29.0](https://github.com/open-telemetry/opentelemetry-rust/releases/tag/opentelemetry-0.29.0)); Logs-OTLP exporter RC. **Conflict:** the site shows Beta/Beta/Beta for all three signals ([site status](https://opentelemetry.io/status/); [Rust docs page](https://opentelemetry.io/docs/languages/rust/)) |
| **Java** | Stable ([site status](https://opentelemetry.io/status/); [Java docs page](https://opentelemetry.io/docs/languages/java/)) | Stable (same) | Stable; log API and SDK promoted to stable in **1.27.0 (2023-06-09)** ([Java CHANGELOG](https://github.com/open-telemetry/opentelemetry-java/blob/main/CHANGELOG.md)). Java is also the only language listed with Profiles = Development ([site status](https://opentelemetry.io/status/)) |
| **.NET** | Stable ([site status](https://opentelemetry.io/status/); [.NET README](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/README.md)) | Stable (same) | Stable via ILogger ([.NET README](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/README.md): "Stable across all 3 signals"). **The Logs Bridge API is experimental (pre-release builds only)**; see the .NET details below ([OTEL1001](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/docs/diagnostics/experimental-apis/OTEL1001.md)) |
| **JavaScript / Node.js** | Stable / Stable ([JS README "Feature Status"](https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md)) | Stable / Stable (same) | **Development / Development** ([JS README](https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md); [site status](https://opentelemetry.io/status/); [JS docs page](https://opentelemetry.io/docs/languages/js/)). `@opentelemetry/sdk-logs` and `@opentelemetry/api-logs` are both at 0.223.0 ([npm registry sdk-logs](https://registry.npmjs.org/@opentelemetry/sdk-logs)) |
| **Python** | Stable ([Python README](https://github.com/open-telemetry/opentelemetry-python/blob/main/README.md); [site status](https://opentelemetry.io/status/)) | Stable (same) | **Development\*** ([Python README](https://github.com/open-telemetry/opentelemetry-python/blob/main/README.md)): "We are working on stabilizing the Log signal which would require making deprecations and breaking changes"; site also says Development ([Python docs page](https://opentelemetry.io/docs/languages/python/)) |

Note: the opentelemetry.io status table has a single status per signal and does not split API from SDK ([site status](https://opentelemetry.io/status/)). Only the JS and Rust READMEs report API and SDK separately ([JS README](https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md); [Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md)).

#### Matrix B: Logs bridge / appender options for common logging libraries

| Language | Bridges/appenders and their maturity |
|---|---|
| **Go** | `go.opentelemetry.io/contrib/bridges/otelslog` (log/slog), `otelzap` (zap), `otellogrus` (logrus) and `otellogr` (logr) are all in the go-contrib **"experimental-bridge" module set, v0.21.0** ([go-contrib versions.yaml](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/versions.yaml)). There is no zerolog bridge in the go-contrib versions.yaml (same source). The bridges therefore stay 0.x even though the Logs API/SDK they target became v1 in v1.47.0 ([Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md)) |
| **C++** | The Logs API/SDK can be used directly (Stable per the [C++ README](https://github.com/open-telemetry/opentelemetry-cpp/blob/main/README.md)). opentelemetry-cpp-contrib has `instrumentation/` directories for **spdlog, glog, log4cxx and boost_log** ([cpp-contrib instrumentation](https://github.com/open-telemetry/opentelemetry-cpp-contrib/tree/main/instrumentation)). Their READMEs declare no maturity level (see Gaps) |
| **Rust** | **`opentelemetry-appender-tracing`: Stable** per the [Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md); stable since 0.29.0 ([release opentelemetry-0.29.0](https://github.com/open-telemetry/opentelemetry-rust/releases/tag/opentelemetry-0.29.0)); current crate 0.33.0 released 2026-09-18 ([appender-tracing CHANGELOG](https://github.com/open-telemetry/opentelemetry-rust/blob/main/opentelemetry-appender-tracing/CHANGELOG.md)). Its span-attribute enrichment is still behind the `experimental_span_attributes` feature flag (same CHANGELOG, 0.32.0). `opentelemetry-appender-log` (for the `log` crate) is also published, but the README status table does not list it. The README recommends `tracing` for new code ([Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md)) |
| **Java** | `opentelemetry-log4j-appender-2.17` and `opentelemetry-logback-appender-1.0` latest **2.32.0-alpha** ([Maven metadata log4j](https://repo1.maven.org/maven2/io/opentelemetry/instrumentation/opentelemetry-log4j-appender-2.17/maven-metadata.xml); [Maven metadata logback](https://repo1.maven.org/maven2/io/opentelemetry/instrumentation/opentelemetry-logback-appender-1.0/maven-metadata.xml)). "any non-stable artifact has the suffix `-alpha`... NONE of the guarantees described above apply to alpha artifacts" ([java-instrumentation VERSIONING](https://github.com/open-telemetry/opentelemetry-java-instrumentation/blob/main/VERSIONING.md)) |
| **.NET** | **Microsoft.Extensions.Logging `ILogger` is the stable path.** The OpenTelemetry .NET log pipeline "is built on top of the Microsoft.Extensions.Logging `ILogger`/`ILoggerProvider`/`ILoggerFactory` APIs" ([OTEL1000](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/docs/diagnostics/experimental-apis/OTEL1000.md)). The NuGet flat-container returned "BlobNotFound" for a package named `OpenTelemetry.Extensions.Logging` (my check on 2026-10-07); the ILogger integration ships in the core `OpenTelemetry` package, latest 1.19.1 ([release core-1.19.1](https://github.com/open-telemetry/opentelemetry-dotnet/releases/tag/core-1.19.1)). The .NET auto-instrumentation adds a **log4net** appender bridge (log4net >= 2.0.13 < 4.0.0, since v1.10.0-beta.1) and **NLog** 5.*/6.* logs instrumentation (since v1.14.0) ([dotnet-instrumentation CHANGELOG](https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/blob/main/CHANGELOG.md)) |
| **Node.js** | `@opentelemetry/instrumentation-winston` v0.67.0 ([release](https://github.com/open-telemetry/opentelemetry-js-contrib/releases/tag/instrumentation-winston-v0.67.0)) + `@opentelemetry/winston-transport` v0.33.0 ([release](https://github.com/open-telemetry/opentelemetry-js-contrib/releases/tag/winston-transport-v0.33.0)), `instrumentation-pino` v0.69.0 ([release](https://github.com/open-telemetry/opentelemetry-js-contrib/releases/tag/instrumentation-pino-v0.69.0)) and `instrumentation-bunyan` v0.68.0 ([release](https://github.com/open-telemetry/opentelemetry-js-contrib/releases/tag/instrumentation-bunyan-v0.68.0)), all released 2026-10-06 and all 0.x. They sit on top of a Logs SDK that is itself "Development" ([JS README](https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md)) |
| **Python** | stdlib `logging`: the SDK `LoggingHandler` was **deprecated in 1.40.0/0.61b0 (2026-03-04)** in favour of `opentelemetry-instrumentation-logging` ([Python CHANGELOG](https://github.com/open-telemetry/opentelemetry-python/blob/main/CHANGELOG.md)). That package is at 0.66b1 with the "Development Status :: 4 - Beta" classifier ([PyPI](https://pypi.org/project/opentelemetry-instrumentation-logging/)) |

#### .NET logs specifics (the ILogger path vs. the Logs Bridge API)
- Experimental APIs "are exposed as `public` in pre-release builds and `internal` in stable builds". The **Active** list includes **OTEL1000** (`LoggerProvider` and `LoggerProviderBuilder`) and **OTEL1001** (Logs Bridge API) — [.NET experimental APIs README](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/docs/diagnostics/experimental-apis/README.md)
- OTEL1001 covers `LoggerProvider.GetLogger`, `Logger`, `LogRecordAttributeList`, `LogRecordData`, `LogRecordSeverity` and `Sdk.CreateLoggerProviderBuilder`. The doc says: "An alternative approach may be taken which would be to append into `ILogger` instead of OpenTelemetry directly" — [OTEL1001](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/docs/diagnostics/experimental-apis/OTEL1001.md)
- `LoggerProviderBuilder`, `LoggerProvider`, `IDeferredLoggerProviderBuilder` and `OpenTelemetryBuilder.WithLogging` were released stable in 1.9.0. `ILoggingBuilder.UseOpenTelemetry` is still under OTEL1000 (experimental) — [OTEL1000](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/docs/diagnostics/experimental-apis/OTEL1000.md); [OpenTelemetry.Api CHANGELOG 1.9.0-rc.1](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry.Api/CHANGELOG.md)
- The Unreleased section of the OpenTelemetry.Api CHANGELOG still lists a "**Breaking change** (pre-release only versions)" to `LoggerProvider.TryCreateLogger`. This confirms the bridge surface is still changing — [OpenTelemetry.Api CHANGELOG](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry.Api/CHANGELOG.md)

#### Go logs timeline (exact versions and dates)
- The Logs API/SDK beta period ran from May 2024. Modules moved from `v0.22.0` (beta) to `v1.47.0-rc.1` — [Go Logs RC blog, 2026-08-31, Robert Pająk](https://opentelemetry.io/blog/2026/go-logs-api-sdk-rc/)
- **RC: v1.47.0-rc.1, 2026-08-28.** It added `Logger`, `GetLoggerProvider` and `SetLoggerProvider` to the root `go.opentelemetry.io/otel` and deprecated `go.opentelemetry.io/otel/log/global` — [release v1.47.0-rc.1](https://github.com/open-telemetry/opentelemetry-go/releases/tag/v1.47.0-rc.1); [Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md)
- **Stable: v1.47.0, 2026-10-02.** "This release contains the first stable release of the OpenTelemetry Go Logs API and SDK. Our project stability guarantees now apply to... `go.opentelemetry.io/otel/log`, `go.opentelemetry.io/otel/sdk/log`" — [Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md); [release v1.47.0](https://github.com/open-telemetry/opentelemetry-go/releases/tag/v1.47.0)
- "The log exporters and `logtest` modules remain experimental" — [Go Logs RC blog](https://opentelemetry.io/blog/2026/go-logs-api-sdk-rc/); the experimental-logs module set is v0.23.0 ([versions.yaml](https://github.com/open-telemetry/opentelemetry-go/blob/main/versions.yaml))
- v1.47.0-rc.1 dropped support for Go 1.25; the project now tests Go 1.26 and 1.27 — [Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md); [Go README](https://github.com/open-telemetry/opentelemetry-go/blob/main/README.md)

#### Matrix C: Latest release per language (as of 2026-10-07; GitHub release timestamps)

| Component | Latest version | Date | Source |
|---|---|---|---|
| Go (otel core) | v1.47.0 (plus metric/log/trace experimental sets 0.69.0/0.23.0/0.1.0) | 2026-10-02 | [release](https://github.com/open-telemetry/opentelemetry-go/releases/tag/v1.47.0) |
| Go contrib | v1.47.0 (otelconf v0.27.0; bridges v0.21.0) | 2026-10-02 (CHANGELOG header says 2026-10-03) | [go-contrib CHANGELOG](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/CHANGELOG.md); [versions.yaml](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/versions.yaml) |
| C++ | v1.29.0 | 2026-09-13 | [release](https://github.com/open-telemetry/opentelemetry-cpp/releases/tag/v1.29.0) |
| Rust | opentelemetry 0.33.0 (family incl. sdk, otlp, appender-tracing) | 2026-09-18 | [release](https://github.com/open-telemetry/opentelemetry-rust/releases/tag/opentelemetry-0.33.0) |
| Java SDK | v1.66.0 | 2026-09-11 | [release](https://github.com/open-telemetry/opentelemetry-java/releases/tag/v1.66.0) |
| Java agent/instrumentation | v2.32.0 (RC for 3.0) | 2026-10-03 | [release](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/tag/v2.32.0) |
| .NET core | core-1.19.1 | 2026-09-21 | [release](https://github.com/open-telemetry/opentelemetry-dotnet/releases/tag/core-1.19.1) |
| .NET auto-instrumentation | v1.17.0 | 2026-09-22 | [release](https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/tag/v1.17.0) |
| JS stable | v2.12.0 | 2026-10-06 | [release](https://github.com/open-telemetry/opentelemetry-js/releases/tag/v2.12.0) |
| JS experimental (sdk-node, sdk-logs, configuration) | experimental/v0.223.0 | 2026-10-06 | [release](https://github.com/open-telemetry/opentelemetry-js/releases/tag/experimental%2Fv0.223.0) |
| Python | v1.45.1 (v1.45.0 / 0.66b0 on 2026-09-25) | 2026-10-06 | [release](https://github.com/open-telemetry/opentelemetry-python/releases/tag/v1.45.1); [CHANGELOG](https://github.com/open-telemetry/opentelemetry-python/blob/main/CHANGELOG.md) |
| Operator | v0.160.0 | 2026-09-28 | [release](https://github.com/open-telemetry/opentelemetry-operator/releases/tag/v0.160.0) |
| OBI | v0.14.0 (stable line); v1.0.0-rc.1 (pre-release) | 2026-10-02; 2026-10-07 | [v0.14.0](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation/releases/tag/v0.14.0); [v1.0.0-rc.1](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation/releases/tag/v1.0.0-rc.1) |
| Go eBPF auto-instrumentation | v0.24.0 | 2026-04-27 | [release](https://github.com/open-telemetry/opentelemetry-go-instrumentation/releases/tag/v0.24.0) |
| Semantic conventions | v1.44.0 | 2026-08-04 | [release](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.44.0) |
| Config schema (opentelemetry-configuration) | v1.2.0 | 2026-09-11 | [release](https://github.com/open-telemetry/opentelemetry-configuration/releases/tag/v1.2.0) |
| Specification | v1.61.0 | 2026-09-14 | [release](https://github.com/open-telemetry/opentelemetry-specification/releases/tag/v1.61.0) |

### Inferences
- For a long-lived company standard, **Go logs can now be treated as stable at the API/SDK level (v1.47.0+)**. But the OTLP log exporters and all go-contrib log bridges (otelslog/otelzap/...) are still 0.x/experimental. A Go "logs via slog bridge to OTLP" pipeline therefore still depends on two experimental modules.
- **Rust:** "Stable" in the README is a project-level claim on 0.x crates. The README stability markings started with 0.29/0.30 (2025), and traces are still Beta. Expect minor-version bumps (0.32→0.33) that can carry breaking changes in Beta components. Pinning Rust crate versions in the internal SDK layer is advisable.
- **.NET:** the internal "event builder" should target ILogger (stable) rather than the OTel Logs Bridge API (`LoggerProvider.GetLogger`). The bridge API is not available in stable NuGet builds at all.
- **JS and Python logs** remain "Development". Any Node.js/Python log-based-event path in the standard should be flagged as subject to breaking changes. For JS, the logs API also moves into `@opentelemetry/api` in SDK 3.x (see Q5).
- The opentelemetry.io status page should not be the only source in the spec. It currently understates Go logs (RC vs Stable) and Rust logs/metrics (Beta vs Stable).

### Gaps
- No API-vs-SDK split exists for C++, Java, .NET or Python in official status tables. The single "Stable" is assumed to cover both.
- The cpp-contrib log bridges (spdlog, glog, log4cxx, boost_log) declare no maturity status in their READMEs. Version and stability could not be verified.
- The exact date C++ logs became stable was not verified in this pass (only the current "Stable" status).
- Serilog/NLog bridges for the .NET *SDK* (outside auto-instrumentation) were not verified. Serilog's OpenTelemetry sink is third-party, not OTel-maintained (not checked in detail).
- Java JUL/JBoss logging appenders and the exact first stable date for the Java appenders were not checked. All Maven appender artifacts found carry `-alpha`.
- The Go zerolog bridge was not found in go-contrib versions.yaml. Whether a community/third-party bridge exists was not checked.

---

## Q2. Declarative configuration (opentelemetry-configuration schema, OTEL_CONFIG_FILE): spec status, since when, and per-language support

### Takeaway
- **The spec and schema are stable.** Key portions of the declarative configuration spec were marked stable by spec PR #4568 (merged 2026-02-27) and released in **spec v1.55.0 (2026-03-05)**. The schema was released as **opentelemetry-configuration v1.0.0 (2026-02-27)** and announced on the OTel blog on **2026-03-05**. The env var is now `OTEL_CONFIG_FILE`; `OTEL_EXPERIMENTAL_CONFIG_FILE` was deprecated or removed per language.
- **Language implementations are not stable anywhere.** Go, C++, Java, JS, Python and PHP have implementations, all in experimental/alpha/0.x packages. .NET has an unreleased experimental SDK package plus an experimental flag-gated mode in its auto-instrumentation. Rust has none.

### Cited Findings
- The spec CHANGELOG v1.55.0 "SDK Configuration" section says "Mark significant portions of declarative configuration as stable" (#4568). The release was published 2026-03-05T16:26:37Z — [spec release v1.55.0](https://github.com/open-telemetry/opentelemetry-specification/releases/tag/v1.55.0). The CHANGELOG.md header misprints the year as "v1.55.0 (2025-03-05)"; the same typo affects v1.56.0–v1.58.0 headers — [spec CHANGELOG](https://github.com/open-telemetry/opentelemetry-specification/blob/main/CHANGELOG.md)
- PR #4568 "Mark declarative config as stable" by jack-berg was merged 2026-02-27. It stabilizes:
  - the schema (opentelemetry-configuration)
  - the YAML file representation
  - the in-memory model
  - `ConfigProperties`
  - `PluginComponentProvider`
  - the `Parse` and `Create` SDK operations
  - the `OTEL_CONFIG_FILE` env var
  
  At the time, C++, Go, Java and JS were up to date with 1.0-rc.3, and PHP with rc.2 — [spec PR #4568](https://github.com/open-telemetry/opentelemetry-specification/pull/4568)
- Spec status today: the data model is "**Status**: Stable" ([data-model.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/configuration/data-model.md)). The configuration SDK is "Stable except where otherwise specified"; some sections remain Development, e.g. `ConfigProvider`/instrumentation API pieces. It also documents "Via OTEL_CONFIG_FILE" ([configuration/sdk.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/configuration/sdk.md))
- **Conflicting statement:** the spec compliance matrix still says "Disclaimer: Declarative configuration is currently in Development status - work in progress". Its declarative-config table shows `+` for Go, Java, JS, PHP, C++ and Kotlin (partial), `-` for .NET, and blank for Python and Rust — [spec-compliance-matrix.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/spec-compliance-matrix.md). This disclaimer is stale relative to the spec docs above.
- The schema repo releases are: v1.0.0-rc.1 2025-06-18, rc.2 2025-09-29, rc.3 2025-12-11, **v1.0.0 2026-02-27**, v1.1.0 2026-06-05 and v1.2.0 2026-09-11 — [opentelemetry-configuration v1.0.0](https://github.com/open-telemetry/opentelemetry-configuration/releases/tag/v1.0.0); [v1.2.0](https://github.com/open-telemetry/opentelemetry-configuration/releases/tag/v1.2.0)
- Blog post "**Declarative configuration is stable!**", dated 2026-03-05, by Jack Berg (Grafana Labs):
  - "implementations available in five languages: C++, Go, Java, JS, PHP. Development is underway for .NET and Python"
  - "Language implementations stabilize on different timelines than the specification"
  - Next steps include deprecating env vars that don't interoperate well
  - The API portion (`ConfigProvider`) for instrumentation config "is out of scope for this initial stabilization"
  
  Source: [OTel blog](https://opentelemetry.io/blog/2026/stable-declarative-config/)
- "Latest supported file format" per language in the support-status doc is: cpp `1.0.0`, go `1.0.0`, java `1.0.0-rc.3`, js `1.0.0-rc.3`, php `1.0.0-rc.2`, python `1.0.0` — [language-support-status.md](https://github.com/open-telemetry/opentelemetry-configuration/blob/main/language-support-status.md). This generated doc lags some changelogs; see Java and C++ below.

#### Matrix D: Declarative config per language

| Language | Implementation and status | Env var | Source |
|---|---|---|---|
| **Go** | `go.opentelemetry.io/contrib/otelconf` in the go-contrib **experimental-config** module set **v0.27.0**. `NewSDK` reads the config file | `OTEL_CONFIG_FILE` supported since go-contrib 1.43.0 (2026-04-03); `OTEL_EXPERIMENTAL_CONFIG_FILE` deprecated in the same release (#8639) | [go-contrib versions.yaml](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/versions.yaml); [go-contrib CHANGELOG](https://github.com/open-telemetry/opentelemetry-go-contrib/blob/main/CHANGELOG.md) |
| **C++** | "File configuration" in the SDK, opt-in at build time via CMake `OTELCPP_WITH_CONFIGURATION`. This was renamed from `WITH_CONFIGURATION` in **1.29.0** (2026-09-13), a build-breaking rename of all CMake options. 1.29.0 also updated file config to **schema 1.1.0** (#4340, #4374), ahead of the support-status doc's "1.0.0" | `OTEL_EXPERIMENTAL_CONFIG_FILE` renamed to **`OTEL_CONFIG_FILE` in 1.26.0 (2026-03-19)** "as the specification for declarative configuration is now stable" | [C++ CHANGELOG](https://github.com/open-telemetry/opentelemetry-cpp/blob/main/CHANGELOG.md) |
| **Rust** | **No implementation found.** A GitHub code search for `OTEL_CONFIG_FILE` in opentelemetry-rust returned 0 hits, and the compliance matrix column is blank | — | [spec-compliance-matrix.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/spec-compliance-matrix.md); [Rust README](https://github.com/open-telemetry/opentelemetry-rust/blob/main/README.md) |
| **Java (SDK)** | `opentelemetry-sdk-extension-declarative-config` **1.66.0-alpha**, extracted to its own artifact in 1.62.0 (2026-05-08). Updated to schema **v1.1.0 in 1.64.0** (2026-07-10). Still taking BREAKING changes in 1.66.0 (2026-09-11) | `otel.experimental.config.file` **removed in 1.63.0 (2026-06-05)**; `otel.config.file` / `OTEL_CONFIG_FILE` remains | [Java README](https://github.com/open-telemetry/opentelemetry-java/blob/main/README.md); [Java CHANGELOG](https://github.com/open-telemetry/opentelemetry-java/blob/main/CHANGELOG.md) |
| **Java (agent)** | "Declarative configuration support in the Java agent is experimental" | `-Dotel.config.file=/path/to/otel-config.yaml` | [Java agent 3.0 preview blog](https://opentelemetry.io/blog/2026/java-agent-3.0-preview/) |
| **.NET (SDK)** | `OpenTelemetry.Configuration.Declarative`: "This is an experimental package"; "A partial experimental implementation". The initial implementation supports only `disabled` and resource attributes, plus `ConfigProperties` and `PluginComponentProvider`. **Unreleased**: its CHANGELOG has only an "Unreleased" section, and NuGet returned 404 for the package on 2026-10-07 | `OTEL_CONFIG_FILE` | [README](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry.Configuration.Declarative/README.md); [CHANGELOG](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry.Configuration.Declarative/CHANGELOG.md) |
| **.NET (auto-instrumentation)** | "File-based Configuration" with **Status: Experimental**. Must be enabled with `OTEL_EXPERIMENTAL_FILE_BASED_CONFIGURATION_ENABLED=true`. Support is "limited": CLR profiler/runtime settings must still be env vars | `OTEL_CONFIG_FILE` since v1.15.0-beta.1 (2026-04-13); `OTEL_EXPERIMENTAL_CONFIG_FILE` support **removed in v1.16.0** (2026-07-08) | [file-based-configuration.md](https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/blob/main/docs/file-based-configuration.md); [dotnet-instrumentation CHANGELOG](https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/blob/main/CHANGELOG.md) |
| **Node.js** | `@opentelemetry/configuration` **0.223.0** (experimental package, 2026-10-06), wired into `@opentelemetry/sdk-node`. TypeScript types are generated from schema **v1.0.0** (since 0.217.0). Ongoing fixes in 0.219–0.222 (samplers, exporters, id_generator) | `OTEL_CONFIG_FILE` | [JS experimental CHANGELOG](https://github.com/open-telemetry/opentelemetry-js/blob/main/experimental/CHANGELOG.md); [npm registry](https://registry.npmjs.org/@opentelemetry/configuration) |
| **Python** | `opentelemetry-configuration` **0.66b1** ("Development Status :: 3 - Alpha"). Since 1.44.0 (2026-07-16), when `OTEL_CONFIG_FILE` is set, "The env-var initialisation path is skipped entirely in favour of the declarative" config. More wiring landed in 1.45.0 (2026-09-25) | `OTEL_CONFIG_FILE` | [PyPI](https://pypi.org/project/opentelemetry-configuration/); [Python CHANGELOG](https://github.com/open-telemetry/opentelemetry-python/blob/main/CHANGELOG.md) |

- Java/Spring Boot has a separate 2026 blog post on declarative config, "The Voyage of a Small Environment Variable" (2026-07-14, Gregor Zeitlinger, Grafana Labs, SIG Java). Only its front matter was read, not the content — [OTel blog](https://opentelemetry.io/blog/2026/spring-boot-declarative-config/)

### Inferences
- The *file format* (schema 1.x) and `OTEL_CONFIG_FILE` are a safe long-term contract for the company standard. The *per-language loaders* are not: every one is alpha/0.x/experimental and still breaking (e.g. Java 1.66.0 BREAKING POJO setter rename, C++ 1.29.0 CMake rename).
- **The internal SDK layer's bootstrap should own the loader version pinning.** It should also keep an env-var fallback for Rust (no implementation) and .NET (SDK package not even published; auto-instrumentation needs an extra opt-in flag).
- The schema versions supported by each implementation differ (Java/C++ on 1.1.0, JS on 1.0.0, schema now 1.2.0). The standard should therefore pin a `file_format` version that all target languages accept (likely `1.0`). Verify per language at adoption time.

### Gaps
- No primary source gives a stable (1.0) date or plan for any language's declarative-config implementation.
- language-support-status.md is generated and lags (shows Java and JS at rc.3 while their changelogs show schema v1.1.0/v1.0.0 work). Per-property coverage was not exhaustively compared.
- I did not verify whether the Go `otelconf` "v0.2.0 configuration schema" mention in the go-contrib 1.47.0 CHANGELOG means legacy schema versions are still supported in parallel.

---

## Q3. OpenTelemetry Operator auto-instrumentation injection, Go injection status, OBI relationship, C++/Rust coverage, latest Operator version

### Takeaway
- **Operator v0.160.0 (2026-09-28)** injects Java, Node.js, Python, .NET and Apache HTTPD by default, and Go and Nginx only behind opt-in flags.
- **Go injection** is an eBPF sidecar from opentelemetry-go-instrumentation v0.24.0. That project calls itself "work in progress". The sidecar requires `privileged: true` and `runAsUser: 0`, plus the target exe path.
- **C++ and Rust services have no Operator injection.** OBI (ex-Grafana Beyla, now OpenTelemetry eBPF Instrumentation) can cover them only at the network/protocol level. OBI is still v0 "Development" (v1.0.0-rc.1 cut 2026-10-07) and is not integrated into the Operator.

### Cited Findings
- "Currently, Apache HTTPD, DotNet, Go, Java, Nginx, NodeJS and Python are supported", via the `Instrumentation` CRD (`opentelemetry.io/v1alpha1`) — [Operator auto-instrumentation README](https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/auto-instrumentation/README.md)
- Default enablement flags: Java, NodeJS, Python, DotNet and ApacheHttpD are `true`. **Go (`enable-go-instrumentation`) is `false` and Nginx (`enable-nginx-instrumentation`) is `false`** — [Operator feature-gates.md](https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/reference/feature-gates.md)
- Default images in Operator 0.160.0:
  - autoinstrumentation-java=2.31.1
  - nodejs=0.78.0
  - python=0.66b0
  - dotnet=1.17.0
  - go=v0.24.0
  - apache-httpd=1.0.4
  - nginx=1.0.4
  
  Source: [Operator versions.txt](https://github.com/open-telemetry/opentelemetry-operator/blob/main/versions.txt). Note the Java default is 2.31.1, not the newest 2.32.0.
- Go injection rules:
  - It requires `OTEL_GO_AUTO_TARGET_EXE` (via annotation `instrumentation.opentelemetry.io/otel-go-auto-target-exe` or the CR); without it "instrumentation injection to abort".
  - It "requires elevated permissions... `privileged: true`, `runAsUser: 0`".
  
  Source: [Operator Go guide](https://github.com/open-telemetry/opentelemetry-operator/blob/main/docs/auto-instrumentation/languages/go.md)
- An Operator changelog entry added `spec.go.securityContext` to override the Go sidecar defaults, with "hardcoded defaults required for eBPF (Privileged, RunAsUser: 0)" kept when unset — [Operator CHANGELOG](https://github.com/open-telemetry/opentelemetry-operator/blob/main/CHANGELOG.md)
- The Go auto-instrumentation project says: "This project is currently work in progress"; it provides "tracing instrumentation for Go libraries using eBPF". Latest release is v0.24.0 (2026-04-27) — [go-instrumentation README](https://github.com/open-telemetry/opentelemetry-go-instrumentation/blob/main/README.md); [release v0.24.0](https://github.com/open-telemetry/opentelemetry-go-instrumentation/releases/tag/v0.24.0)
- An alternative for Go that the Operator does not inject: **OpenTelemetry Go Compile-Time Instrumentation v1 (first stable release)**, announced 2026-07-16 by Kemal Akkoyun (Datadog). It is a build-time change: "change a single line in how you build your binary or container image" — [OTel blog](https://opentelemetry.io/blog/2026/go-compile-time-instrumentation-v1/)
- Operator 0.160.0 also contains:
  - BREAKING: network policies disabled by default
  - removal of the autoinstrumentation-php image definition
  - Kubernetes 1.37 support
  
  Source: [Operator release v0.160.0](https://github.com/open-telemetry/opentelemetry-operator/releases/tag/v0.160.0)
- Operator status on the site is "mixed", with components in v1alpha1 and v1beta1 — [site status](https://opentelemetry.io/status/)
- The Operator CHANGELOG has no entries mentioning OBI. The only "ebpf" references concern the Go sidecar — [Operator CHANGELOG](https://github.com/open-telemetry/opentelemetry-operator/blob/main/CHANGELOG.md)
- **OBI lineage:** "the project, originally Grafana Beyla, was donated earlier this year by Grafana Labs". The first alpha release was announced 2025-11-03 — [OTel blog: OBI first release](https://opentelemetry.io/blog/2025/obi-announcing-first-release/)
- **OBI status:** "OBI is currently in Development. Users should expect breaking changes between minor releases while the project remains in `v0`" — [OBI README](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation/blob/main/README.md). v1.0.0-rc.1 (pre-release, 2026-10-07) is "the first release candidate for OBI's first stable major release". It needs at least 14 days of maintainer validation before final release, and adopts "the documented subset of OpenTelemetry declarative configuration" as part of the proposed v1 config contract — [OBI v1.0.0-rc.1](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation/releases/tag/v1.0.0-rc.1). A stable 1.0 is the flagship 2026 goal — [OBI 2026 goals blog, 2026-01-23](https://opentelemetry.io/blog/2026/obi-goals/)
- **OBI coverage of C++/Rust:**
  - OBI docs claim "Wide language support: Java (JDK 8+), .NET, Go, Python, Ruby, Node.js, C, C++, and Rust" — [OBI docs](https://opentelemetry.io/docs/zero-code/obi/)
  - The support matrix only lists runtime baselines for Go, Java, Node.js, Python, Ruby/Puma and nginx. It states: "Additional language families may be instrumented through network-level tracing, but are not listed here unless the repository documents a concrete runtime or library compatibility baseline"
  - Network-level protocols include HTTP/1.x, HTTP/2, gRPC, SQL protocols, NATS and others, with limits such as "Generic TLS cannot inject" for HTTP/2/gRPC
  - Requirements: Linux 5.8+ (RHEL 4.18+), BTF, amd64/arm64, and root or capabilities
  
  Source: [OBI SUPPORT_MATRIX](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation/blob/main/SUPPORT_MATRIX.md)

### Inferences
- For the stated stack, the Operator covers **Java, .NET and Node.js** well (default-on, mature agents). **Go** is opt-in and needs privileged sidecars, which is likely to conflict with restricted Pod Security Admission. **C++ and Rust** get nothing from the Operator, so manual SDK instrumentation through the internal bootstrap layer is required for them.
- OBI could give baseline RED metrics and HTTP/gRPC spans for C++/Rust services without code changes, deployed separately from the Operator (e.g. DaemonSet/Helm). Two limits apply: it is pre-1.0, and TLS context injection on HTTP/2/gRPC is not possible on the generic path. It should be positioned as a complement, not a replacement, for SDK instrumentation.
- For Go, compile-time instrumentation (stable v1) is likely a better long-term zero-code path than the Operator's eBPF sidecar, but it moves the integration point to CI/build rather than K8s admission.

### Gaps
- No primary source gives a roadmap for OBI integration into the Operator `Instrumentation` CRD.
- No Operator documentation was found on injecting `OTEL_CONFIG_FILE`/declarative config through the Instrumentation CR. The `configFile` field found in the CRD reference is the Nginx config path, not OTel declarative config. This was not exhaustively searched.
- The exact Operator release in which Go support became gated by `--enable-go-instrumentation` was not dated. The CHANGELOG notes the featuregate `operator.autoinstrumentation.go` was replaced by that flag (#2675).

---

## Q4. Verification of the four claims the architecture spec relies on

### Takeaway
- **Claim 1 (semconv latest is v1.44.0): TRUE**, released 2026-08-04.
- **Claim 2 (JS logs SDK is "Development"): TRUE**, on both opentelemetry.io/status and the opentelemetry-js README (API and SDK).
- **Claim 3 ("Don't Wrap OpenTelemetry" blog post): TRUE.** The full title is "Don't Wrap OpenTelemetry — You're Probably Hurting More Than Helping", by Cijo Thomas (Microsoft), 2026-06-24.
- **Claim 4 (declarative config declared stable): TRUE.** Spec PR #4568 merged 2026-02-27; schema v1.0.0 on 2026-02-27; spec v1.55.0 and the blog post on 2026-03-05.

### Cited Findings

**Claim (1): Semantic conventions latest = v1.44.0**
- The GitHub releases list shows **v1.44.0 (2026-08-04)** as the newest release, after v1.43.0 (2026-07-03), v1.42.0 (2026-06-12), v1.41.1 (2026-05-11), v1.41.0 (2026-04-28) and v1.40.0 (2026-02-19) — [semconv release v1.44.0](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.44.0)
- v1.44.0 breaking changes include a `browser.web_vital` event rework, renamed k8s/container paging-fault metrics, and `{container,k8s.pod,k8s.node}.memory.usage` becoming an updowncounter. It also promotes `network.interface.name` and a set of k8s/container memory metrics to release_candidate — [semconv CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md)
- Stability by area (documents at tag v1.44.0):
  - **HTTP: Stable.** "**Status**: Stable, Unless otherwise specified" ([http-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/http/http-spans.md)); HTTP was marked stable in v1.23.0, released 2023-11-03 ([semconv CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md))
  - **Database: Stable** ("Stable, Unless otherwise specified") ([database-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/db/database-spans.md)). It was marked stable for **MariaDB, Microsoft SQL Server, MySQL and PostgreSQL** in v1.33.0 (2025-05-02) ([release v1.33.0](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.33.0); [CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md)). The Oracle DB client span is RC (v1.40.0)
  - **Messaging: Development** ([messaging-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/messaging/messaging-spans.md))
  - **RPC: Release Candidate** (core RPC plus gRPC and Apache Dubbo, marked RC in v1.40.0, 2026-02-19) ([rpc-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/rpc/rpc-spans.md); [release v1.40.0](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.40.0))
  - **Kubernetes: mixed.** A selection of k8s and container attributes was promoted to **stable** in v1.42.0 (2026-06-12) ([release v1.42.0](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.42.0); [CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md)). For example, `k8s.cluster.name` is Stable in the registry ([k8s registry](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/registry/attributes/k8s.md)). Many k8s metrics are only RC, and the overall k8s resource doc remains "Development". The earlier attributes RC milestone was announced 2026-03-16 ([K8s SemConv RC blog](https://opentelemetry.io/blog/2026/k8s-semconv-rc/))
  - **Exceptions: Stable as logs; span-event form Deprecated.** `exceptions-logs.md` is "Stable, except where otherwise specified" ([exceptions-logs.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/exceptions/exceptions-logs.md)). `exceptions-spans.md` is "**Status**: Deprecated — Use Semantic conventions for exceptions in logs instead" ([exceptions-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/exceptions/exceptions-spans.md)). The change came in v1.40.0 (2026-02-19): "Update exception recording guidelines to not use span events" (#3256), plus the introduction of `OTEL_SEMCONV_EXCEPTION_SIGNAL_OPT_IN` (#3363) ([CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md))
  - **Code attributes: Stable.** "Mark `code.*` semantic conventions as stable" in v1.33.0 (2025-05-02) ([CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md)); e.g. `code.column.number` is Stable ([code registry](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/registry/attributes/code.md))
  - Also stable in 2026: `deployment.environment.name`, `telemetry.distro.*` (v1.41.0), and `service.instance.id`/`service.namespace` (v1.40.0) ([CHANGELOG](https://github.com/open-telemetry/semantic-conventions/blob/main/CHANGELOG.md))

**Claim (2): JS logs SDK status = "Development"**
- The opentelemetry.io status table row is "JavaScript | Stable | Stable | Development" — [site status](https://opentelemetry.io/status/); JS docs page "Traces Stable | Metrics Stable | Logs Development" — [JS docs](https://opentelemetry.io/docs/languages/js/)
- The opentelemetry-js README "Feature Status" row reads "Logs | Development | Development" (API Status | SDK Status) — [JS README](https://github.com/open-telemetry/opentelemetry-js/blob/main/README.md)
- The packages are still 0.x: `@opentelemetry/sdk-logs` 0.223.0 (2026-10-06), with a `0.300.0-development.1` canary — [npm registry sdk-logs](https://registry.npmjs.org/@opentelemetry/sdk-logs)

**Claim (3): "Don't Wrap OpenTelemetry" blog post**
- Details — [OTel blog](https://opentelemetry.io/blog/2026/dont-wrap-opentelemetry/):
  - URL: `https://opentelemetry.io/blog/2026/dont-wrap-opentelemetry/` (HTTP 200)
  - Title: **"Don't Wrap OpenTelemetry — You're Probably Hurting More Than Helping"**
  - Author: **Cijo Thomas (Microsoft)**
  - Date: **Wednesday, June 24, 2026** (site "Last modified June 24, 2026: Add blog post: Don't Wrap OpenTelemetry (#10170)")
- Main arguments (all from the same post):
  - **Scope.** The post is about wrapping the OTel **API** (the instrumentation surface). "It's perfectly reasonable for organizations to provide shared helpers that configure the SDK — setting up exporters, sampling policies, resource attributes... That's infrastructure setup, not an API wrapper"
  - **Anti-pattern #1: signatures that force allocation.** Wrapper signatures like `List<KeyValuePair<string,string>>` or `Vec<(String,String)>` heap-allocate on every call and defeat the allocation-free paths: .NET `Histogram<T>.Record` overloads for 1–3 tags, `TagList` for 4–8, and Rust's borrowed `&[KeyValue]` slices
  - **Anti-pattern #2: lookup wrappers.** Name-based instrument lookup per call (`ConcurrentDictionary.GetOrAdd` in .NET, `Mutex<HashMap>` in Rust) becomes a hot-path serialization point. "OTel instruments are designed to be created once at startup and held as a reference"
  - **Compounding costs.** Developers learn the wrapper rather than OTel. You own "an API on top of an API" and must re-expose new features. Debugging gets harder
  - **Testing is not a reason to wrap.** Every SDK ships an InMemoryExporter, plus a stdout exporter
  - **Legitimate exceptions.** (a) Dual-writing during migration from a legacy metrics system, keeping the API surface deliberate. (b) Governance needs (allowed attributes, naming, approved metric definitions), handled via schema plus **code generation that emits direct OTel API calls**, with no runtime wrapper. The post points to **OTel Weaver** as the upstream direction
  - Bottom line: "OpenTelemetry was designed to be the stable, user-facing abstraction... Skip the wrapper."

**Claim (4): Declarative configuration declared stable**
- Announcement: "**Declarative configuration is stable!**", 2026-03-05, Jack Berg (Grafana Labs) — [OTel blog](https://opentelemetry.io/blog/2026/stable-declarative-config/)
- Spec mechanics: PR #4568 merged **2026-02-27** ([PR](https://github.com/open-telemetry/opentelemetry-specification/pull/4568)), released in spec **v1.55.0 on 2026-03-05** ([release](https://github.com/open-telemetry/opentelemetry-specification/releases/tag/v1.55.0)), together with the schema **opentelemetry-configuration v1.0.0 on 2026-02-27** ([release](https://github.com/open-telemetry/opentelemetry-configuration/releases/tag/v1.0.0))
- Precise scope: what became stable is the *spec + schema + `OTEL_CONFIG_FILE`*, **not** language implementations ("Language implementations stabilize on different timelines than the specification") — [OTel blog](https://opentelemetry.io/blog/2026/stable-declarative-config/)

### Inferences
- If the spec states "semconv v1.44.0 is latest", it is accurate as of 2026-10-07 (two months since the last release). Given the roughly monthly cadence, it should be phrased as "v1.44.0 or later", with stable areas named explicitly: HTTP, DB (four systems), code, exceptions-as-logs, and selected k8s attributes. Messaging (Development) and RPC (RC) are not yet safe to treat as stable.
- The company's thin SDK layer (config + bootstrap only) is explicitly endorsed by the "Don't Wrap" post. The **event builder** is the part that could drift into API wrapping. To stay aligned with the post, it should either emit via the native Logs API with zero-allocation patterns, or be code-generated (Weaver-style) rather than a runtime wrapper taking collections/names per call.
- For Claim 4, the spec should avoid implying that SDKs are stable for declarative config. Only the format and env var are.

### Gaps
- Blog author handle and affiliation were taken from the post byline; no further verification of the author was needed or done.
- I did not check whether the semconv repo has an unreleased v1.45.0 in progress on `main` (only releases were checked).

---

## Q5. 2026 deprecations and breaking changes relevant to a long-lived standard

### Takeaway
- **Span Events API deprecation.** OTel is deprecating the Span Events API (`Span.AddEvent`/`RecordException`) in favor of log-based events (OTEP 4430). It was announced 2026-03-17. Semconv already marks exceptions-as-span-events "Deprecated" and provides `OTEL_SEMCONV_EXCEPTION_SIGNAL_OPT_IN`. The spec's Trace API text itself does not yet mark the methods deprecated.
- **Java agent 3.0** (targeted October 2026; 2.32.0 is its RC) flips DB and code semconv to stable defaults.
- **JS SDK 3.0** (planned 2026-09-30, not yet released as of 2026-10-07) moves the Logs API into `@opentelemetry/api` and requires Node.js >= 22.15.0.
- **Other breaking changes:** Go logs v1 global API moves; C++ 1.29.0 CMake renames; Python `LoggingHandler` deprecation; config env var renames.

### Cited Findings
- **Span Events deprecation:** blog "Deprecating Span Events API", 2026-03-17, by Liudmila Molkova (Grafana Labs), Robert Pająk (Splunk) and Trask Stalnaker (Microsoft) — [OTel blog](https://opentelemetry.io/blog/2026/deprecating-span-events/). Key points:
  - "The tracing specification will deprecate APIs such as `Span.AddEvent` and `Span.RecordException` in favor of emitting log-based events"
  - "we are deprecating the **API** for recording span events, not the ability to see events attached to spans"
  - "The SDK will offer you a way transform log-based events back onto span events"
  - Instrumentations will "move from span events to log-based events in their next major versions"
  - New custom instrumentation should "Prefer the Logs API for new events and exceptions"
- The OTEP "Span Event API deprecation plan" (#4430) landed in spec v1.45.0 (2025-05-14). Spec v1.56.0 (2026-04-20) added "event to span event bridge" under Logs (#5006) — [spec CHANGELOG](https://github.com/open-telemetry/opentelemetry-specification/blob/main/CHANGELOG.md); [OTEP PR #4430](https://github.com/open-telemetry/opentelemetry-specification/pull/4430); [spec release v1.56.0](https://github.com/open-telemetry/opentelemetry-specification/releases/tag/v1.56.0)
- A text search of the current Trace API spec for "deprecat" returns no matches, so `Span.AddEvent`/`RecordException` are not yet formally marked deprecated in the API spec text — [trace/api.md](https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md)
- **Exceptions migration flag:**
  - `OTEL_SEMCONV_EXCEPTION_SIGNAL_OPT_IN` has values `logs` (logs only) and `logs/dup` (both). The default stays span events
  - Instrumentations SHOULD keep their existing major version for at least six months after dual emission starts, and MAY drop the variable in their next major version
  
  Source: [exceptions-spans.md v1.44.0](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/exceptions/exceptions-spans.md)
- **Semconv stability flag:** HTTP, DB, messaging and RPC docs all still instruct existing instrumentations that they "SHOULD introduce an environment variable `OTEL_SEMCONV_STABILITY_OPT_IN`" — [http-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/http/http-spans.md); [rpc-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/rpc/rpc-spans.md); [messaging-spans.md](https://github.com/open-telemetry/semantic-conventions/blob/v1.44.0/docs/messaging/messaging-spans.md)
- **Java agent 3.0:** blog post 2026-10-06 by Jay DeLuca — [Java agent 3.0 preview blog](https://opentelemetry.io/blog/2026/java-agent-3.0-preview/); [release v2.32.0](https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/tag/v2.32.0):
  - 2.32.0 "serves as the release candidate for **3.0**, which is targeted for **October 2026**"
  - "Database and code conventions become stable defaults, messaging adopts newer conventions that are still experimental"
  - Preview flags: `OTEL_INSTRUMENTATION_COMMON_V3_PREVIEW`, `OTEL_SEMCONV_STABILITY_OPT_IN=database/dup,code/dup`, and the new `OTEL_SEMCONV_STABILITY_PREVIEW=messaging/dup`
  - Changes include:
    - `db.system` → `db.system.name`
    - `db.statement` → `db.query.text`
    - `db.client.connections.max` → `db.client.connection.limit`
    - messaging span renames (`orders publish` → `send orders`)
    - `enduser.id` → `user.name`
    - Hibernate/Hystrix/Twilio instrumentations off by default
    - **Zipkin exporter removed in preview mode**
- **Java SDK** stays 1.x (v1.66.0, 2026-09-11). Its declarative-config artifacts had BREAKING changes in 1.62.0, 1.63.0, 1.64.0 and 1.66.0, all in `-alpha` artifacts — [Java CHANGELOG](https://github.com/open-telemetry/opentelemetry-java/blob/main/CHANGELOG.md)
- **JS SDK 3.0** — [JS 3.x announcement](https://github.com/open-telemetry/opentelemetry-js/blob/main/doc/3.x/announcement.md); [JS 3.x migration guide](https://github.com/open-telemetry/opentelemetry-js/blob/main/doc/3.x/migration-guide.md); [JS experimental CHANGELOG](https://github.com/open-telemetry/opentelemetry-js/blob/main/experimental/CHANGELOG.md):
  - The plan was "Feature-freeze for 2.x: September 1, 2026; SDK 3.0 release: September 30, 2026"
  - SDK 3.0 requires Node.js `>=22.15.0` (except `@opentelemetry/api` and `@opentelemetry/semantic-conventions`)
  - It consolidates `sdk-trace-base/node/web` into `@opentelemetry/sdk-trace`
  - It drops Jaeger propagator/exporter and the OpenTracing/OpenCensus shims
  - The migration guide says "`@opentelemetry/api-logs` (package removed) — The Logs API is now part of `@opentelemetry/api`"
  - The experimental CHANGELOG `0.300.0-development.1` also removes `sdk-node` re-exports
- **JS 3.0 has not shipped as of 2026-10-07.** On npm, `@opentelemetry/core` latest is 2.12.0 (2026-10-06) and canary is `3.0.0-development.1` (2026-10-05); `@opentelemetry/api` latest is 1.9.1, canary `1.10.0-development.1` — [npm registry core](https://registry.npmjs.org/@opentelemetry/core); [release v2.12.0](https://github.com/open-telemetry/opentelemetry-js/releases/tag/v2.12.0)
- **Go:** there is no v2 of the core. The logs v1 release deprecates `go.opentelemetry.io/otel/log/global` in favour of root-package `otel.Logger`/`GetLoggerProvider`/`SetLoggerProvider` (rc.1, 2026-08-28). v1.47.0 removes the experimental `OTEL_GO_X_METRIC_EXPORT_BATCH_SIZE` env var and applies a default max attribute-value depth of 64 — [Go CHANGELOG](https://github.com/open-telemetry/opentelemetry-go/blob/main/CHANGELOG.md)
- **.NET:** core remains 1.x (1.19.1). Release notes for 1.19.0 add `AddOpenTelemetry` for `IHostApplicationBuilder` and an `AlwaysRecordSampler`. No 2.0 announcement was found in RELEASENOTES — [release core-1.19.1](https://github.com/open-telemetry/opentelemetry-dotnet/releases/tag/core-1.19.1). The Logs Bridge API is still pre-release with breaking changes — [OpenTelemetry.Api CHANGELOG](https://github.com/open-telemetry/opentelemetry-dotnet/blob/main/src/OpenTelemetry.Api/CHANGELOG.md)
- **C++ 1.29.0 (2026-09-13):**
  - All CMake options were renamed with the `OTELCPP_` prefix (e.g. `WITH_OTLP_HTTP` → `OTELCPP_WITH_OTLP_HTTP`)
  - BREAKING: `noexcept` was removed from the public SDK provider/tracer/logger/meter constructors
  - The repo carries a `DEPRECATED.md` with current deprecation plans
  
  Source: [C++ CHANGELOG](https://github.com/open-telemetry/opentelemetry-cpp/blob/main/CHANGELOG.md)
- **Python:** SDK `LoggingHandler` deprecated in 1.40.0 (2026-03-04) in favour of `opentelemetry-instrumentation-logging` — [Python CHANGELOG](https://github.com/open-telemetry/opentelemetry-python/blob/main/CHANGELOG.md)
- **Config env var renames:**
  - `OTEL_EXPERIMENTAL_CONFIG_FILE` → `OTEL_CONFIG_FILE`: C++ 1.26.0, go-contrib 1.43.0, .NET auto-instr removal in v1.16.0, Java removal of `otel.experimental.config.file` in 1.63.0 (see Q2 sources)
  - The blog also signals future deprecation of env vars that "don't interoperate well" with declarative config — [OTel blog](https://opentelemetry.io/blog/2026/stable-declarative-config/)
- **Operator 0.160.0:** BREAKING change, network policies are now disabled by default; the PHP auto-instrumentation image definition was removed — [Operator release v0.160.0](https://github.com/open-telemetry/opentelemetry-operator/releases/tag/v0.160.0)

### Inferences
- The internal **event builder should emit log-based events** (Logs API / ILogger with an event name), not span events. This aligns with the deprecation direction and with semconv exceptions-as-logs (Stable). But the Logs API is still "Development" in JS and Python and only just stable in Go, so the event builder's backing implementation will differ in maturity per language.
- The standard should specify a migration policy for `OTEL_SEMCONV_STABILITY_OPT_IN` (`database/dup`, `code/dup`, `http/dup`) and `OTEL_SEMCONV_EXCEPTION_SIGNAL_OPT_IN` (`logs/dup`). Dashboards and alerts would need dual-name support during the Java 3.0 transition and similar transitions in other languages.
- Node.js services pinned to Node 18/20 will be blocked from the JS SDK 3.x line (Node >= 22.15.0 required). The standard's runtime baseline for Node.js should account for this.

### Gaps
- The final Java agent 3.0.0 and JS SDK 3.0.0 release dates are unknown: both were planned or targeted for Sept–Oct 2026 and neither was released as of 2026-10-07.
- No primary source gives a timeline for when the spec will formally mark `Span.AddEvent`/`RecordException` deprecated in the Trace API text, or for per-language SDK deprecations of those methods.
- I did not verify whether the Go, .NET or Python SDKs have shipped the "log-based events → span events" compatibility transform yet.
