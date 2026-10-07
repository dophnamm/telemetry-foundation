# OpenTelemetry Reports, Whitepapers, Specs, Case Studies, Books and Emerging Topics: an Annotated Reading List (as of 7 October 2026)

Audience: someone learning OpenTelemetry (OTel) on a Prometheus + Loki + Tempo + Grafana stack, with Node.js and Python services on Docker Compose and Kubernetes.
How links were checked: every URL below was requested with curl on 2026-10-07. "200" means the page loaded. Pages marked "(bot-protected)" returned a 403 or a Cloudflare challenge to curl, but they appeared in search results or a WebFetch read, so they exist. Dates come from the page's `article:published_time` or `datePublished` metadata where it had one. Statuses older than 2026 are labelled **historical**.

## 1. Official and neutral whitepapers, reports, specifications and stability status

### Takeaway
OpenTelemetry has been a **CNCF Graduated project since 21 May 2026**. Tracing, baggage and the logs Bridge API/SDK/protocol are stable, as is OTLP for traces, metrics and logs. The metrics SDK is "mixed", and the profiles protocol is still pre-stable. For Node.js and Python, traces and metrics are **Stable** but **logs are still "Development"**, which matters for anyone sending app logs to Loki through the OTel SDK. The canonical neutral overview is the CNCF Observability Whitepaper (v1.0, Oct 2023). Its repo was archived in Dec 2025, after observability moved into CNCF TAG Operational Resilience.

### Cited Findings
**Graduation and project reports**
- **[OpenTelemetry is a CNCF Graduated Project](https://opentelemetry.io/blog/2026/otel-graduates/)**. OpenTelemetry project blog, 21 May 2026 (200).
  - Summary: the official project announcement of graduation. It frames graduation as "not the finish line".
  - Why useful: the canonical primary source to cite for OTel's maturity.
  - [Source](https://opentelemetry.io/blog/2026/otel-graduates/)
- **[CNCF Announces OpenTelemetry's Graduation, Solidifying Status as the De Facto Observability Standard](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)**. CNCF press release, 21 May 2026 (200).
  - Summary: the release gives these figures:
    - 12,000+ contributors from 2,800+ companies.
    - Second-highest velocity of 240+ CNCF projects, after Kubernetes.
    - JavaScript API at 1.36B downloads and Python API at 1.3B downloads in the past 12 months.
    - Named adopters: Alibaba, Anthropic, Bloomberg, Capital One, eBay, FICO, Heroku and AWS (Bedrock AgentCore).
    - An independent third-party security audit was completed. TOC sponsors were Emily Fox and Davanum Srinivas.
  - Why useful: hard adoption numbers. It also shows that JS and Python, this reader's languages, are among the most-downloaded OTel APIs.
  - [Source](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)
- Date note: one search-result summary said OTel "crossed to Graduated on May 11, 2026". I could not trace that claim to a primary source. Both primary sources use 21 May 2026, the announcement date at Observability Summit in Minneapolis. — [CNCF](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)
- **[OpenTelemetry Has Graduated… Now what?](https://opentelemetry.io/blog/2026/otel-grad-now-what/)**. OTel blog, 15 Jul 2026 (200). Republished by CNCF as **[OpenTelemetry has graduated… now what?](https://www.cncf.io/blog/2026/08/31/opentelemetry-has-graduated-now-what/)**, Adriana Villela and Reese Lee, 31 Aug 2026 (200).
  - Summary: the post-graduation roadmap covers:
    - GenAI and agentic workloads.
    - Browser and mobile observability.
    - Weaver, for telemetry-schema governance.
    - The Packaging initiative ("installable modules").
    - The OpenTelemetry Injector, for automatic instrumentation.
  - Why useful: the best short statement of where the project is heading in late 2026.
  - [Source](https://www.cncf.io/blog/2026/08/31/opentelemetry-has-graduated-now-what/)
- **[OpenTelemetry Project Journey Report](https://www.cncf.io/reports/opentelemetry-project-journey-report/)**. CNCF, 20 Oct 2023 (200). **Historical.**
  - Summary: OTel joined CNCF on 17 May 2019 and reached incubation in August 2021. By report time it had 9,160+ contributors, 55,640+ commits and 1,100+ contributing companies.
  - Why useful: a baseline for measuring growth. Compare it with the 2026 numbers of 12k+ contributors and 2.8k+ companies.
  - [Source](https://www.cncf.io/reports/opentelemetry-project-journey-report/)

**Neutral whitepaper**
- **[CNCF TAG Observability: Observability Whitepaper](https://github.com/cncf/tag-observability/blob/main/whitepaper.md)**. CNCF TAG Observability with 40+ community contributors, v1.0 released Oct 2023 (200).
  - Summary: a vendor-neutral primer covering:
    - What observability is.
    - The signals: metrics, logs, traces, profiles and dumps.
    - Correlating signals.
    - Use cases: SLIs/SLOs, alerting and root-cause analysis.
    - Current gaps.
  - The repo was **archived on 18 Dec 2025** and is read-only.
  - Why useful: the most neutral conceptual grounding, and the right first read before vendor docs.
  - [Source](https://github.com/cncf/tag-observability/blob/main/whitepaper.md)
- CNCF moved to five TAGs: Workloads Foundation, Operational Resilience, Infrastructure, Security & Compliance, and Developer Experience. The former TAG Observability's scope now sits in **[TAG Operational Resilience](https://contribute.cncf.io/community/tags/operational-resilience/)**, which lists observability, troubleshooting and performance among its topics. The legacy site [tag-observability.cncf.io](https://tag-observability.cncf.io) still loads (© 2025). — [CNCF blog, 4 Nov 2025](https://www.cncf.io/blog/2025/11/04/why-cncf-tags-are-the-core-of-cloud-native-innovation-and-where-to-find-them-at-kubecon-atlanta/)

**Specification and stability status (current)**
- **[Specification Status Summary](https://opentelemetry.io/docs/specs/status/)**. OpenTelemetry (200, living page).
  - Tracing: "completely stable, and covered by long term support".
  - Metrics: API and protocol stable, SDK "mixed".
  - Logs: Bridge API, SDK and protocol stable.
  - Baggage: stable.
  - Profiles: protocol in "Development".
  - Why useful: the authoritative signal-by-signal maturity table.
  - [Source](https://opentelemetry.io/docs/specs/status/)
- Status inconsistency: the Profiles spec pages ([Profiles](https://opentelemetry.io/docs/specs/otel/profiles/), 200) now show **"Status: Alpha"**, while the Status Summary still shows "Development" for the profiles protocol. The summary page appears to lag the Alpha announcement. — [Profiles spec](https://opentelemetry.io/docs/specs/otel/profiles/); [Status summary](https://opentelemetry.io/docs/specs/status/)
- **[Language/Collector Status page](https://opentelemetry.io/status/)**. OpenTelemetry (200, living page).
  - JavaScript and Python: Traces Stable, Metrics Stable, **Logs Development**, no Profiles.
  - Go: Logs "Release candidate".
  - Java: Logs Stable, Profiles Development.
  - The Collector and the K8s Operator are "mixed" (Operator CRDs are v1alpha1/v1beta1).
  - Why useful: tells a Node.js/Python team exactly which signals are production-safe in their SDKs.
  - [Source](https://opentelemetry.io/status/)
- **[OTLP Specification](https://opentelemetry.io/docs/specs/otlp/)**. The page title currently reads "OTLP Specification 1.11.0" (200). Proto releases on [GitHub](https://github.com/open-telemetry/opentelemetry-proto/releases):
  - v1.11.1: 29 Sep 2026.
  - v1.11.0: 21 Jul 2026.
  - v1.10.0: 9 Mar 2026, the release that shipped the Profiles Alpha data model.
  - Why useful: the wire protocol everything in the stack speaks. Prometheus, Loki and Tempo all accept OTLP.
  - [Source](https://opentelemetry.io/docs/specs/otlp/); [releases](https://github.com/open-telemetry/opentelemetry-proto/releases); [ClickHouse summary of Profiles in proto v1.10.0](https://clickhouse.com/resources/engineering/otel-news-profiles-signal)
- **[OpenTelemetry Semantic Conventions](https://opentelemetry.io/docs/specs/semconv/)**. The page title reads "semantic conventions 1.44.0" (200). Semconv v1.44.0 was released 4 Aug 2026.
  - Why useful: the attribute names (`service.name`, `http.*`, `db.*`, `k8s.*`) that drive Grafana dashboards, the Loki structured metadata and Prometheus `target_info`.
  - [Source](https://opentelemetry.io/docs/specs/semconv/); [releases](https://github.com/open-telemetry/semantic-conventions/releases)
- **[HTTP semantic conventions declared stable](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/)**. OTel blog, 6 Nov 2023 (200). **Historical milestone.**
  - Summary: the first stable semconv (v1.23.0). It renamed `net.peer.*`/`net.host.*` to `client.*`/`server.*` and introduced the `OTEL_SEMCONV_STABILITY_OPT_IN=http` or `http/dup` migration switch.
  - Why useful: explains why older Node.js/Python dashboards break on upgrade.
  - [Source](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/)
- Database semantic conventions were declared stable in 2025. Per a secondary source this was in v1.33.0. — [Grafana Labs blog, 6 Jun 2025](https://grafana.com/blog/database-observability-how-opentelemetry-semantic-conventions-improve-consistency-across-signals/) (bot-protected); [Grafana 2026 recap](https://grafana.com/blog/opentelemetry-and-grafana-labs-whats-new-and-whats-next-in-2026/)
- **[Kubernetes attributes promoted to release candidate in OTel Semantic Conventions](https://opentelemetry.io/blog/2026/k8s-semconv-rc/)**. OTel blog, 16 Mar 2026 (200).
  - Summary: K8s attributes reached `release_candidate`. Users can opt in with the `k8sattributes` processor feature gates `processor.k8sattributes.EmitV1K8sConventions` and `DontEmitV0K8sConventions`.
  - A follow-up post, **[Kubernetes attributes processor reaches v1.0.0](https://opentelemetry.io/blog/2026/k8s-attributes-processor-v1/)**, came on 16 Sep 2026 (200).
  - Why useful: directly relevant to K8s label enrichment in Loki, Tempo and Prometheus.
  - [Source](https://opentelemetry.io/blog/2026/k8s-semconv-rc/)
- **[Declarative configuration is stable!](https://opentelemetry.io/blog/2026/stable-declarative-config/)**. OTel blog, 5 Mar 2026 (200).
  - Summary: the opentelemetry-configuration JSON schema reached 1.0.0, with a YAML file format, enabled via `OTEL_CONFIG_FILE`.
  - Implementations exist for C++, Go, Java, **JavaScript** and PHP. **.NET and Python are "underway"**.
  - Why useful: one YAML file can configure Node.js SDKs. Python still relies on env vars and code.
  - [Source](https://opentelemetry.io/blog/2026/stable-declarative-config/)
- **[Performance Benchmark of OpenTelemetry API](https://opentelemetry.io/docs/specs/otel/performance-benchmark/)**. OTel spec (200). This is a guideline for how SDKs should measure and report overhead (see section 3). — [Source](https://opentelemetry.io/docs/specs/otel/performance-benchmark/)

### Inferences
- For a Node.js/Python + Loki setup, the safest log path in Oct 2026 is probably this: keep app logs as structured stdout or an existing logging library, and ship them through a Collector (filelog receiver or Docker/K8s logs) to Loki's native OTLP endpoint. Treat the SDK logs bridge in JS/Python as "Development" and expect breaking changes. This is inferred from the language status table above.
- Graduation plus stable declarative config, K8s semconv RC and the k8sattributes processor v1.0 suggest 2026 is the year the "platform plumbing" of OTel matured, while signals at the edge (profiles, GenAI) remain experimental.

### Gaps
- I did not find a dedicated CNCF OTel graduation due-diligence document or a public security-audit report link in this session. The press release says an audit was completed but I did not locate the report URL.
- The Status Summary page shows no per-page "last updated" date, so the exact date of each stability transition (for example, when the metrics SDK became "mixed") is not documented here.
- I did not check RPC and messaging semconv stability. The Grafana Jan 2026 recap says RPC and MCP conventions were "in progress".

## 2. Notable end-user case studies of OpenTelemetry adoption and migration at scale

### Takeaway
The richest, most current case studies are the OTel Developer Experience SIG interview series from 2026 on Adobe, Skyscanner and Mastodon. These are also published as "reference implementations" in the OTel docs. They converge on the same lessons:
- Keep Collector topology simple.
- Isolate pipelines per signal.
- Set a memory limiter from day one.
- Sample aggressively.
- Budget effort for semantic-convention upgrades.

Older but still instructive accounts come from eBay (2022), GitHub (2021), Lightstep (2023) and Shopify (2020). Two 2026 surveys add population-level data.

### Cited Findings
**Developer Experience SIG reference implementations (2026)**
- **[Inside Adobe's OpenTelemetry pipeline: simplicity at scale](https://opentelemetry.io/blog/2026/devex-adobe/)**. OTel DevEx SIG interview with Bogdan Stancu (Adobe), 8 Apr 2026 (200).
  - Summary: thousands of Collectors per signal type in a three-tier design:
    1. A Helm chart with an immutable sidecar plus a configurable deployment collector.
    2. A managed namespace with a separate collector per signal.
    3. Multiple backends.
  - Teams enable instrumentation by adding two annotations. Signal isolation stops a rate-limited backend from stalling the other signals. Adobe built a custom circuit-breaker extension to propagate backend auth errors upstream.
  - Lesson: "OTLP success doesn't guarantee end-to-end delivery" in chained collectors.
  - Why useful: a blueprint for multi-tier Collector topologies on K8s.
  - [Source](https://opentelemetry.io/blog/2026/devex-adobe/)
- **[How Skyscanner scales OpenTelemetry: managing collectors across 24 production clusters](https://opentelemetry.io/blog/2026/devex-skyscanner/)**. OTel DevEx SIG with Neil Fordyce (Skyscanner Hubble platform team), 21 Apr 2026 (200).
  - Summary: 1,000+ microservices on 24 production K8s clusters, Java-heavy **with Python and Node.js**.
    - Topology: a gateway Collector ReplicaSet for OTLP plus a DaemonSet agent that scrapes Prometheus endpoints. Istio routes traffic to the nearest collector.
    - They derive platform metrics from Istio spans to avoid Prometheus cardinality explosions, and drop SDK HTTP/RPC metrics globally.
    - They filter false-positive 404 errors from cache services.
  - Lessons:
    - Upgrading HTTP semconv meant rewriting transform-processor rules.
    - "Memory limiter from day one".
  - Why useful: the closest match to this reader's stack (Prometheus scraping, Node.js/Python services, K8s).
  - [Source](https://opentelemetry.io/blog/2026/devex-skyscanner/); [reference implementation](https://opentelemetry.io/docs/guidance/reference-implementations/)
- A search-engine summary of Skyscanner sources (unverified) says the OTel journey began in 2021 and that 300+ microservices were migrated "in a matter of weeks" by bumping one core library version. It is likely drawn from [Skyscanner Engineering, "Skyscanner's journey to effective observability" (Medium)](https://medium.com/@SkyscannerEng/skyscanners-journey-to-effective-observability-655167a49d2f) (bot-protected; not read directly) or the [localized Skyscanner reference-implementation page](https://opentelemetry.io/ko/docs/guidance/reference-implementations/skyscanner/). I did not confirm these figures on the primary page, so treat them as unverified.
- **[How Mastodon Runs OpenTelemetry Collectors in Production](https://opentelemetry.io/blog/2026/devex-mastodon/)**. OTel DevEx SIG (Juliano Costa, Tristan Sloughter, Johanna Öjeling, Damien Mathieu, with Tim Campbell of Mastodon), 18 Mar 2026 (200).
  - Summary: mastodon.social serves about 300k daily active users and about 10M requests/minute on 70–80 pods. Observability is run by one engineer.
  - Design: **one Collector per K8s namespace**, with no gateway/agent tiers, deployed via the OTel Operator and Argo CD.
  - Sampling: successful traces at about 0.1%, all error traces kept. They upgrade within days of each release.
  - Why useful: shows a small team can run OTel simply. This is a good model for a Docker Compose → K8s learner.
  - [Source](https://opentelemetry.io/blog/2026/devex-mastodon/)
- The OTel docs collect these three as **[Reference implementations](https://opentelemetry.io/docs/guidance/reference-implementations/)** (200): Adobe, Mastodon and Skyscanner. — [Source](https://opentelemetry.io/docs/guidance/reference-implementations/)

**Earlier migrations (historical but instructive)**
- **[Why and How eBay Pivoted to OpenTelemetry](https://opentelemetry.io/blog/2022/why-and-how-ebay-pivoted-to-opentelemetry/)**. eBay engineering on the OTel blog, 19 Dec 2022 (200). **Historical.**
  - Summary: eBay's Sherlock.io platform moved from Elastic Beats to the OTel Collector for metrics and logs ingestion, to align with industry standards.
  - Why useful: a migration away from an agent-per-backend model at very large scale. eBay is also named as an adopter in the 2026 graduation release.
  - [Source](https://opentelemetry.io/blog/2022/why-and-how-ebay-pivoted-to-opentelemetry/)
- **[Why (and how) GitHub is adopting OpenTelemetry](https://github.blog/engineering/infrastructure/why-and-how-github-is-adopting-opentelemetry/)**. Wolfgang Hennerbichler and Andrew Hayworth, GitHub Blog, 26 May 2021 (updated 22 Sep 2021) (200). **Historical.**
  - Summary: GitHub standardised on OTel tracing, mostly in Ruby/Rails, to replace multiple statsd dialects. Auto-instrumentation drove adoption, and vendor-neutral data avoids re-instrumenting when switching backends.
  - Why useful: a clear "why OTel" business case.
  - [Source](https://github.blog/engineering/infrastructure/why-and-how-github-is-adopting-opentelemetry/)
- **[End-User Q&A Series: Migrating to OTel at Lightstep](https://opentelemetry.io/blog/2023/end-user-q-and-a-04/)**. OTel End User WG, 24 Jul 2023 (200). **Historical.**
  - Summary: lessons from migrating from OpenTracing/OpenCensus. Covers the Target Allocator for Prometheus scraping and the trade-offs of sidecar Collectors.
  - Why useful: Target Allocator guidance applies directly when replacing Prometheus scrape configs with Collector-based scraping in K8s.
  - [Source](https://opentelemetry.io/blog/2023/end-user-q-and-a-04/)
- **Shopify: ["Migrating to OpenTelemetry From a Custom Distributed Tracing Pipeline"](https://raw.githack.com/sbueringer/kubecon-slides/master/slides/2020-kubecon-eu/Migrating%20to%20OpenTelemetry%20From%20a%20Custom%20Distributed%20Tracing%20Pipeline%20-%20Francis%20Bogsanyi,%20Shopify%20-KubeCon%20EU%202020.pdf)**. Francis Bogsanyi (Shopify), KubeCon EU 2020 slides via a community mirror (200). **Historical.**
  - Lessons (from search snippets of the slides):
    - Migration takes a long time.
    - Work backward from the end of the pipeline.
    - Migrate traffic from the old pipeline to the new one in fine-grained steps.
    - Trace collection is commoditised.
  - A secondary write-up ([Horovitz, "Shopify's Journey to Planet-Scale Observability"](https://horovits.medium.com/shopifys-journey-to-planet-scale-observability-9c0b299a04dd), bot-protected) claims Shopify removed proprietary agents that caused 15–20% overhead on high-throughput services. This is secondary and not verified against a Shopify primary source.
  - [Source](https://raw.githack.com/sbueringer/kubecon-slides/master/slides/2020-kubecon-eu/Migrating%20to%20OpenTelemetry%20From%20a%20Custom%20Distributed%20Tracing%20Pipeline%20-%20Francis%20Bogsanyi,%20Shopify%20-KubeCon%20EU%202020.pdf)

**Population-level surveys (2026)**
- **[OpenTelemetry Collector Follow-up Survey](https://opentelemetry.io/blog/2026/otel-collector-follow-up-survey-analysis/)**. OTel End User SIG, 28 Jan 2026 (200).
  - Results:
    - 65% run more than 10 Collectors.
    - Kubernetes is used by 81%. VM usage rose from 33% to 51%.
    - Only 39% say the Collector Builder (ocb) is easy to use.
  - Why useful: tells you what "normal" Collector operations look like.
  - [Source](https://opentelemetry.io/blog/2026/otel-collector-follow-up-survey-analysis/)
- **[Prometheus and OpenTelemetry interoperability in 2026: Survey results](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/)**. OTel blog, 22 Sep 2026 (200).
  - Results (81 qualified respondents):
    - Ease-of-use rose from 3.1 to 3.6/5. "Hard to use together" fell from 29% to 10%.
    - 49% mix Prometheus exporters and OTel receivers.
    - OTel SDKs are used by 65% versus 52% for Prometheus SDKs.
  - Pain points:
    - Data-model unification (labels vs attributes).
    - Resource attributes and metadata.
    - Naming and UTF-8.
  - Why useful: **the single most relevant survey for a Prometheus-backed OTel stack**.
  - [Source](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/)

### Inferences
- Across Adobe, Skyscanner and Mastodon, the recurring operational recommendations are:
  - memory_limiter
  - per-signal pipelines
  - tail or very low head sampling for success traces
  - transform/filter processors to normalise semconv
  - frequent small upgrades

  These are a reasonable checklist for a learner moving from Docker Compose to K8s.
- Skyscanner's experience suggests a pattern for a Prometheus backend. Generate low-cardinality RED metrics centrally, from spans or the service mesh, rather than relying on per-SDK HTTP metrics. This matters if Prometheus cardinality is a concern.

### Gaps
- I found **no primary Uber case study of OpenTelemetry adoption** in this session. Uber is historically associated with Jaeger, not OTel migration.
- I found no CNCF-hosted (cncf.io/case-studies) OTel-specific case study in this session. I did not search exhaustively.
- I could not read Shopify's or Skyscanner's own Medium/engineering posts directly (bot-protected), so their figures rely on secondary summaries.
- None of the case studies give quantified cost savings or overhead reductions from a primary source.

## 3. Empirical data on OpenTelemetry performance overhead

### Takeaway
There is no single overhead number. The project itself says you must measure in your own environment. Published measurements range from near-zero (a vendor-tuned Java agent's CPU) to large: about 35% more CPU in a 10k RPS Go service, and 19–80% throughput loss in an academic study where exporting is synchronous or unbatched. Serialization and export of trace data is the main cost, so batching and sampling are the main levers. I found **no official Node.js- or Python-specific overhead benchmark**.

### Cited Findings
- **[Performance Benchmark of OpenTelemetry API](https://opentelemetry.io/docs/specs/otel/performance-benchmark/)**. OTel specification (200). A guideline for how language SDKs should measure and report basic SDK overhead at a given event throughput. Why useful: explains what an "SDK benchmark" means before you compare numbers. — [Source](https://opentelemetry.io/docs/specs/otel/performance-benchmark/)
- **[Collector Benchmarks](https://opentelemetry.io/docs/collector/benchmarks/)**. OpenTelemetry (200, live dashboard).
  - Summary: load tests run on every commit to collector-contrib. Charts show CPU, memory and throughput for scenarios such as 10k spans/s and 10k data points/s, and the data can be downloaded as JSON.
  - Why useful: helps you size Collector resource limits in K8s.
  - [Source](https://opentelemetry.io/docs/collector/benchmarks/)
- **[OTel component performance benchmarks](https://opentelemetry.io/blog/2023/perf-testing/)**. OTel blog, 27 Nov 2023 (200). **Historical.** Explains that Collector load tests moved to community-owned bare-metal machines for consistent results. It also says overhead depends on throughput, hardware, what is instrumented, SDK configuration and sampling. — [Source](https://opentelemetry.io/blog/2023/perf-testing/)
- **[Java agent: Performance](https://opentelemetry.io/docs/zero-code/java/agent/performance/)**. OpenTelemetry docs (200). States it is "impossible to come up with a single agent overhead estimate". It lists the factors (hardware, virtualization and containers, JVM, span volume) and recommends sampling to reduce span volume. — [Source](https://opentelemetry.io/docs/zero-code/java/agent/performance/)
- **[Performance overhead of the Elastic Distribution of OpenTelemetry Java](https://www.elastic.co/docs/reference/opentelemetry/edot-sdks/java/overhead)**. Elastic (vendor) (200). Synthetic benchmark of EDOT Java against no agent:

  | Metric | No agent | EDOT Java | Change |
  |---|---|---|---|
  | Startup | 5.55 s | 6.82 s | +23% |
  | p95 latency | 1.96 ms | 2.06 ms | +5% |
  | CPU | 53.82% | 54.25% | +0.43 pp |
  | Memory allocation | 21.54 GB | 26.37 GB | +22% |
  | Max heap | 436.71 MB | 478.46 MB | +10% |

  Vendor-produced, "indicators" only. — [Source](https://www.elastic.co/docs/reference/opentelemetry/edot-sdks/java/overhead)
- **[OpenTelemetry for Go: measuring the overhead](https://coroot.com/blog/opentelemetry-for-go-measuring-the-overhead/)**. Nikolay Sivko, Coroot (vendor of an eBPF-based alternative), 13 Jun 2025 (200).
  - Setup: a Go HTTP server with a Valkey counter at 10,000 RPS on 4 vCPU/8 GB nodes.
  - With the OTel SDK enabled:
    - CPU: about 2 → 2.7 cores (≈35% more).
    - Memory: about 10 MB → 15–18 MB.
    - p99 latency: 10 ms → about 15 ms.
    - About 4 MB/s of export traffic.
    - About 10% of CPU went to span batching/export.
  - The vendor's eBPF agent stayed under 0.3 cores per node.
  - Why useful: a concrete, reproducible-style number. Note the vendor bias.
  - [Source](https://coroot.com/blog/opentelemetry-for-go-measuring-the-overhead/)
- **[Investigating Performance Overhead of Distributed Tracing in Microservices and Serverless Systems](https://atlarge-research.com/pdfs/2025-tracing-overhead-anou.pdf)**. Anders Nõu, Sacheendra Talluri, Alexandru Iosup and Daniele Bonetta (Vrije Universiteit Amsterdam), Companion of ACM/SPEC ICPE '25, Toronto, May 2025, [DOI 10.1145/3680256.3721316](https://dl.acm.org/doi/10.1145/3680256.3721316). The PDF returned 200; the ACM page is bot-protected.
  - Summary: compares OpenTelemetry with Elastic APM on microservice and serverless workloads. Finds "significant throughput reductions (19-80%) and latency increases (up to 175%)", depending on configuration and environment. "Serializing trace data for export is the largest cause of overhead."
  - Why useful: the best peer-reviewed, OTel-specific overhead study found. It identifies the export stage as the place to optimise (batching, async export, sampling).
  - [Source (PDF text extracted)](https://atlarge-research.com/pdfs/2025-tracing-overhead-anou.pdf)
- **[OpenTelemetry JS Statement on Node.js DOS Mitigation](https://opentelemetry.io/blog/2026/oteljs-nodejs-dos-mitigation/)**. OTel JS SIG, 15 Jan 2026 (200). States that OTel JS is not itself vulnerable to the Node.js `async_hooks` stack-space DoS issue, and that users should upgrade to Node.js 20+ (fixed in 20.20.0+). Why useful: a Node.js-specific runtime caveat for anyone running the OTel JS SDK. — [Source](https://opentelemetry.io/blog/2026/oteljs-nodejs-dos-mitigation/)
- **[Don't Wrap OpenTelemetry — You're Probably Hurting More Than Helping](https://opentelemetry.io/blog/2026/dont-wrap-opentelemetry/)**. OTel blog, 24 Jun 2026 (200). Argues that in-house wrappers around the OTel API add heap allocations and instrument lookups and hurt maintainability, so teams should use the API directly. Why useful: a performance and design pitfall common in Node.js/Python platform teams. — [Source](https://opentelemetry.io/blog/2026/dont-wrap-opentelemetry/)

### Inferences
- Putting the Coroot and ICPE '25 results together: CPU and latency overhead is dominated by span creation volume and export serialization. For Node.js/Python services, the practical levers are probably:
  - BatchSpanProcessor rather than synchronous export.
  - Head or parent-based sampling at the SDK.
  - Tail sampling in a Collector gateway.
  - Avoiding over-instrumentation and wrappers.
- Vendor numbers (Elastic, Coroot) point in opposite directions. Elastic shows near-zero CPU cost for a tuned Java agent; Coroot shows high cost for the Go SDK at 10k RPS. They should be read as context-specific, not general.

### Gaps
- **No official or peer-reviewed Node.js or Python OTel SDK overhead benchmark was found.** An opentelemetry-js GitHub issue (#3940, "Performance benchmarking for general SDK overhead") exists but I did not review its status.
- Several numbers in search snippets could not be traced to a verifiable primary source, so they are excluded:
  - "7–42% CPU overhead".
  - "auto-instrumentation ≈2× manual".
  - "median CPU overhead falls from 17.8% to 3.6% with sampling".

  They appear linked to a Umeå University thesis ("Evaluating OpenTelemetry's Impact on Performance in Microservice Architectures", [PDF](https://umu.diva-portal.org/smash/get/diva2:1877027/FULLTEXT01.pdf)), but the PDF and record page were unreachable (connection refused or bot challenge).
- A University of Turku thesis, "OpenTelemetry Tracing Overhead in a Single Go Service on Kubernetes" ([utupub.fi](https://www.utupub.fi/handle/11111/62394), bot-protected), was found in search but not read.
- I did not find the eBPF profiler's or OBI's own overhead benchmarks.

## 4. Status (as of October 2026) of emerging areas: Profiling, GenAI semconv, OBI, Entities, Logs/Events, OpAMP

### Takeaway
| Area | Status, Oct 2026 |
|---|---|
| **Profiles** | Public **Alpha** since 26 Mar 2026 (OTLP proto v1.10.0, Collector ≥ v0.148.0, eBPF profiler from Elastic). Not for critical production; no SDK API yet. |
| **GenAI semconv** | Entirely **"Development"**. Moved on 12 Jun 2026 to a separate `semantic-conventions-genai` repo, which has no tagged release yet. |
| **OBI** (from Grafana Beyla) | Shipped v0.14.0 on 2 Oct 2026 and **v1.0.0-rc.1 on 7 Oct 2026**, approaching stable 1.0. |
| **Entities** | Data model is **"Development"**. Entity events landed in spec v1.58.0. |
| **Logs** | Logs API, SDK and protocol are **Stable**. The separate Event API was deprecated in favour of LogRecords with `event_name`. The **Span Events API is being deprecated** (Mar 2026). |
| **OpAMP** | Still **Beta** (opamp-spec v0.20.0, Aug 2026). |

### Cited Findings
**Profiling**
- **[OpenTelemetry Profiles Enters Public Alpha](https://opentelemetry.io/blog/2026/profiles-alpha/)**. OTel Profiling SIG, 26 Mar 2026 (200).
  - What shipped:
    - Profiles in Collector v0.148.0+ and an official eBPF-profiler Collector distribution.
    - The eBPF profiler supports Go (on-target symbolization), **Node.js V8 (incl. ARM64)**, .NET 9/10, Ruby and BEAM (initial).
    - The format is about 40% smaller on the wire, and samples can link to trace and span IDs.
  - Limits: "should not be used for critical production workloads". No production backends supported it at launch.
  - Next steps: symbolization APIs, process/thread context sharing, and Beta/GA.
  - Why useful: the authoritative status statement.
  - [Source](https://opentelemetry.io/blog/2026/profiles-alpha/)
- A secondary summary adds component status:
  - Collector support sits behind a feature gate.
  - The eBPF profiler is Alpha and Linux-only.
  - In-process language SDK profiling APIs are "still in design".

  — [ClickHouse summary](https://clickhouse.com/resources/engineering/otel-news-profiles-signal). Corroborated by [Polar Signals, 26 Mar 2026](https://www.polarsignals.com/blog/posts/2026/03/26/opentelemetry-profiling-goes-alpha) (200) and [Elastic Observability Labs](https://www.elastic.co/observability-labs/blog/otel-profiling-alpha) (200).
- Data model OTEPs, now hosted in the spec repo after the standalone `oteps` repo was archived:
  - [OTEP 0212 Profiling Vision](https://github.com/open-telemetry/opentelemetry-specification/tree/main/oteps).
  - **OTEP 0239 "Profiles data model v2"** at `oteps/profiles/0239-profiles-data-model.md`, originally [oteps PR #239 "Introduces Profiling Data Model v2"](https://github.com/open-telemetry/oteps/pull/239) by petethepig (200). Per a secondary source it was proposed in Nov 2023.
  - Newer profiles OTEPs: 4719 (process context) and 4947 (thread context).
  - Spec page: [Profiles Data Format](https://opentelemetry.io/docs/specs/otel/profiles/data-format/) (200), pprof-based, with a generalized dictionary.
  - Sources: [spec repo oteps dir](https://github.com/open-telemetry/opentelemetry-specification/tree/main/oteps); [OTEP 0239 PR](https://github.com/open-telemetry/oteps/pull/239); `gh api` listing on 2026-10-07.
- **[OpenTelemetry announces support for profiling](https://opentelemetry.io/blog/2024/profiling/)**. OTel blog, 19 Mar 2024 (200). **Historical.** The original announcement that profiling would become a signal. — [Source](https://opentelemetry.io/blog/2024/profiling/)
- **[Elastic Contributes its Continuous Profiling Agent to OpenTelemetry](https://opentelemetry.io/blog/2024/elastic-contributes-continuous-profiling-agent/)**. OTel blog, 7 Jun 2024 (200). **Historical.**
  - Summary: the donation of Elastic's eBPF whole-system profiler was accepted. It supports C/C++, Rust, Zig, Go, Java, **Python**, Ruby, PHP, **Node.js/V8**, Perl and .NET. Maintainers come from Grafana Labs, Datadog, Red Hat and others.
  - The repo is now [open-telemetry/opentelemetry-ebpf-profiler](https://github.com/open-telemetry/opentelemetry-ebpf-profiler) (200).
  - [Source](https://opentelemetry.io/blog/2024/elastic-contributes-continuous-profiling-agent/); [CNCF version](https://www.cncf.io/blog/2024/06/07/an-improved-opentelemetry-continuous-profiling-agent/)

**GenAI / LLM semantic conventions**
- **[Inside the LLM Call: GenAI Observability with OpenTelemetry](https://opentelemetry.io/blog/2026/genai-observability/)**. OTel blog, 14 May 2026 (200).
  - Summary: GenAI conventions are "already in use today and under active development".
  - Examples of tools that emit telemetry:
    - VS Code Copilot emits traces, metrics and events.
    - OpenAI Codex exports logs and metrics.
    - Claude Code exports metrics and log events, with traces in beta.
  - Prompt and tool-argument content is not captured by default.
  - Why useful: a practical walkthrough of what GenAI telemetry looks like.
  - [Source](https://opentelemetry.io/blog/2026/genai-observability/)
- **[Semantic Conventions v1.42.0 release](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.42.0)**, 12 Jun 2026 (200). All `gen_ai.*`, `openai.*` and MCP attributes, metrics, events and spans were **deprecated in core semconv and moved** to **[open-telemetry/semantic-conventions-genai](https://github.com/open-telemetry/semantic-conventions-genai)** (200). The old docs page now reads ["Moved: Generative AI semantic conventions"](https://opentelemetry.io/docs/specs/semconv/gen-ai/) (200). — [Release notes](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.42.0); [semconv release dates via GitHub API](https://github.com/open-telemetry/semantic-conventions/releases)
- On 2026-10-07 the `semantic-conventions-genai` repo had **no tagged releases** (GitHub API returned none). Its README still lists the Schema URL as "TODO", and it uses Weaver to depend on core semconv. — [Repo](https://github.com/open-telemetry/semantic-conventions-genai)
- **[The state of the OpenTelemetry GenAI semantic conventions (July 2026)](https://john-hodge.com/blog/opentelemetry-genai-semantic-conventions/)**. John Hodge (independent blog), 17 Jul 2026 (200).
  - Summary: as of mid-July 2026 every `gen_ai.*` attribute, span, metric and event is "Development", with none Stable. Development conventions can be renamed or removed without a deprecation cycle.
  - Why useful: a clear secondary status audit. Treat it as secondary.
  - [Source](https://john-hodge.com/blog/opentelemetry-genai-semantic-conventions/)

**OpenTelemetry eBPF Instrumentation (OBI)**
- **[OpenTelemetry eBPF Instrumentation Marks the First Release](https://opentelemetry.io/blog/2025/obi-announcing-first-release/)**. OBI maintainers (Grafana Labs, Splunk, with Coralogix and Odigos), 3 Nov 2025 (200). **Historical (first alpha).**
  - Summary: OBI instruments at the protocol level, out of process. Protocols include HTTP/S, HTTP/2, gRPC, SQL, Redis, MongoDB, Kafka, GraphQL, Elasticsearch/OpenSearch and AWS S3.
  - Distributed tracing is strongest for Go, **Node.js, Python**, NGINX and PHP. It complements SDKs rather than replacing them.
  - [Source](https://opentelemetry.io/blog/2025/obi-announcing-first-release/)
- **[OpenTelemetry eBPF Instrumentation 2026 Goals](https://opentelemetry.io/blog/2026/obi-goals/)**. OBI SIG, 23 Jan 2026 (200). Goals:
  - A stable 1.0.
  - More protocols: messaging, NoSQL and cloud SDKs.
  - .NET support.
  - Hybrid eBPF + SDK instrumentation.

  — [Source](https://opentelemetry.io/blog/2026/obi-goals/)
- **OBI releases on [GitHub](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation)**: v0.12.1 (20 Aug 2026), v0.13.0 (4 Sep 2026), v0.14.0 (2 Oct 2026), and **v1.0.0-rc.1 (7 Oct 2026, pre-release)**. — [GitHub releases via API](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation)
- **[Zero-code trace-log correlation with OBI](https://opentelemetry.io/blog/2026/obi-trace-log-correlation/)**. OTel blog, 6 Oct 2026 (200). The newest OBI capability, highly relevant to correlating traces in Tempo with logs in Loki. Content not reviewed in detail. — [Source](https://opentelemetry.io/blog/2026/obi-trace-log-correlation/)
- **[Introducing OpenTelemetry eBPF Instrumentation: Why we donated Grafana Beyla to OpenTelemetry](https://grafana.com/blog/opentelemetry-ebpf-instrumentation-beyla-donation/)**. Grafana Labs, 2025 (bot-protected). Beyla continues as **Grafana's distribution of upstream OBI** ([Grafana docs: Using OBI instead of Beyla](https://grafana.com/docs/beyla/latest/obi/), 200). — [Grafana docs](https://grafana.com/docs/beyla/latest/obi/)

**Entities**
- **[Entity Data Model](https://opentelemetry.io/docs/specs/otel/entities/data-model/)**. OTel spec (200). Status: **Development**. An entity has a required Type and an identifying ID attribute set. Entities represent things like `k8s.cluster`, `k8s.node`, `host` or `container`, and can be attached to all signals. — [Source](https://opentelemetry.io/docs/specs/otel/entities/data-model/)
- **[What can you do with OpenTelemetry entity events?](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/)**. OTel blog, 14 Aug 2026 (200). The entity-events spec shipped in spec v1.58.0 (22 Jun 2026). Relationships are embedded as an `entity.relationships` array in entity state events. — [Source](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/)

**Logs Bridge API and Events**
- Logs API spec status: **"Stable, except where otherwise specified"** ([Logs API](https://opentelemetry.io/docs/specs/otel/logs/api/), checked 2026-10-07). The Status Summary lists Bridge API, SDK and protocol as stable, with experimental support for event-conforming log records. — [Status summary](https://opentelemetry.io/docs/specs/status/)
- Per-language logs maturity (Oct 2026): Java Stable; Go "Release candidate" ([Go Logs API and SDK reach RC](https://opentelemetry.io/blog/2026/go-logs-api-sdk-rc/), 31 Aug 2026, 200); **JavaScript and Python "Development"**. — [Status page](https://opentelemetry.io/status/)
- **[Deprecating Span Events API](https://opentelemetry.io/blog/2026/deprecating-span-events/)**. OTel blog, 17 Mar 2026 (200).
  - What changes: `Span.AddEvent` and `Span.RecordException` are targeted for deprecation. New events should be emitted via the Logs API, correlated with spans through context.
  - "OTLP support for log-based events is already stable". Instrumentations will switch in their next major versions, and viewing events on spans keeps working through compatibility layers.
  - Separately, the standalone Events API was deprecated in favour of LogRecords with an `event_name` field.
  - Why useful: changes how Node.js/Python code should record exceptions and events going forward.
  - [Source](https://opentelemetry.io/blog/2026/deprecating-span-events/)

**OpAMP**
- **[Open Agent Management Protocol](https://opentelemetry.io/docs/specs/opamp/)**. OTel spec (200). **Status: Beta.** A protocol for remote management of agent fleets: status reporting, configuration push and package updates. The reference implementation is opamp-go. Recent opamp-spec releases: v0.18.0 (20 May 2026), v0.19.0 (3 Aug 2026), v0.20.0 (12 Aug 2026). — [Spec](https://opentelemetry.io/docs/specs/opamp/); [releases](https://github.com/open-telemetry/opamp-spec/releases)
- **[Operating OpenTelemetry at scale with OpAMP](https://www.cncf.io/blog/2026/07/13/operating-opentelemetry-at-scale-with-opamp/)**. CNCF blog, 13 Jul 2026 (200). A practitioner overview of fleet management with OpAMP. Content not reviewed in detail. — [Source](https://www.cncf.io/blog/2026/07/13/operating-opentelemetry-at-scale-with-opamp/)
- Grafana Labs reported a **private preview of OpAMP-based Fleet Management** for Collector distributions. — [Grafana Labs, "OpenTelemetry and Grafana Labs: What's new and what's next in 2026", Marylia Gutierrez, 14 Jan 2026](https://grafana.com/blog/opentelemetry-and-grafana-labs-whats-new-and-whats-next-in-2026/) (read via WebFetch; bot-protected to curl)

### Inferences
- For this stack in Oct 2026:
  - OBI is the most production-ready emerging item. It is at 1.0 RC, ships inside `grafana/otel-lgtm`, and supports Node.js/Python tracing.
  - Profiles is ready for experimentation only. Pyroscope is bundled in otel-lgtm, and Node.js V8 is supported by the eBPF profiler.
  - GenAI semconv should be treated as unstable schemas, so pin versions and expect renames.
- The span-events deprecation and the push to "events as logs" make Loki (logs) and Tempo (traces) correlation via trace_id/span_id more central. This raises the importance of the JS/Python logs SDKs, which are still "Development", reaching stability.

### Gaps
- I could not confirm the exact OBI 1.0 GA date. Only rc.1 exists as of 2026-10-07.
- I did not find a precise date when the standalone Event API was formally deprecated in the spec.
- I did not verify whether any production backends (including Grafana Pyroscope) officially ingest OTLP Profiles as of Oct 2026. The alpha post says none were production-ready at launch.
- OpAMP's timeline to Stable was not found.
- Entities: I did not find a timeline to stability.

## 5. Most recommended books and long-form guides (plus stack-specific guides for Prometheus, Loki, Tempo and Grafana)

### Takeaway
The core OTel-specific books are:
- *Learning OpenTelemetry* (Young & Parker, O'Reilly, 2024), the best current primer from project co-founders.
- *Mastering OpenTelemetry and Observability* (Flanders, Wiley, 2024).
- *Practical OpenTelemetry* (Gomez Blanco, Apress, 2023), written by a Skyscanner engineer.
- *Cloud-Native Observability with OpenTelemetry* (Boten, Packt, 2022), now **historical** because it predates logs stability.

For concepts and culture, read *Observability Engineering*. The 2nd edition (June 2026) adds Austin Parker as co-author. *Distributed Tracing in Practice* (2020) and the free Google SRE book monitoring chapters are background reading. For the stack itself, the Prometheus OTLP guide, Loki's native OTLP docs and Grafana's `docker-otel-lgtm` are the key hands-on references.

### Cited Findings
**OTel-specific books**
- **[Learning OpenTelemetry: Setting Up and Operating a Modern Observability System](https://www.oreilly.com/library/view/-/9781098147174/)**. Ted Young & Austin Parker, O'Reilly, March 2024 per the O'Reilly listing (some retailers list April 2024), 170 pp (bot-protected).
  - Summary: covers every OTel component and how to set up, operate and troubleshoot an OTel pipeline. Written by an OTel co-founder (Young) and a long-time maintainer (Parker).
  - Why useful: the best single book to start with. It is vendor-neutral and covers architecture, the Collector and rollout strategy.
  - Portuguese (Mar 2025) and Japanese (Jan 2025) translations exist.
  - [Source](https://www.oreilly.com/library/view/-/9781098147174/); [search listing of translations](https://www.oreilly.com/library/view/aprendendo-opentelemetry/9798341636996/)
- **[Mastering OpenTelemetry and Observability: Enhancing Application and Infrastructure Performance and Avoiding Outages](https://www.wiley.com/en-us/Mastering+OpenTelemetry+and+Observability%3A+Enhancing+Application+and+Infrastructure+Performance+and+Avoiding+Outages-p-9781394253128)**. Steve Flanders (founding member of OpenCensus and OpenTelemetry, Splunk), Wiley. Wiley-VCH lists October 2024 while an aggregator lists November 2024. 368 pp (200).
  - Summary: an enterprise-oriented guide to OTel's flexibility, extensibility and vendor neutrality, data portability, and troubleshooting.
  - Why useful: deeper Collector and enterprise coverage from a project founder.
  - [Source](https://www.wiley.com/en-us/Mastering+OpenTelemetry+and+Observability%3A+Enhancing+Application+and+Infrastructure+Performance+and+Avoiding+Outages-p-9781394253128); [Wiley-VCH listing](https://www.wiley-vch.de/de/fachgebiete/computer-und-informatik/mastering-opentelemetry-and-observability-978-1-394-25312-8)
- **[Practical OpenTelemetry: Adopting Open Observability Standards Across Your Organization](https://www.oreilly.com/library/view/practical-opentelemetry-adopting/9781484290750/)**. Daniel Gomez Blanco (Principal Engineer, Skyscanner), Apress, 3 Mar 2023, 241 pp (bot-protected).
  - Summary: organisation-wide adoption. Covers migration off proprietary APM, semantic conventions, sampling strategy and rollout sequencing, with Java examples.
  - Why useful: pairs with the 2026 Skyscanner case study above. It is the best book on the *organisational* side of migration.
  - [Source](https://www.oreilly.com/library/view/practical-opentelemetry-adopting/9781484290750/); [Hatchards listing](https://www.hatchards.co.uk/book/practical-opentelemetry/daniel-gomez-blanco/9781484290743)
- **[Cloud-Native Observability with OpenTelemetry](https://www.oreilly.com/library/view/cloud-native-observability-with/9781801077705/)**. Alex Boten, Packt, May 2022 (bot-protected). **Historical.**
  - Summary: a hands-on, Python-centric introduction to traces, metrics, logs and the Collector, written by a Collector maintainer who also contributed to declarative config.
  - Why useful: good Python examples, but it predates stable logs, current semconv and declarative config. Expect API drift.
  - [Source](https://www.oreilly.com/library/view/cloud-native-observability-with/9781801077705/); [stable declarative config post naming Alex Boten as a contributor](https://opentelemetry.io/blog/2026/stable-declarative-config/)
- Also found but not evaluated:
  - *Observability For Legacy Systems: Methods and Solutions with OpenTelemetry and AIOps* (Apress, August 2025), per an aggregator search result.
  - O'Reilly report *The Future of Observability with OpenTelemetry* ([O'Reilly](https://www.oreilly.com/library/view/the-future-of/9781098118433/)), date not verified.

  — [O'Reilly search listing](https://www.oreilly.com/search/skills/opentelemetry/)

**Concepts and culture**
- **[Observability Engineering, 2nd Edition](https://www.honeycomb.io/observability-engineering-oreilly-book)**. Charity Majors, Liz Fong-Jones, George Miranda and **Austin Parker**, O'Reilly. The O'Reilly listing gives June 2026 and about 632 pp. The Honeycomb landing page is dated 30 Oct 2025 (200). The O'Reilly page is [here](https://www.oreilly.com/library/view/-/9781098179915/) (bot-protected).
  - Summary: "almost entirely rewritten and twice as long". It adds 27 new chapters (only six carried over), including LLMs and AI agent instrumentation, frontend observability, cost and performance, open-source tooling, and observability governance for leaders. Guest contributors include Boris Tane, Phillip Carter and Hazel Weakly.
  - Why useful: the canonical long-form case for wide events / "Observability 2.0", updated for the OTel era.
  - [Honeycomb](https://www.honeycomb.io/observability-engineering-oreilly-book); [O'Reilly listing summary via search](https://www.oreilly.com/library/view/-/9781098179915/)
- **[Observability Engineering (1st ed.)](https://www.oreilly.com/library/view/observability-engineering/9781492076438/)**. Majors, Fong-Jones & Miranda, O'Reilly, May 2022, 318 pp (bot-protected). **Historical (superseded by the 2nd ed.).** — [Source](https://www.oreilly.com/library/view/observability-engineering/9781492076438/)
- **[Distributed Tracing in Practice: Instrumenting, Analyzing, and Debugging Microservices](https://www.oreilly.com/library/view/distributed-tracing-in/9781492056621/)**. Austin Parker, Daniel Spoonhower, Jonathan Mace, Ben Sigelman & Rebecca Isaacs, O'Reilly, April 2020, 327 pp (bot-protected). **Historical.**
  - Summary: the pieces of a tracing deployment (instrumentation, collection, analysis), with sampling and overhead management.
  - Why useful: deep tracing theory from Dapper and OpenTracing veterans. It predates OTel 1.0, so its APIs are dated.
  - [Source](https://www.oreilly.com/library/view/distributed-tracing-in/9781492056621/)
- **[Google SRE Book, Chapter 6: "Monitoring Distributed Systems"](https://sre.google/sre-book/monitoring-distributed-systems/)** (200) and **[SRE Workbook: "Monitoring"](https://sre.google/workbook/monitoring/)** (200). Google, free online.
  - Summary: the "four golden signals" (the page title references them), symptom-based alerting and monitoring philosophy.
  - Why useful: the conceptual basis for RED/USE dashboards and SLO alerting in Prometheus and Grafana.
  - [Source](https://sre.google/sre-book/monitoring-distributed-systems/)

**Stack-specific long-form guides**
- **[Using Prometheus as your OpenTelemetry backend](https://prometheus.io/docs/guides/opentelemetry/)**. Prometheus project docs (200).
  - Summary: enable OTLP ingestion with `--web.enable-otlp-receiver` (endpoint `/api/v1/otlp/v1/metrics`, OTLP/HTTP only).
  - Resource attributes become a `target_info` metric, with `job` set from `service.name` and `instance` from `service.instance.id`.
  - Why useful: the essential guide for pushing OTLP metrics from Node.js/Python SDKs or the Collector directly into Prometheus.
  - [Source](https://prometheus.io/docs/guides/opentelemetry/)
- **[Ingesting logs to Loki using OpenTelemetry Collector](https://grafana.com/docs/loki/latest/send-data/otel/)** (200) and **[How is native OTLP endpoint different from Loki Exporter](https://grafana.com/docs/loki/latest/send-data/otel/native_otlp_vs_loki_exporter/)** (200). Grafana Labs docs.
  - Summary: native OTLP ingestion arrived in Loki 3.0 and is the recommended path. OTel resource and log attributes are stored as structured metadata, so queries need no parsing.
  - The Collector `lokiexporter` was **deprecated as of July 2024**.
  - Why useful: tells you exactly how OTel attributes map into Loki labels and metadata.
  - [Source](https://grafana.com/docs/loki/latest/send-data/otel/native_otlp_vs_loki_exporter/)
- **[Grafana Tempo documentation](https://grafana.com/docs/tempo/latest/)** (200) and **[OpenTelemetry at Grafana Labs](https://grafana.com/docs/opentelemetry/)** (200). The official docs hub for OTLP traces into Tempo and for Grafana's OTel guidance. — [Tempo](https://grafana.com/docs/tempo/latest/); [Grafana OTel docs](https://grafana.com/docs/opentelemetry/)
- **[Docker OpenTelemetry LGTM](https://grafana.com/docs/opentelemetry/docker-lgtm/)** (200) and **[grafana/docker-otel-lgtm on GitHub](https://github.com/grafana/docker-otel-lgtm)** (200). Grafana Labs.
  - Summary: one container image with the OTel Collector, Prometheus, Tempo, Loki, Pyroscope and Grafana, plus optional OBI. It is for development, demo and testing only.
  - Why useful: **the fastest way to stand up this reader's exact stack on Docker Compose** and point Node.js/Python SDKs at it.
  - [Source](https://grafana.com/docs/opentelemetry/docker-lgtm/)
- **[OpenTelemetry and Grafana Labs: What's new and what's next in 2026](https://grafana.com/blog/opentelemetry-and-grafana-labs-whats-new-and-whats-next-in-2026/)**. Marylia Gutierrez, Grafana Labs, 14 Jan 2026 (read via WebFetch).
  - Points relevant to this stack:
    - Resource attributes can now be promoted to labels in Prometheus's OTLP endpoint.
    - Mimir OTLP ingestion improvements.
    - Loki's internal tracing moved from OpenTracing to OTel.
    - Private preview of OpAMP Fleet Management.
    - The Prometheus receiver is approaching stability.
  - Why useful: an annual state-of-the-union for OTel on the Grafana stack.
  - [Source](https://grafana.com/blog/opentelemetry-and-grafana-labs-whats-new-and-whats-next-in-2026/)
- **[OpenTelemetry Demo Docs](https://opentelemetry.io/docs/demo/)**. OpenTelemetry (200). A polyglot microservice demo (Astronomy Shop) including Node.js and Python services. Content not reviewed this session. — [Source](https://opentelemetry.io/docs/demo/)

### Inferences
- Suggested reading order for this learner:
  1. The CNCF whitepaper.
  2. *Learning OpenTelemetry*.
  3. The Prometheus OTLP guide plus the Loki native-OTLP doc, while running `docker-otel-lgtm`.
  4. The Skyscanner, Mastodon and Adobe case studies when moving to K8s.
  5. *Observability Engineering* 2nd ed. for the wide-events philosophy.
- Boten's 2022 Packt book is still useful for its Python examples. Readers should cross-check API names against current semconv (HTTP stable since v1.23.0) and the logs SDK status.

### Gaps
- Most publisher pages (O'Reilly, Packt) block automated fetches, so page counts and dates come from search-result snippets of those pages or from retailers, not from a direct page read.
- I found no Manning OTel book in this session.
- I did not verify a dedicated Node.js- or Python-specific OTel book.
- The Google SRE chapter author and publication year were not verified in-session (commonly cited as Rob Ewaschuk, 2016).

## 6. Notable thought-leadership pieces shaping the field

### Takeaway
Two critiques shape the conceptual debate around OTel. Ben Sigelman's "Three Pillars with Zero Answers" (2018–2019) argued that metrics, logs and traces are just data, not observability. Charity Majors' "Observability 2.0" (2024) argued for arbitrarily-wide structured events as a single source of truth, with metrics and traces derived at query time. Practitioner guides from 2024 (Morrell, Tane) show how to implement wide events with OTel spans. The OTel project's 2026 move to "events are logs" is consistent with, though not identical to, this convergence.

### Cited Findings
- **[Is It Time To Version Observability? (Signs Point To Yes)](https://charity.wtf/2024/08/07/is-it-time-to-version-observability-signs-point-to-yes/)**. Charity Majors (Honeycomb CTO), charity.wtf, 7 Aug 2024 (200).
  - Summary: defines **Observability 1.0** as the "three pillars" with many siloed tools and sources of truth, and **Observability 2.0** as arbitrarily-wide structured events as the single source of truth.
  - Argues that 1.0 forces costly cardinality management and gives only aggregates, while 2.0 enables exploratory, high-cardinality debugging.
  - Why useful: the defining essay of the current debate. It is directly relevant to choosing Loki/Prometheus (1.0-style split storage) versus wide-event stores.
  - [Source](https://charity.wtf/2024/08/07/is-it-time-to-version-observability-signs-point-to-yes/)
- **[Is It Already Time To Version Observability? (Signs Point To Yes.)](https://www.usenix.org/conference/srecon24americas/presentation/majors-plenary)**. Charity Majors, SREcon24 Americas plenary, USENIX (200). The talk version, framing the shift as a "breaking, backwards-incompatible change" in data types, workflows and cost models. — [Source](https://www.usenix.org/conference/srecon24americas/presentation/majors-plenary)
- **"Three Pillars with Zero Answers: A New Scorecard for Observability"**. Ben Sigelman (Lightstep co-founder, Dapper and OpenTracing co-creator), blog post Feb 2019, after the KubeCon NA Dec 2018 talk "Three Pillars, Zero Answers: We Need to Rethink Observability". **Historical but foundational.**
  - Summary: metrics, logs and traces are "just data". Teams that check all three boxes still struggle in incidents. He reframes observability around **detection** and **refinement**, and highlights metric cardinality, log cost and trace sampling problems.
  - The original Lightstep blog URL was not verified. Copies and coverage: [DZone repost](https://dzone.com/articles/three-pillars-with-zero-answers-a-new-scorecard-for-observability) (bot-protected), [InfoQ coverage, Feb 2019](https://www.infoq.com/news/2019/02/rethinking-observability) (bot-protected), [slides on SlideShare](https://www.slideshare.net/slideshow/three-pillars-zero-answers-rethinking-observability/229751434).
  - Why useful: the critique that shaped OTel's emphasis on correlated signals. Sigelman is quoted in the 2026 graduation release as OTel co-creator.
  - [InfoQ](https://www.infoq.com/news/2019/02/rethinking-observability); [CNCF graduation release](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)
- **[A Practitioner's Guide to Wide Events](https://jeremymorrell.dev/blog/a-practitioners-guide-to-wide-events/)**. Jeremy Morrell, 22 Oct 2024 (200).
  - Summary: emit one event per unit of work with everything you can collect. It shows how to implement this as a "main" OTel span enriched by middleware with service, HTTP, user and system attributes, possibly hundreds of them, because columnar storage compresses repetitive data.
  - Why useful: **the most concrete how-to for applying wide events with OTel SDKs in Node.js-style services**.
  - [Source](https://jeremymorrell.dev/blog/a-practitioners-guide-to-wide-events/)
- **[Observability wide events 101](https://boristane.com/blog/observability-wide-events-101/)**. Boris Tane, 7 Sep 2024 (200). He is also a guest contributor to *Observability Engineering* 2nd ed.
  - Summary: "for each request, emit a single context-rich event/log per service hop", paired with fast, non-pre-aggregating query tooling, to investigate unknown unknowns.
  - Why useful: a short, accessible introduction to wide events.
  - [Source](https://boristane.com/blog/observability-wide-events-101/); [Honeycomb 2nd ed. contributors](https://www.honeycomb.io/observability-engineering-oreilly-book)
- **[Deprecating Span Events API](https://opentelemetry.io/blog/2026/deprecating-span-events/)**. OTel blog, 17 Mar 2026 (200). The project is converging on "events are logs with names emitted via the Logs API, correlated with traces and metrics through context". This is a project-level design statement on how signals should relate. — [Source](https://opentelemetry.io/blog/2026/deprecating-span-events/)

### Inferences
- The Prometheus + Loki + Tempo + Grafana stack is architecturally an "Observability 1.0" multi-store design in Majors' terms. Correlation in it relies on shared resource attributes and trace_id/span_id linkage, such as exemplars, Loki derived fields and Tempo trace-to-logs.
- Practitioners can borrow wide-event practices without changing backends. The practice is to put rich attributes on the root span (Morrell's approach) and query them in Tempo with TraceQL. Watch cardinality when spans are turned into metrics for Prometheus; see Skyscanner's approach in section 2.

### Gaps
- I could not verify the canonical URL of Sigelman's original Feb 2019 Lightstep blog post. Lightstep's site has changed since its acquisition, and the DZone and InfoQ copies are bot-protected to curl.
- I did not find a formal OTel project position paper responding to "Observability 2.0". The span-events deprecation is the closest project-level design signal.
