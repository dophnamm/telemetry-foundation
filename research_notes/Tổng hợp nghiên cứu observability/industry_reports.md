# Industry Reports, Surveys and Analyst Research on Observability (2024–2026)

Compiled 2026-10-07. Bias labels used throughout:
- **[VENDOR]** = survey run/commissioned and published by an observability vendor (selection and framing bias likely; samples often drawn from the vendor's own community or customer base).
- **[VENDOR-SPONSORED 3P]** = fieldwork by a third-party research firm (ETR, ESG, Dimensional Research, Coleman Parkes, Wakefield, Censuswide, EMA…) but paid for by one or more vendors.
- **[TELEMETRY]** = derived from a vendor's own customer telemetry, not a survey (biased toward that vendor's customer base).
- **[NEUTRAL]** = foundation/community/independent (CNCF, LF Research, OTel SIGs, Stack Overflow).
- **[ANALYST]** = analyst firm evaluation (paid client research; vendor-hosted reprints are gated).

Verification note: unless marked "(snippet only)" or "(secondary)", the page cited was fetched and the statistic was confirmed on it during this research session. Gartner, IDC and BusinessWire block automated fetches, so those claims rely on vendor press releases and trade press.

---

## Q1. What do the latest editions of the recurring vendor surveys say?

### Takeaway
Across 2024–2026 vendor surveys, four themes repeat. Cost is the top tool-selection criterion. Tool counts are high but slowly consolidating; New Relic shows a slight 2026 rebound to 5.0 tools. AI in observability has gone from interest to near-universal claimed use. OpenTelemetry is near-universally "invested in" but much less often fully in production: Grafana 2026 shows only 10.3% using OTel across all production workloads, and Elastic 2026 shows 11% in production. Outage-cost figures are large but methodologically inconsistent across vendors: New Relic 2026 gives $1.85M per hour; PagerDuty 2024 gives $4,537 per minute.

### Cited Findings

#### 1.1 Grafana Labs Observability Survey [VENDOR; sample = Grafana community, self-selected]
All editions are open, interactive web reports with no sign-up form.

**2024 edition (2nd annual): Grafana Labs Observability Survey 2024** (exact title not confirmed)
- Publisher: Grafana Labs. Published Mar 12, 2024.
- Report: https://grafana.com/observability-survey/2024/ (open).
- Press release: https://grafana.com/press/2024/03/12/grafana-labs-announces-updates-to-kubernetes-monitoring-solution-open-source-innovations-and-findings-from-2024-observability-survey/
- Sample: 306 respondents, recruited via the Grafana website, social media and events.
- Respondents reported "investing in Prometheus (89%) and OpenTelemetry (85%)". "Almost 40% of respondents use both", and more than 50% increased usage of both over the past year. — [Grafana press release 2024](https://grafana.com/press/2024/03/12/grafana-labs-announces-updates-to-kubernetes-monitoring-solution-open-source-innovations-and-findings-from-2024-observability-survey/)
- 75% use Prometheus in production. — [Grafana 2024 report](https://grafana.com/observability-survey/2024/)
- Cost is the biggest concern: 61% cited "cost or unexpected bills" as a top concern (report page). Open source is "a critical piece of 98% of respondents' observability stacks" (press release). — [Grafana 2024 report](https://grafana.com/observability-survey/2024/); [press release](https://grafana.com/press/2024/03/12/grafana-labs-announces-updates-to-kubernetes-monitoring-solution-open-source-innovations-and-findings-from-2024-observability-survey/)
- Tool sprawl: 62 technologies in use, and "70% of teams use four or more" (report page). The press release words it as "more than two-thirds… at least four observability technologies". — [Grafana 2024 report](https://grafana.com/observability-survey/2024/)
- 65% of organizations with a systematic approach saved time or money through centralized observability, versus 35% of reactive teams. — [press release](https://grafana.com/press/2024/03/12/grafana-labs-announces-updates-to-kubernetes-monitoring-solution-open-source-innovations-and-findings-from-2024-observability-survey/)

**2025 edition (3rd annual): Grafana Labs Observability Survey 2025** (exact title not confirmed)
- Published Mar 25, 2025, at KubeCon EU London.
- Report: https://grafana.com/observability-survey/2025/ (open).
- Press release: https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/
- Sample: 1,255 responses, collected Sept 18, 2024 – Jan 2, 2025.
- "70% reporting that their organizations use both Prometheus and OpenTelemetry in some capacity" (press release). The report page says 71%. — [Grafana press release 2025](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/); [report](https://grafana.com/observability-survey/2025/)
- In production: "67% use Prometheus in production in some capacity"; OpenTelemetry 41%, with 38% investigating it and only 6% having no plans to use it. — [Grafana press release 2025](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/)
- Companies use "an average of eight observability technologies" (down from 9), and 101 technologies are cited. — [Grafana 2025 report](https://grafana.com/observability-survey/2025/)
- Cost: "Three-quarters of companies say cost is an important criteria when selecting observability technologies, though less than a third say they're concerned about observability costing too much." Complexity is the top concern (39%), and alert fatigue is the No. 1 obstacle to faster incident response. — [Grafana press release 2025](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/); [report](https://grafana.com/observability-survey/2025/)
- 75% use open-source licensing for observability. 85% use unified infrastructure and application observability. — [press release](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/); [report](https://grafana.com/observability-survey/2025/)

**2026 edition (4th annual): Grafana Labs Observability Survey 2026** (exact title not confirmed)
- Published Mar 18, 2026.
- Report: https://grafana.com/observability-survey/2026/ (open).
- Press release: https://grafana.com/press/2026/03/18/grafana-labs-4th-annual-observability-survey-reveals-a-field-at-a-crossroads-ai-economics-complexity-and-the-enduring-power-of-open-source/
- Sample: 1,363 responses from 76 countries, collected Oct 1, 2025 – Jan 10, 2026. Censuswide hosted the survey platform and helped with analysis.
- Prometheus: 77% have invested, and 21.3% use it across all production workloads. OpenTelemetry: 76% have invested, but only **10.3% use it across all production workloads**. 65% invest in both. — [Grafana 2026 report](https://grafana.com/observability-survey/2026/)
- OpenTelemetry use by signal: metrics 57%, traces 50%, logs 48%. This was read from the press release by a sub-researcher and not re-verified. — [press release 2026](https://grafana.com/press/2026/03/18/grafana-labs-4th-annual-observability-survey-reveals-a-field-at-a-crossroads-ai-economics-complexity-and-the-enduring-power-of-open-source/)
- AI: 92% see value in AI that surfaces anomalies before downtime. 77% find autonomous AI action valuable, though 15% are skeptical. 95% want AI to explain its reasoning. — [Grafana 2026 report](https://grafana.com/observability-survey/2026/)
- Cost is the top selection criterion for the third year running (65%). Complexity/overhead is the biggest concern (38%), and alert fatigue the top incident-response obstacle (30%). 77% saved time or money through centralized observability. — [Grafana 2026 report](https://grafana.com/observability-survey/2026/)
- SaaS: 49% use SaaS for observability on the report page, while the press release says 50% (up from 43%). 17% are SaaS-only. — [report](https://grafana.com/observability-survey/2026/); [press release](https://grafana.com/press/2026/03/18/grafana-labs-4th-annual-observability-survey-reveals-a-field-at-a-crossroads-ai-economics-complexity-and-the-enduring-power-of-open-source/)

#### 1.2 New Relic Observability Forecast [VENDOR-SPONSORED 3P; fieldwork by Enterprise Technology Research (ETR)]
Landing pages require a download form, and the old /2024 and /2025 URLs redirect to the 2026 page. The PDFs, however, are hosted at openly reachable URLs.

**2024 edition: "2024 Observability Forecast"**
- Published Oct 22, 2024.
- Press release: https://newrelic.com/press-release/20241022
- PDF: https://newrelic.com/sites/default/files/2024-10/new-relic-2024-observability-forecast-report.pdf (URL found in search, not opened).
- Sample: 1,700 technology professionals in 16 countries (65% practitioners, 35% ITDMs), surveyed April–May 2024.
- "Median annual downtime from high-impact outages is 77 hours, with an hourly cost of up to US$1.9 million." — [New Relic PR 2024](https://newrelic.com/press-release/20241022)
- Full-stack observability: "79% less downtime (70 hours compared to 338 hours per year)" and "48% lower hourly outage costs". — [New Relic PR 2024](https://newrelic.com/press-release/20241022)
- 42% have deployed AI monitoring. AIOps is at 24%, with 39% planning to deploy it within a year. — [New Relic PR 2024](https://newrelic.com/press-release/20241022)
- Tool count fell 11% and single-tool use rose 37% year over year; 41% plan to consolidate within the next year. — [New Relic PR 2024](https://newrelic.com/press-release/20241022)
- Median annual observability spend was US$1.95M against US$8.15M in value received, a "4x ROI". — [New Relic PR 2024](https://newrelic.com/press-release/20241022)

**2025 edition: "2025 Observability Forecast"**
- Published Sept 17, 2025.
- Press release: https://newrelic.com/press-release/20250917
- PDF (open): https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf
- Sample: 1,700 IT and engineering professionals in 23 countries, surveyed April–May 2025.
- Outages: the median annual cost of high-impact outages is $76M, and the "median cost of $2 million USD per hour, or approximately $33,333 USD for every minute". — [New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)
- "73% of organizations… lack full-stack observability." Hourly outage cost is $1M with full-stack observability versus $2M without. — [New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)
- "AI monitoring utilization went from 42% in 2024 to 54% in 2025." — [New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)
- "The average number of tools has declined by 27% over two years… [to an] average of 4.4 observability tools." 52% plan to consolidate onto unified platforms. — [New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)
- Engineers spend 33% of their time firefighting. A full-text search of the PDF found no mention of "OpenTelemetry" or "OTel". — [New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)

**2026 edition: "2026 Observability Forecast" (latest)**
- Published Sept 22, 2026.
- Press release: https://newrelic.com/press-release/20260922
- Landing page (form): https://newrelic.com/resources/report/observability-forecast/2026
- Sample: 2,575 IT and engineering leaders and practitioners in 24 countries and 12 industries, surveyed April–May 2026 with ETR.
- Outages: organizations "lose an annualized $74 million to high-impact outages", with a "mean cost of $1.85 million per hour and $30,833 for every minute". 36% have a high-impact outage weekly or more often; only 15% never do. — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- MTTD/MTTR: detection averages "41 minutes" and resolution "54 minutes". 70% report a faster MTTD and 69% a faster MTTR. — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- **OpenTelemetry:** "Nearly three-quarters of organizations (73%) are standardized on OTel, actively migrating to it, or testing it. Only 2% have ruled it out." — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- AI: "25% of organizations have deployed AI agents in production without any monitoring", and 47% have AI application observability. — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- The average tool count "crept back up from 4.4 to 5.0" (landing-page copy, read by a sub-researcher). 76% report a positive ROI of at least 1x. — [New Relic 2026 landing page](https://newrelic.com/resources/report/observability-forecast/2026); [PR](https://newrelic.com/press-release/20260922)

#### 1.3 Splunk (Cisco) State of Observability [VENDOR-SPONSORED 3P]
- Gated: the report form is at https://www.splunk.com/en_us/form/state-of-observability.html, and the campaign page is https://www.splunk.com/en_us/campaigns/state-of-observability.html (now showing 2025).
- Splunk press releases now live on newsroom.cisco.com.

**2024 edition: "State of Observability 2024"**
- Published Oct 22, 2024.
- Press release: https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html
- Sample: Enterprise Strategy Group (ESG), May–June 2024. 1,850 ITOps staff, managers, executives, developers, engineers, architects and SREs at organizations with 500+ employees, in 10 countries and 16 industries.
- OTel: "78% of leaders embracing the open-source standard and 57% experiencing lower observability costs". "72% of leaders embrace OpenTelemetry to access a broader ecosystem…" — [Cisco/Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html). (An overall "58% adopt OTel" figure appears only in secondary summaries; it was not on the press release.)
- "Nearly all survey respondents (97%) use AI and/or ML-powered systems to enhance their observability operations." — [Cisco/Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html)
- "57% of respondents agree the volume of alerts they receive is problematic." — [Cisco/Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html)
- Leaders achieve "a 2.6x annual return" on their investment. — [Cisco/Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html)

**2025 edition (5th annual): "State of Observability 2025: The Rise of a Business Catalyst" (latest)**
- Published Oct 21, 2025.
- Press release: https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html
- Sample: 1,855 ITOps and engineering professionals, surveyed Feb–Mar 2025, in 9 countries and 16 industries. The press release does not name the research partner.
- "76% of respondents regularly use AI-powered observability in their everyday workflows". "47% say monitoring AI workloads has made their job more challenging." — [Cisco/Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
- Top challenges: "too many disparate tools (59%)" and "a high volume of false alerts (52%)". — [Cisco/Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
- Leaders generate "an annual 125% ROI". 74% say observability improves productivity. — [Cisco/Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
- OTel: 47% of OpenTelemetry users "never panic during customer incidents", versus 32% of non-users. — [Cisco/Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
- No 2026 edition had been published as of Oct 7, 2026; the 2024 and 2025 editions both came out in October.

#### 1.4 Dynatrace (annual CIO research) [VENDOR-SPONSORED 3P]

**2024: "The state of observability 2024: Overcoming complexity through AI-driven analytics and automation strategies" (the Global CIO Report)**
- Published Mar 5, 2024.
- Report (gated): https://www.dynatrace.com/info/reports/state-of-observability-2024/
- Press release: https://www.dynatrace.com/news/press-release/annual-global-cio-report-reveals-cloud-native-technologies-produce-explosion-of-data-beyond-humans-ability-to-manage/
- Sample: Coleman Parkes; 1,300 CIOs and technology leaders at companies with 1,000+ employees (US 200, LatAm 100, Europe 600, Middle East 150, APAC 250).
- Organizations use an average of 10 monitoring/observability tools, and the average multicloud environment spans 12 platforms and services. — [Dynatrace PR 2024](https://www.dynatrace.com/news/press-release/annual-global-cio-report-reveals-cloud-native-technologies-produce-explosion-of-data-beyond-humans-ability-to-manage/)
- 86% say cloud-native stacks produce "an explosion of data that is beyond humans' ability to manage". 88% say complexity rose in the past 12 months. — [Dynatrace PR 2024](https://www.dynatrace.com/news/press-release/annual-global-cio-report-reveals-cloud-native-technologies-produce-explosion-of-data-beyond-humans-ability-to-manage/)
- 97% say traditional AIOps can't handle the data overload; 72% have adopted AIOps. 81% say manual log management can't keep up. — [Dynatrace PR 2024](https://www.dynatrace.com/news/press-release/annual-global-cio-report-reveals-cloud-native-technologies-produce-explosion-of-data-beyond-humans-ability-to-manage/)

**2025: "The State of Observability 2025: Why observability is becoming the control plane for AI-powered enterprise transformation"**
- Published Oct 7, 2025.
- Report (gated): https://www.dynatrace.com/info/ebooks/the-state-of-observability/
- Press release: https://www.dynatrace.com/news/press-release/state-of-observability-2025/
- Sample: Qualtrics; 842 CIOs, CTOs and senior IT leaders at enterprises with ≥$100M revenue (US 206, Germany 125, France 129, Spain 130, Italy 128, Japan 124).
- "100% of business leaders surveyed are using AI as part of their operations today." — [Dynatrace PR 2025](https://www.dynatrace.com/news/press-release/state-of-observability-2025/)
- "More than two-thirds (69%) of AI-powered decisions still include human-in-the-loop processes to verify accuracy." — [Dynatrace PR 2025](https://www.dynatrace.com/news/press-release/state-of-observability-2025/)
- 70% say observability budgets increased in the past year, and 75% expect increases next fiscal year. — [Dynatrace PR 2025](https://www.dynatrace.com/news/press-release/state-of-observability-2025/)

**2026: "The Pulse of Agentic AI 2026: Balancing innovation with control from pilot to production"**
- Published Jan 22, 2026. This is adjacent research; no "State of Observability 2026" was found.
- Press release: https://dynatrace.com/news/press-release/pulse-of-agentic-ai-2026 (the report is gated).
- Sample: Y2 Analytics; 919 senior leaders, surveyed Nov–Dec 2025.
- About 50% of agentic AI projects are still at proof-of-concept or pilot stage. "69% of agentic AI–powered decisions are still verified by humans" (the same 69% as the 2025 report, on a different population). — [Dynatrace PR 2026](https://dynatrace.com/news/press-release/pulse-of-agentic-ai-2026)
- Observability is used during agent implementation by 69%, operationalization by 57% and development by 54%. 74% expect budgets to rise. — [Dynatrace PR 2026](https://dynatrace.com/news/press-release/pulse-of-agentic-ai-2026)

#### 1.5 Elastic "Landscape of Observability" series [VENDOR-SPONSORED 3P; fieldwork by Dimensional Research]

**2024: "The 2024 Observability Landscape: A Survey of Observability Decision Makers"**
- Survey fielded January 2024; publication month not confirmed.
- PDF (open): https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf
- Sample: 510 respondents at companies with more than 500 employees.
- "78% are considering OpenTelemetry, although only 9% have moved to production". "87% agree OpenTelemetry will be the standard… within the next five years." — [Elastic/Dimensional 2024 PDF](https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf)
- "On average, companies have more than seven different observability and monitoring tools"; 74% are working to consolidate. — [Elastic 2024 PDF](https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf)
- 96% expect AI to have an impact within five years, and 97% have concerns about generative AI. — [Elastic 2024 PDF](https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf)
- "60% with mature observability practices have reduced MTTR"; only 14% describe themselves as mature. — [Elastic 2024 PDF](https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf)

**2025: "Landscape of Observability in 2025: Futureproofing IT"**
- Blog summary dated Feb 27, 2025: https://www.elastic.co/observability-labs/blog/emerging-trends-in-observability-2025
- The PDF was found only as a third-party copy: https://www.intelligentcio.com/wp-content/uploads/sites/5/2025/07/dimensional-research-landscape-of-observability-in-2025-WP.pdf
- Sample: 509 respondents.
- "91% of observability 'experts' are evaluating or implementing OTel compared to 54% of 'early-stage'." — [Elastic 2025 PDF (third-party copy)](https://www.intelligentcio.com/wp-content/uploads/sites/5/2025/07/dimensional-research-landscape-of-observability-in-2025-WP.pdf)
- 79% are consolidating tools (up from 74%), and 97% are taking active steps to manage costs. — [Elastic 2025 PDF](https://www.intelligentcio.com/wp-content/uploads/sites/5/2025/07/dimensional-research-landscape-of-observability-in-2025-WP.pdf)
- 71% of experts report reduced MTTR, versus 40% of early-stage organizations. GenAI reliability concerns fell from 64% to 55%. — [Elastic 2025 PDF](https://www.intelligentcio.com/wp-content/uploads/sites/5/2025/07/dimensional-research-landscape-of-observability-in-2025-WP.pdf)

**2026: "The Landscape of Observability in 2026: Balancing cost and innovation" (latest)**
- Blog dated Feb 4, 2026: https://www.elastic.co/blog/2026-observability-trends-generative-ai-opentelemetry
- Landing page (form): https://www.elastic.co/lp/observability-landscape-survey-report
- The PDF is also directly reachable: https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf
- Industry cuts exist for the public sector and financial services.
- Sample: 526 IT decision makers at companies with more than 500 employees.
- **OTel in production rose from 6% (2025) to 11% (2026)**, and experimenting rose from 31% to 36%. Vendor-sourced OTel distributions rose from 44% to 60%. — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- "67% regularly experience unexpected costs or overages" (97% ever have). 96% are cutting costs, and consolidating toolsets is the top method (51%). — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- "85% currently use GenAI for observability… projected to grow to 98% within two years"; 23% use agentic AI today. — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- LLM observability: 85% plan it, but only 8% have completed implementation. — [Elastic 2026 blog](https://www.elastic.co/blog/2026-observability-trends-generative-ai-opentelemetry)
- Inconsistency: the 2024 report gave 9% with OTel in production, while the 2026 report puts 2025 at 6%. The samples and wording differ, so the series is not strictly comparable.

#### 1.6 Honeycomb [VENDOR]
- Honeycomb published no survey of its own in 2024–2026. Its press-release index (Sept 2024 – Sept 29, 2026) lists no survey or study. — [Honeycomb press releases](https://www.honeycomb.io/news/press-releases)
- It co-branded two gated DZone reports, neither of which publishes a sample size or statistics on its landing page:
  - "2024 DZone + Honeycomb Observability and Performance Trend Report": [landing page](https://www.honeycomb.io/resources/whitepapers/2024-dzone-observability-performance-trend-report)
  - "DZone + Honeycomb 2025 Intelligent Observability Trend Report": [landing page](https://www.honeycomb.io/resources/whitepapers/dzone-honeycomb-2025-intelligent-observability-trend-report)

#### 1.7 Chronosphere [VENDOR]
**"The State of Log Data: 6 Trends Impacting Observability and Security"**
- Published Oct 15, 2024, as an open blog post: https://chronosphere.io/learn/observability-log-data-trends/
- Sample: 127 people familiar with their organization's logging strategy; 83% work at companies with 500+ employees.
- Log data grew 250% year over year on average. 22% generate 1TB+ of logs per day, and 12% generate 10TB+. — [Chronosphere](https://chronosphere.io/learn/observability-log-data-trends/)
- 38% struggle to get insights from logs. Fluent Bit is the most common open-source agent (22%). — [Chronosphere](https://chronosphere.io/learn/observability-log-data-trends/)
- No 2025 or 2026 Chronosphere survey was found. Chronosphere has since been acquired by Palo Alto Networks, which now markets it as "Cortex XCOR". — [Palo Alto Networks](https://www.paloaltonetworks.com/resources/research/gartner-critical-capabilities-observability)
- Attribution caution: SiliconANGLE (Feb 5, 2026) says "more than half of enterprises now rely on 11 to 20 observability tools", but the figure comes from theCUBE Research, not from a Chronosphere survey. — [SiliconANGLE](https://siliconangle.com/2026/02/05/observability-cost-ai-scale-chronosphere-opensourcesummit/)

#### 1.8 Datadog "State of" reports [TELEMETRY; all open, no form]
- None of the Datadog reports fetched gives an OpenTelemetry adoption percentage.

**State of Cloud Costs 2024**
- Published Jun 13, 2024: https://www.datadoghq.com/state-of-cloud-costs/
- Press release: https://www.datadoghq.com/about/latest-news/press-releases/datadogs-state-of-cloud-costs-2024-report-finds-spending-on-gpu-instances-growing-40-as-organizations-experiment-with-ai/
- Data: AWS cost data from hundreds of organizations, May 2023 – Apr 2024.
- GPU-instance spend grew 40% among GPU-using organizations, from 10% to 14% of EC2 compute cost. — [Datadog PR](https://www.datadoghq.com/about/latest-news/press-releases/datadogs-state-of-cloud-costs-2024-report-finds-spending-on-gpu-instances-growing-40-as-organizations-experiment-with-ai/)
- "83 percent of container costs are associated with idle resources." — [Datadog PR](https://www.datadoghq.com/about/latest-news/press-releases/datadogs-state-of-cloud-costs-2024-report-finds-spending-on-gpu-instances-growing-40-as-organizations-experiment-with-ai/)
- No 2025 edition was found; the page still shows 2024.

**State of Containers and Serverless 2025**
- Blog dated Nov 6, 2025: https://www.datadoghq.com/blog/containers-and-serverless-2025-study-learnings/
- Report: https://www.datadoghq.com/state-of-containers-and-serverless/
- Data: tens of thousands of Datadog customers.
- Organizations using GPUs rose from about 4.5% to just over 6% (Oct 2023 – Oct 2025). AI is 7% of container workloads. — [Datadog](https://www.datadoghq.com/state-of-containers-and-serverless/)
- Most workloads use under 50% of requested memory and under 25% of requested CPU. Over 64% of Kubernetes organizations use HPA. — [Datadog](https://www.datadoghq.com/state-of-containers-and-serverless/)

**State of AI Engineering 2026**
- Press release Apr 21, 2026: https://www.datadoghq.com/about/latest-news/press-releases/datadog-state-of-ai-engineering-report-2026/
- Report: https://www.datadoghq.com/state-of-ai-engineering/
- Data: LLM telemetry from 1,000+ organizations.
- About 5% of AI model requests fail in production, and nearly 60% of those failures come from capacity limits. — [Datadog](https://www.datadoghq.com/state-of-ai-engineering/)
- Multi-model use: 69% use 3+ models per the press release, while the report page says "over 70%". Agent-framework adoption doubled from 9% to 18%. — [Datadog PR](https://www.datadoghq.com/about/latest-news/press-releases/datadog-state-of-ai-engineering-report-2026/); [report](https://www.datadoghq.com/state-of-ai-engineering/)
- 69% of input tokens are system prompts, but only 28% of LLM calls use prompt caching. — [Datadog](https://www.datadoghq.com/state-of-ai-engineering/)

Also published, but less relevant here: State of Cloud Security 2025 ([link](https://www.datadoghq.com/state-of-cloud-security/)) and State of DevSecOps 2026 ([PR](https://www.datadoghq.com/about/latest-news/press-releases/datadog-state-of-devsecops-report-2026), snippet only).

#### 1.9 LogicMonitor [VENDOR]

**"2026 Observability & AI Outlook for IT Leaders"**
- Copyright 2025; released late 2025.
- Landing page: https://www.logicmonitor.com/resources/2026-observability-ai-outlook-for-it (returned 403, so gating could not be checked).
- Full PDF on a distributor portal: https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf
- Sample: 100 VP+ IT decision-makers with observability budget authority, surveyed mid-2025. No research firm is named, and the sample is small.
- 84% are pursuing or considering tool consolidation (41% actively). 66% run 2–3 platforms, and only 10% use a single platform. — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)
- 67% are likely to switch platforms within 1–2 years, and only 41% are satisfied with their platform's insights. — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)
- AI maturity: 4% fully operational, 49% piloting, 22% not adopted. — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)
- 96% expect observability spending to hold or grow over the next 12–24 months. — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)

**EMEA research, Mar 26, 2026 (secondary coverage only)**
- Sample: 400 senior IT leaders in the UK, France, Benelux and DACH.
- 97% of UK leaders would consider consolidating to one platform. The average is 3 tools, and 46% say cost is the biggest challenge. — [SecurityBrief UK](https://securitybrief.co.uk/story/uk-it-leaders-eye-observability-platform-consolidation)

#### 1.10 SolarWinds [VENDOR-SPONSORED 3P; UserEvidence for the 2025 and 2026 reports]

**"2026 State of Monitoring and Observability Report" (most observability-specific)**
- Published Mar 10–11, 2026.
- Report (gated): https://www.solarwinds.com/resources/report/state-of-monitoring-and-observability
- Press release: https://solarwinds.com/company/newsroom/press-releases/state-of-monitoring-observability-2026
- Sample: 750+ IT professionals across North America, Europe, LatAm, APAC and MEA; fielded Nov 19 – Dec 19, 2025.
- 77% have limited visibility across on-premises and cloud. 75% say poor cross-team coordination hinders observability. — [SolarWinds PR 2026](https://solarwinds.com/company/newsroom/press-releases/state-of-monitoring-observability-2026)
- 55% say they use too many monitoring tools. — [SolarWinds PR 2026](https://solarwinds.com/company/newsroom/press-releases/state-of-monitoring-observability-2026)
- 90% are confident AI can improve monitoring and observability. Planned AI uses: incident prioritization 47%; RCA, capacity prediction and alert-noise reduction 45% each. — [SolarWinds PR 2026](https://solarwinds.com/company/newsroom/press-releases/state-of-monitoring-observability-2026)

**"2025 IT Trends Report: Fragile to Agile"**
- Published Jul 29, 2025.
- Report (gated): https://www.solarwinds.com/resources/report/it-trends-report-2025
- Press release: https://www.solarwinds.com/company/newsroom/press-releases/it-trends-report-2025
- Sample: 600+ IT leaders in 9 countries.
- Outage impact: customer experience 71%, revenue loss 32%, brand damage 28%. 53% say inefficient workflows slow their response to issues. — [SolarWinds PR 2025](https://www.solarwinds.com/company/newsroom/press-releases/it-trends-report-2025)

**"2024 IT Trends Report: AI: Friend or Foe?"**
- Published Jun 12, 2024.
- Press release: https://www.solarwinds.com/company/newsroom/press-releases/new-solarwinds-report-it-pros-want-ai-but-fear-shortcomings-in-data-quality-privacy-security
- Sample: nearly 700 IT professionals.
- 9 in 10 use or plan to use AI, but only 38% trust their data quality. — [SolarWinds PR 2024](https://www.solarwinds.com/company/newsroom/press-releases/new-solarwinds-report-it-pros-want-ai-but-fear-shortcomings-in-data-quality-privacy-security)

**"2025 State of Database Report"**
- Published Nov 4, 2025.
- Report (gated): https://www.solarwinds.com/resources/report/state-of-database-2025
- 75% of DBAs are affected by alert fatigue. — [iTWire coverage](https://itwire.com/guest-articles/guest-research/survey-finds-one-in-three-dbas-eye-career-move-as-demands-on-role-increase.html)

#### 1.11 PagerDuty [VENDOR-SPONSORED 3P; Censuswide and Wakefield Research]

**"Cost of Incidents" survey (main source for per-minute downtime cost)**
- Published Jun 27, 2024.
- Landing page with an open PDF: https://www.pagerduty.com/resources/learn/cost-of-downtime/
- Press release: https://pagerduty.com/newsroom/study-cost-of-incidents
- Sample: Censuswide; 500 IT leaders at companies with 1,000+ employees in the US, UK and Australia; May 31 – Jun 6, 2024.
- Downtime costs "$4,537 per minute". Average resolution takes 175 minutes, or about $794K per incident. — [PagerDuty](https://pagerduty.com/newsroom/study-cost-of-incidents)
- About 25 high-priority incidents a year, or about $19.8M per organization per year. 59% say customer-impacting incidents increased, by an average of 43%. — [PagerDuty](https://pagerduty.com/newsroom/study-cost-of-incidents)

**"2024 State of Digital Operations"**
- Published Feb 7, 2024: https://www.pagerduty.com/blog/news-announcements/2024-state-of-digital-operations/
- Enterprise incidents rose 16% year over year; this comes from platform data plus 300+ surveyed leaders. — [PagerDuty blog](https://www.pagerduty.com/blog/news-announcements/2024-state-of-digital-operations/)

**"2025 State of Digital Operations" (4th edition)**
- Published Jan 22, 2025: https://www.pagerduty.com/newsroom/2025-state-of-digital-operations-study/
- Sample: 1,100+ operations leaders across NA, EMEA and APJ.
- 64% expect IT operations budgets to rise. — [PagerDuty](https://www.pagerduty.com/newsroom/2025-state-of-digital-operations-study/)

**AI resilience survey**
- Published Sep 23, 2025: https://www.pagerduty.com/newsroom/ai-resilience-survey-2025/
- Sample: Wakefield Research, 1,500 executives.
- 84% have had at least one AI-related outage, and 85% need better procedures to detect AI errors. — [PagerDuty](https://www.pagerduty.com/newsroom/ai-resilience-survey-2025/)

**"2026 State of AI-First Operations" (latest)**
- Published Mar 17, 2026.
- Press release: https://www.pagerduty.com/newsroom/2026-state-of-ai-first-operations/
- Report (gated): https://www.pagerduty.com/state-of-digital-ops/
- Sample: Wakefield Research, 1,000 director+ respondents across 7 regions.
- Per-hour losses during IT incidents: 8% lose more than $1M, 34% at least $500K, 68% more than $300K. — [PagerDuty PR 2026](https://www.pagerduty.com/newsroom/2026-state-of-ai-first-operations/)
- 59% use AI in operations. 75% of AI adopters improved resilience, versus 66% of non-adopters. — [PagerDuty PR 2026](https://www.pagerduty.com/newsroom/2026-state-of-ai-first-operations/)

#### 1.12 Logz.io "Observability Pulse 2024" [VENDOR]
- Released Mar 19, 2024, at KubeCon EU.
- Report (open): https://logz.io/observability-pulse-2024/
- Press release: https://logz.io/news-posts/observability-pulse-2024-release/
- Sample: 500 (press release) or 501 (report); fielded late 2023 – Jan 2024.
- No 2025 or 2026 edition exists; logz.io/observability-pulse-2025/ returns 404.
- Only 10% have full observability. 82% report MTTR over 1 hour, up from 74% (2023), 64% (2022) and 47% (2021). — [Logz.io](https://logz.io/observability-pulse-2024/)
- 76% say OTel is "at least somewhat important". Top tools: Grafana 39%, Prometheus 33%. — [Logz.io](https://logz.io/observability-pulse-2024/)
- 21% use a single tool, up from 16%. 91% use at least one method to cut observability spend. — [Logz.io](https://logz.io/observability-pulse-2024/)

### Inferences
- **OpenTelemetry "adoption" figures depend on how the question is asked.** The same period yields very different numbers:
  - "Invested in": 76–85% (Grafana)
  - "Standardized, migrating or testing": 73% (New Relic 2026)
  - "In production in some capacity": 41% (Grafana 2025)
  - "Across all production workloads": 10.3% (Grafana 2026)
  - "In production": 11% (Elastic 2026)

  A headline OTel percentage should always carry its definition.
- **Outage-cost figures are not comparable across vendors.** New Relic gives a median or mean cost per hour of high-impact outages ($1.9M in 2024, $2M in 2025, $1.85M in 2026). PagerDuty's $4,537 per minute (about $272K per hour) uses a different population and definition. Both are vendor-sponsored and favor the case for buying observability.
- **Tool consolidation is the stated intent everywhere, but outcomes are mixed.**
  - Grafana's average fell from 9 to 8 technologies (2024→2025).
  - New Relic's fell to 4.4 in 2025, then rose back to 5.0 in 2026.
  - Dynatrace's CIO sample averaged 10 tools in 2024.
  - Absolute counts differ by population: practitioners count more "technologies" than CIOs count "tools".
- **AI in observability is now universal in vendor surveys**: 97% (Splunk 2024), 100% (Dynatrace 2025), 85% (Elastic 2026), 76% using it regularly (Splunk 2025). Deeper maturity is low: 4% fully operational AI (LogicMonitor), 8% with LLM observability completed (Elastic 2026), and 25% with agents in production unmonitored (New Relic 2026).

### Gaps
- No vendor in this cluster publishes a profiling-adoption percentage; the only profiling number found comes from CNCF (see Q2).
- Splunk 2026 had not been published as of this date, and no Dynatrace "State of Observability 2026" was found (only the Agentic AI pulse).
- Datadog does not publish an OTel-usage percentage in its "State of" reports. A snippet claiming "OTel usage up 55% YoY" could not be verified and was excluded.
- Middleware 2026 (407 respondents), Imply's "Breaking Point for Observability Leaders" (Dec 2025) and an Edge Delta/Wakefield cost survey (200 respondents; "98% had cost overages") appeared in search snippets only. They were not verified and are not included.
- The New Relic 2026 PDF was too large to fetch, so the 2026 stats come from the press release and landing page.
- Cisco/AppDynamics App Attention Index: no 2024–2026 edition found. Observe, Coralogix, Sumo Logic, ScienceLogic, Riverbed, BigPanda, Kentik and IBM Instana: no major survey found in quick searches (not exhaustive).

---

## Q2. What do neutral / community sources say?

### Takeaway
Neutral sources show OpenTelemetry moving from "evaluating" to mainstream:
- CNCF annual survey: OTel production use rose from 39% (2024 survey) to 49% (2025 survey), while Prometheus held at 73–77% in production.
- OTel is consistently CNCF's #2 project by velocity.
- OTel graduated from CNCF on May 21, 2026.
- Profiling entered public alpha as the fourth OTel signal in March 2026, with about 20% of CNCF respondents already using profiling.
- There is no dedicated Linux Foundation Research observability report in 2024–2026.
- EMA's observability research is multi-vendor sponsored.

### Cited Findings

#### 2.1 CNCF Annual Survey [NEUTRAL; CNCF with Linux Foundation Research; all open, no form]

**"Cloud Native 2023: The Undisputed Infrastructure of Global Technology" (2023 survey)**
- Published around March–April 2024: https://www.cncf.io/reports/cncf-annual-survey-2023/ (HTML report).
- Sample: web survey Aug–Dec 2023; 988 usable records out of 3,735 starts.
- Kubernetes is used in production by 66%, and 84% use or evaluate it. — [CNCF 2023](https://www.cncf.io/reports/cncf-annual-survey-2023/)
- Observability is described only narratively: "Monitoring and observability are fast becoming more challenging… projects like Prometheus and Open Telemetry were more widely adopted in 2023." Per-project percentages are only in chart images and could not be extracted. — [CNCF 2023](https://www.cncf.io/reports/cncf-annual-survey-2023/)

**"Cloud Native 2024: Approaching a Decade of Code, Cloud, and Change" (2024 survey)**
- Published Apr 1, 2025: https://www.cncf.io/reports/cncf-annual-survey-2024/
- PDF (open): https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf
- Sample: 750 respondents, Nov–Dec 2024; the project questions had n=689.
- **Prometheus: 73% in production and 12% evaluating.** Fluentd is at 39% in production, and **Jaeger at 14% in production and 17% evaluating**. — [CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf)
- **OpenTelemetry was the #1 incubating project, at 39% in production and 23% evaluating.** — [CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf)
- Container challenges (2024 vs 2023): monitoring 36% vs 37%, and logging 22% vs 17%. Cultural change is now the top challenge (46%). — [CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf)
- Kubernetes production use "hit 80% in 2024, up from 66% in 2023". — [CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf)

**"The CNCF Annual Cloud Native Survey: The Infrastructure of AI's Future" (2025 survey, latest)**
- Published Jan 20, 2026: https://www.cncf.io/reports/the-cncf-annual-cloud-native-survey/
- PDF (open): https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf
- Press release: https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/
- Sample: 628 respondents, September 2025; margin of error ±3.3% at 90% confidence.
- **Prometheus: "77% production use with 12% evaluating."** — [CNCF 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf)
- **OpenTelemetry: "49% production use with 26% evaluating"**, up from 39%/23% in the 2024 survey. — [CNCF 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf)
- **Profiling: "Nearly 20% of respondents now report using profiling as part of their observability stack."** — [CNCF PR Jan 20, 2026](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/)
- "82% of container users now run Kubernetes in production." "66% of organizations hosting generative AI models use Kubernetes to manage some or all of their inference workloads." — [CNCF PR](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/)
- The press release calls OTel "the second-highest-velocity CNCF project, with more than 24,000 contributors". This contributor count does not match other CNCF figures (see 2.2). — [CNCF PR](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/)

#### 2.2 CNCF project velocity, annual reports and OTel graduation [NEUTRAL]
- **2024 velocity:** OTel "remains the second highest velocity project". — [CNCF blog, Jan 29, 2025](https://www.cncf.io/blog/2025/01/29/2024-year-in-review)
- **Mid-2025:** OTel "remains the second highest velocity project in CNCF". — [CNCF blog, Jul 18, 2025](https://cncf.io/blog/2025/07/18/a-mid-year-2025-look-at-cncf-linux-foundation-and-the-top-30-open-source-projects)
- **Full-year 2025:** "OpenTelemetry is picking up serious momentum, with a 39% rise in commits and a contributor base that grew from 1,301 to 1,756 in just one year; that's a 35% increase." — [CNCF blog, Feb 9, 2026](https://www.cncf.io/blog/2026/02/09/what-cncf-project-velocity-in-2025-reveals-about-cloud-natives-future/)
- **CNCF Annual Report 2025** (PDF dated Mar 2026) repeats the velocity text and reports 1,420 OTel Certified Associate exam registrations since the exam launched in Nov 2024. — [CNCF AR 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/03/cncf_ar25_033126a.pdf)
- **OTel graduated from CNCF on May 21, 2026**, announced at Observability Summit in Minneapolis. — [CNCF announcement](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)
  - "Over 12,000 contributors from over 2,800 companies" since 2019.
  - "Second-highest project velocity among over 240 projects… second only to Kubernetes."
  - The JS API package has been downloaded more than 1.36B times and the Python API package more than 1.3B times.
  - The OTel project's own post: [OTel blog](https://opentelemetry.io/blog/2026/otel-graduates/)
- **The contributor counts measure different things:**
  - 1,756 is annual authors in 2025 (velocity data).
  - 12,000+ is cumulative contributors (graduation announcement).
  - 24,000+ comes from the survey press release and is unexplained.
  - Always state which one is meant.

#### 2.3 OpenTelemetry signals: profiling and eBPF (project milestones, not surveys)
- **Profiles entered public alpha in March 2026**, making profiling the fourth signal alongside traces, metrics and logs.
  - "With OpenTelemetry Profiles, we're introducing an industry-wide standard for production profiling, with true vendor neutrality."
  - It requires Collector v0.148.0 or newer. Components include the eBPF profiler donated by Elastic, a pprof receiver and k8sattributes support. — [OTel blog: Profiles enters public alpha](https://opentelemetry.io/blog/2026/profiles-alpha/); also [Elastic](https://www.elastic.co/observability-labs/blog/otel-profiling-alpha) and [Polar Signals, Mar 26, 2026](https://www.polarsignals.com/blog/posts/2026/03/26/opentelemetry-profiling-goes-alpha)
- The CNCF Annual Report 2024 already noted that OTel "recently added profiling as a new signal type". — [CNCF AR 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/CNCF-Annual-Report-2024_v2.pdf)
- **eBPF instrumentation:** Grafana Labs donated Beyla to OpenTelemetry in 2025 (announced at GrafanaCON 2025) as "OpenTelemetry eBPF Instrumentation" (OBI). — [Grafana blog](https://grafana.com/blog/2025/05/07/opentelemetry-ebpf-instrumentation-beyla-donation/)

#### 2.4 Linux Foundation Research [NEUTRAL]
- **No dedicated LF Research observability or OpenTelemetry report exists for 2024–2026.** All 119 report entries at linuxfoundation.org/research were checked; the only relevant ones are the CNCF annual surveys above. — [LF Research](https://www.linuxfoundation.org/research)
- The last CNCF/TAG Observability microsurvey was published Mar 8, 2022, with 186 responses. It is outside the window. — [CNCF blog 2022](https://www.cncf.io/blog/2022/03/08/cloud-native-observability-microsurvey-prometheus-leads-the-way-but-hurdles-remain-to-understanding-the-health-of-systems/)

#### 2.5 EMA (Enterprise Management Associates) [VENDOR-SPONSORED 3P; multi-sponsor analyst research]

**"Taking Observability to the Next Level: OpenTelemetry's Emerging Role in IT Performance and Reliability"**
- Published March 2025, by Dan Twing (EMA) and Pete Goldin (APMdigest).
- Sample: 400 IT professionals, global.
- Sponsors: Apica, Beta Systems, Dynatrace, Elastic, Embrace and SolarWinds.
- Open PDFs hosted by sponsors: [Elastic copy](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf), [Apica copy](https://www.apica.io/wp-content/uploads/dae-uploads/EMA7260-Otel-RR-Apica.pdf)
- EMA press release: https://www.enterprisemanagement.com/press_release/ema-webinar-to-explore-opentelemetrys-growing-role-in-observability-and-it-performance/
- **48.5% use OTel today**, and about another quarter plan to. 68.3% are moderately or very familiar with OTel. — [EMA PDF (Elastic copy)](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf)
- Half consider OTel mature enough to implement today, and 98.7% support the project's direction. — [EMA PDF](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf)
- More than 46% of users see over 20% ROI. Among organizations that reduced costs with OTel, 42% cut costs by more than 20%. Some coverage misreads this as "42% saw cost decrease". — [EMA PDF](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf)

**"Network Observability: Managing Performance Across Hybrid Networks"**
- Published Feb 4, 2025, by Shamus McGillicuddy.
- Sample: 351 IT decision-makers.
- Sponsors: Broadcom, BlueCat, Juniper, NETSCOUT and Park Place. The report is EMA paid/gated.
- 87% use multiple network observability tools, and only 43% are completely successful with their current tools. — [Syndicated EMA PR](https://smb.campbellrivermirror.com/article/EMA-Releases-New-Research-Report-on-Network-Observability-Trends-and-Requirements/67a212820feb870d1b50b0b5)

**"The Reality of Observability Unification in Modern IT Operations" (latest)**
- Published Sep 15, 2026.
- Sample: 356 enterprise IT professionals.
- Sponsors: BlueCat, Dynatrace, Entuity/Park Place, NETSCOUT and SolarWinds. The report is gated.
- **75% use 4–12 observability tools**, and 55% switch tools 3–5 times per incident. AI transformation is the #1 driver of unification. — [EMA PR](https://www.enterprisemanagement.com/press_release/new-ema-research-finds-observability-unification-remains-a-challenge-for-most-enterprises/)

#### 2.6 OpenTelemetry community surveys [NEUTRAL-ish]
These are self-selected samples run by OTel SIGs; several authors work at vendors. All are open on opentelemetry.io.

| Survey | Date and author | n | Key stats |
|---|---|---|---|
| [Collector Survey](https://opentelemetry.io/blog/2024/otel-collector-survey/) | May 8, 2024 | 186 | 53.8% run more than 10 collectors. 80.6% deploy on Kubernetes. Gateway mode 64.5%. |
| [Getting Started](https://opentelemetry.io/blog/2024/otel-get-started-survey/) | Jun 19, 2024 | 104 | 67.3% want comprehensive docs; 65.3% want reference implementations. |
| [Prometheus Compatibility](https://opentelemetry.io/blog/2024/prometheus-compatibility-survey/) | Jul 25, 2024 | 86 | 60% prefer keeping dots in metric names. |
| [Docs Usability](https://opentelemetry.io/blog/2024/otel-docs-survey/) | Dec 18, 2024 | 48 | 79% use OTel in production. |
| [Developer Experience](https://opentelemetry.io/blog/2025/devex-survey/) | Apr 2, 2025 | 218 | 83% use OTel in production; 77.4% are not vendor employees. Pain points: docs, examples, local debugging, SDK configuration. |
| [Mainframe](https://opentelemetry.io/blog/2025/mainframe-survey/) | Oct 10, 2025 | 45 | 22 of 45 respondents are in financial services. |
| [Collector Follow-up](https://opentelemetry.io/blog/2026/otel-collector-follow-up-survey-analysis/) | Jan 28, 2026 | about 120 (inferred) | 65% run more than 10 collectors. VMs rose from 33% to 51%. 46% build a custom collector, but only 39% find the Collector Builder easy. |
| [Prometheus–OTel Interoperability](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/) | Sep 22, 2026 | 186 (81 qualified, vendor employees excluded) | Ease rating rose from 3.1 to 3.6/5. "Hard to use together" fell from 29% to 10%. Infrastructure: Prometheus exporters 72%, OTel receivers 57%, about 49% use both. Apps: OTel SDKs 65%. |

#### 2.7 Other neutral sources
- **Stack Overflow Developer Survey 2025**, "platforms and tools" question, n=24,473: Prometheus 11.8%, Datadog 8.9%, Splunk 4.5%, New Relic 3.8%. OpenTelemetry is not listed. Among AI-agent developers (n=2,689), "Grafana + Prometheus" is the most used agent-observability tool (43%). The 2024 survey had no monitoring-tool question. — [Stack Overflow 2025 Technology](https://survey.stackoverflow.co/2025/technology)
- **DORA 2025, "State of AI-assisted Software Development"** (Google Cloud): no observability-specific statistics could be extracted. — [DORA 2025](https://cloud.google.com/resources/content/2025-dora-ai-assisted-software-development-report)

### Inferences
- **The neutral CNCF data broadly corroborates the vendor narrative, at lower and more conservative levels.** OTel production use was 39% in 2024 and 49% in 2025 among cloud-native respondents. That sits between Grafana 2025's 41% "in some capacity" and Elastic's 11% "in production". Prometheus remains the more entrenched project (73–77% in production) but is roughly flat; OTel is the one climbing.
- **Graduation (May 2026) together with the 2026 Gartner commentary marks OTel's transition from emerging to baseline.** Gartner via Network World: "Many enterprise buyers now consider OpenTelemetry support a baseline requirement rather than a differentiator." See Q3.
- **The community surveys point to OTel's remaining friction points**: documentation, SDK configuration, the Collector Builder and Prometheus naming interop. The 2026 interop survey shows the last of these improving.

### Gaps
- CNCF 2023 per-project OTel and Prometheus percentages, CNCF 2025 Jaeger figures, and the 2025 monitoring-challenge percentage exist only as chart images and could not be extracted.
- There is no general OTel "end-user adoption" survey from the OTel project itself for 2024–2026.
- No independent (non-vendor) survey with a large sample measures observability cost or tool counts. EMA is sponsored, and CNCF does not ask about cost.

---

## Q3. What do analyst firms say?

### Takeaway
- **Gartner MQ for Observability Platforms, Leaders by year:**
  - 2024: 7 Leaders out of 17 vendors.
  - 2025: 8 Leaders out of 20 vendors.
  - 2026: 8 Leaders out of 19 vendors. Coralogix entered the Leaders quadrant, and Splunk dropped to Challenger.
- **Gartner's public predictions:**
  - The observability market reaches $14.3B by 2028.
  - 40% of log telemetry goes through telemetry pipelines by 2027.
  - 40% of AI-deploying organizations use dedicated AI observability tools by 2028.
- **Other analysts:**
  - Forrester's only relevant Wave is AIOps Platforms (Q2 2025).
  - IDC published an inaugural Observability MarketScape in November 2025.
  - GigaOm runs Cloud Observability and Kubernetes Observability Radars.

### Cited Findings

#### 3.1 Gartner Magic Quadrant for Observability Platforms [ANALYST; gartner.com is paywalled, vendor reprints require forms]

**2024 edition**
- Published Aug 12, 2024.
- Analysts: Gregg Siegfried, Padraig Byrne, Mrudula Bangera and Matt Crossley.
- Vendors evaluated: 17.
- Source: [Dynatrace PR, Aug 14, 2024](https://www.dynatrace.com/news/press-release/2024-gartner-magic-quadrant-for-observability-platforms/)
- Inclusion criteria [Chronosphere](https://chronosphere.io/learn/2024-gartner-magic-quadrant-observability/):
  - SaaS delivery.
  - At least 50 paying production customers in at least 2 regions.
  - Either $75M revenue, or at least $10M with at least 25% growth.
- **Leaders (7): Chronosphere, Datadog, Dynatrace, Elastic, Grafana Labs, New Relic, Splunk.**
  - Cross-checked via trade press (snippet) and vendor releases: [Datadog](https://www.datadoghq.com/about/latest-news/press-releases/datadog-named-a-leader-in-the-2024-gartner-magic-quadrant-for-observability-platforms/), [New Relic](https://newrelic.com/de/press-release/20240814-0), [Grafana](https://grafana.com/press/2024/08/21/grafana-labs-soars-past-250m-arr-and-5000-customers-completes-270m-primary-and-secondary-transaction-and-named-a-leader-in-the-gartner-magic-quadrant-for-observability-platforms/), [Chronosphere](https://chronosphere.io/news/mq-leader-2024/). These vendor-release links are snippet-confirmed only.
- Dynatrace claimed it was positioned furthest on Completeness of Vision and highest on Ability to Execute (its 14th time as a Leader). — [Dynatrace PR](https://www.dynatrace.com/news/press-release/2024-gartner-magic-quadrant-for-observability-platforms/)
- AWS was a Challenger. — [AWS blog](https://aws.amazon.com/blogs/mt/aws-named-as-a-challenger-in-the-2024-gartner-magic-quadrant-for-observability-platforms)
- LogicMonitor was a Visionary (snippet only). — [LogicMonitor](https://www.logicmonitor.com/press/logicmonitor-recognized-as-a-visionary-in-the-gartner-magic-quadrant-for-observability-platforms-2024)

**2025 edition**
- Report dated Jul 7, 2025; vendor releases came out Jul 10, 2025.
- Analysts: Gregg Siegfried, Matt Crossley, Padraig Byrne, Andre Bridges and Martin Caren.
- Source: [Dynatrace PR](https://www.dynatrace.com/news/press-release/2025-gartner-magic-quadrant-for-observability-platform/); [IBM](https://www.ibm.com/new/announcements/ibm-named-leader-in-2025-gartner-magic-quadrant-for-observability-platforms)
- Vendors evaluated: 20, Gartner's ceiling. Gartner said "complying with the Magic Quadrant ceiling of 20 vendors required difficult inclusion decisions". — [Network World 2025](https://www.networkworld.com/article/4032218/in-crowded-observability-market-gartner-calls-out-ai-capabilities-cost-optimization-devops-integration.html)
- **Leaders (8): Chronosphere, Datadog, Dynatrace, Elastic, Grafana Labs, IBM (Instana), New Relic, Splunk.**
  - The remaining 12 split into 4 Challengers, 4 Visionaries and 4 Niche Players.
  - The 2025 article says Observe was excluded despite having "viable offerings".
  - Source: [Network World 2025](https://www.networkworld.com/article/4032218/in-crowded-observability-market-gartner-calls-out-ai-capabilities-cost-optimization-devops-integration.html)
- Gartner market sizing in the same article: the market "will grow to $14.2 billion by 2028". — [Network World 2025](https://www.networkworld.com/article/4032218/in-crowded-observability-market-gartner-calls-out-ai-capabilities-cost-optimization-devops-integration.html)
- Visionaries: Honeycomb ([Honeycomb blog, Jul 18, 2025](https://www.honeycomb.io/blog/honeycomb-named-visionary-2025-gartner-magic-quadrant-observability-platforms)), plus ScienceLogic and Coralogix (snippet only).
- Niche Players: SolarWinds (snippet only).
- Honorable mentions: Kloudfuse, Dash0, Observe, groundcover. — [Kloudfuse](https://www.kloudfuse.com/blog/inside-the-2025-gartner-magic-quadrant-for-observability-trends-takeaways)

**2026 edition (latest)**
- Report dated Jul 13, 2026.
- Gartner abstract (gated): https://www.gartner.com/en/documents/8114397
- Vendors evaluated: 19.
- Source: [Dynatrace PR, Jul 15, 2026](https://www.dynatrace.com/news/press-release/dynatrace-named-a-leader-in-the-2026-gartner-magic-quadrant-for-observability-platforms-for-the-16th-time/)
- Full placement, from [Network World, Jul 17, 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html) (fetched and confirmed during compilation):
  - **Leaders (8):** Chronosphere, Coralogix, Datadog, Dynatrace, Elastic, Grafana Labs, IBM, New Relic
  - **Challengers (5):** Alibaba Cloud, AWS, LogicMonitor, Microsoft, Splunk
  - **Visionaries (2):** BMC Helix, Honeycomb
  - **Niche Players (4):** Apica, HPE, ScienceLogic, SolarWinds
- Movements since 2025:
  - Splunk dropped from Leader to Challenger.
  - Coralogix moved from Visionary to Leader.
  - ScienceLogic moved from Visionary to Niche Player.
- Grafana says it was positioned furthest on Completeness of Vision for the second year in a row. — [Grafana analyst page](https://grafana.com/analyst-reports/gartner-magic-quadrant-observability-platforms/)
- Gartner commentary quoted by Network World:
  - "Gartner projects the observability market will reach $14.3 billion by 2028."
  - "5% of its clients now spend more than $10 million annually with a single observability provider."
  - "Telemetry cost management remains one of the top concerns for enterprise buyers."
  - "Many enterprise buyers now consider OpenTelemetry support a baseline requirement rather than a differentiator."
  - Buyers want visibility into "token consumption, model latency, response quality, hallucination rates".
  - Source: [Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)
- Analyst lists conflict across vendors:
  - [Datadog (form)](https://www.datadoghq.com/resources/gartner-magic-quadrant-observability-platforms-2026/) and Dynatrace list Byrne, Caren, Cummings and Young.
  - Grafana lists Byrne, Prasad, Caren, Cummings and Bisht.

#### 3.2 Gartner Critical Capabilities for Observability Platforms [ANALYST]
- **2024:** 17 vendors, 5 use cases. Dynatrace ranked #1 in 3 of them (snippet only). — [BusinessWire](https://www.businesswire.com/news/home/20240821229397/en/)
- **2025:** 20 vendors, 6 use cases. Dynatrace ranked #1 in 4: Cost Optimization 4.32, SRE 4.3, Business Insights 4.3, AI Engineering 4.29 (snippet only). — [Nasdaq/PR](https://www.nasdaq.com/press-release/dynatrace-ranked-1-across-four-six-use-cases-2025-gartner-critical-capabilities)
- **2026:** dated Jul 13–16, 2026.
  - Elastic ranked #1 in the Software Engineering, IT Operations and DevOps Engineering use cases. — [Elastic (form)](https://www.elastic.co/resources/observability/analyst-report/gartner-critical-capabilities-observability-platforms)
  - Chronosphere/Cortex XCOR "ranks first for the Observability Cost Control Use Case". — [Palo Alto Networks (form)](https://www.paloaltonetworks.com/resources/research/gartner-critical-capabilities-observability)

#### 3.3 Gartner Hype Cycle, Market Guides and predictions [ANALYST]
- **Hype Cycle for Monitoring and Observability** exists in 2024, 2025 and (likely) 2026 editions; all are gated:
  - 2024: https://www.gartner.com/en/documents/5611691
  - 2025: https://www.gartner.com/en/documents/6755734, dated Jul 22, 2025 (snippet only).
  - Where OTel, AI/LLM observability, telemetry pipelines, eBPF and profiling sit on the curve could **not** be verified from any public source.
- **Market Guide for Telemetry Pipelines** (Sep 2, 2025, analyst Andre Bridges): "By 2027, Gartner projects that 40% of all log telemetry will be processed through a telemetry pipeline product, a substantial increase from less than 20% in 2024." — [Mezmo-hosted guide (form)](https://www.mezmo.com/resources/gartner-market-guide-for-telemetry-pipelines)
- **AI observability prediction** (May 12, 2026, Padraig Byrne): "Forty percent of organizations deploying AI will implement dedicated AI observability tools by 2028 to monitor model performance, bias and outputs." — [TechEdgeAI coverage](https://techedgeai.com/gartner-predicts-40-of-organizations-deploying-ai-will-use-ai-observability-to-monitor-model-performance-by-2028/). Gartner's own release blocks automated fetches: [Gartner newsroom](https://www.gartner.com/en/newsroom/press-releases/2026-05-12-gartner-predicts-40-percent-of-organizations-deploying-ai-will-use-ai-observability-to-monitor-model-performance-by-2028)
- **LLM observability prediction** (Mar 30, 2026): by 2028, explainable AI will drive LLM observability investments to 50% of GenAI deployments, up from 15% today. This rests on snippets and multiple outlets; the primary page was not fetched. — [Gartner newsroom](https://www.gartner.com/en/newsroom/press-releases/2026-03-30-gartner-predicts-by-2028-explainable-ai-will-drive-llm-observability-investments-to-50-percent-for-secure-genai-deployment)
- Gartner publishes a gated research note, "Assessing OpenTelemetry for Enterprise Observability": https://www.gartner.com/en/documents/6524802. No verifiable Gartner "X% will use OTel by 20XX" statistic was found.

#### 3.4 Forrester [ANALYST]
- **"The Forrester Wave: AIOps Platforms, Q2 2025"**: 10 providers, 26 criteria; Dynatrace PR dated Apr 15, 2025. — [Dynatrace PR](https://www.dynatrace.com/news/press-release/forrester-wave-aiops-platforms-q2-2025/)
  - Leaders confirmed by vendors: Dynatrace (highest Current Offering score) per the [Dynatrace PR](https://www.dynatrace.com/news/press-release/forrester-wave-aiops-platforms-q2-2025/); Datadog per its [blog](https://datadoghq.com/blog/datadog-aiops-platforms-forrester-wave-2025); and ScienceLogic (highest Strategy score) per its [page](https://sciencelogic.com/product/resources/forrester-names-sciencelogic-a-leader-in-aiops-platforms-wave).
  - The reprints require forms.
- No Forrester Wave dedicated to observability or APM was published in 2024–2026.
- Forrester TEI studies are vendor-commissioned, for example [Elastic TEI 2026](https://www.elastic.co/blog/total-economic-impact-of-elastic-observability-2026), and should not be treated as neutral.

#### 3.5 IDC [ANALYST]
- **"IDC MarketScape: Worldwide Observability Platforms 2025 Vendor Assessment"**, doc US53004325, November 2025, analyst Shannon Kalvar.
  - Free Elastic reprint PDF dated Nov 14, 2025: https://www.elastic.co/pdf/idc-marketscape-worldwide-observability-platforms-2025.pdf
  - Gated IDC page: https://my.idc.com/getdoc.jsp?containerId=US53004325
- Leaders:
  - Elastic: [Elastic blog](https://www.elastic.co/blog/elastic-observability-idc-marketscape-leader-2025)
  - New Relic: [New Relic (form)](https://newrelic.com/resources/report/idc-marketscape-worldwide-observability)
  - Splunk: [Splunk (form)](https://www.splunk.com/en_us/form/worldwide-observability-platforms-2025-vendor-assessment.html)
  - Oracle and ServiceNow: snippet only.
- New Relic calls it the "inaugural IDC MarketScape: Worldwide Observability **Software** 2025", which is a naming conflict.
- No free IDC observability market-size figure was found.

#### 3.6 GigaOm Radar [ANALYST]
- **Cloud Observability 2024** (21 vendors): New Relic was a Leader and Outperformer. — [New Relic blog, Mar 27, 2024](https://newrelic.com/blog/news/leader-in-gigaom-2024-radar-for-cloud-observability)
- **Cloud Observability 2025** (23 vendors, Mar 19, 2025): Dynatrace was a Leader and Outperformer. — [Dynatrace PR](https://www.dynatrace.com/news/press-release/2025-gigaom-radar-report-for-cloud-observability/)
- **Kubernetes Observability 2025** (23 vendors, Aug 7, 2025): Dynatrace was a Leader and Outperformer. — [Dynatrace PR](https://www.dynatrace.com/news/press-release/2025-gigaom-radar-kubernetes-observability/)
- 2026 Cloud Observability: Dynatrace was a Leader and Fast Mover. — [Dynatrace (form)](https://www.dynatrace.com/info/reports/gigaom-radar-for-cloud-observability/)

### Inferences
- **Gartner Leaders were stable but not static.** Six vendors were Leaders in all three years (2024, 2025, 2026): Chronosphere, Datadog, Dynatrace, Elastic, Grafana Labs and New Relic. IBM joined in 2025. Splunk was a Leader in 2024–2025 and a Challenger in 2026. The 2026 movements (Splunk down to Challenger, Coralogix up to Leader) coincide with Gartner's emphasis on AI-workload observability and cost management.
- **Gartner's own framing in 2025–2026 matches the vendor survey themes**: cost control (telemetry pipelines, cost-control use case), AI/LLM observability (AI Engineering use case, the 2028 predictions) and OTel as table stakes.
- Most analyst "evidence" reaches the public via vendor PR. A vendor amplifies a placement only when it is favorable, so absences, such as no New Relic 2026 PR, are not evidence of anything.

### Gaps
- The full 2024 and 2025 Challenger/Visionary/Niche lists could not be confirmed.
- The 2026 MQ analyst list conflicts between vendor sources.
- Gartner Hype Cycle positions for OTel, AI observability, telemetry pipelines, eBPF and profiling could not be verified.
- The IDC MarketScape vendor count (reportedly 26) and the Oracle/ServiceNow Leader placements are snippet-only.
- No Forrester observability/APM Wave or GigaOm AIOps Radar was found.
- Omdia, 451 Research and ISG were not searched.
- Non-Gartner market sizes, such as MarketsandMarkets' "$2.4B (2023) to $4.1B (2028)", are snippet-only and define the market much more narrowly.

---

## Q4. What trends recur across reports?

### Takeaway
Six themes recur across almost every 2024–2026 source:
- **OpenTelemetry has become the default standard.** Investment is near-universal, production depth is growing, and OTel graduated in May 2026.
- **Cost control** is the top selection criterion and a top Gartner buyer concern.
- **Consolidation** is the main cost lever, though tool counts remain high.
- **AI-assisted observability** is near-universally claimed but shallow in maturity.
- **Observability *of* AI/LLMs** is the new frontier.
- **Profiling** is emerging as the fourth signal: about 20% use it (CNCF 2025), and it entered OTel alpha in March 2026.

### Cited Findings

**Trend 1. OpenTelemetry as the standard**
- Neutral: OTel production use rose from 39% (2024 survey) to 49% (2025 survey). — [CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf); [CNCF 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf)
- Neutral: OTel graduated from CNCF on May 21, 2026, as "the de facto standard for open source observability". — [CNCF](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)
- Vendor: 76% have invested in OTel (Grafana 2026), but 10.3% use it across all production workloads. — [Grafana 2026](https://grafana.com/observability-survey/2026/)
- Vendor: 73% are standardized on, migrating to or testing OTel; only 2% have ruled it out (New Relic 2026). — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- Vendor-sponsored: OTel in production went from 6% to 11%, and use of vendor OTel distributions from 44% to 60% (Elastic 2026). — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- EMA (multi-sponsor): 48.5% use OTel today. — [EMA 2025](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf)
- Analyst: "Many enterprise buyers now consider OpenTelemetry support a baseline requirement rather than a differentiator" (Gartner, via Network World). — [Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)

**Trend 2. Prometheus remains entrenched and coexists with OTel**
- CNCF: Prometheus is 73% in production (2024 survey) and 77% (2025 survey). — [CNCF 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf)
- Grafana: 70% use both Prometheus and OTel (2025), and 65% invest in both (2026). — [Grafana PR 2025](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/); [Grafana 2026](https://grafana.com/observability-survey/2026/)
- OTel interop survey (Sep 2026): about 49% use both Prometheus exporters and OTel receivers, and "hard to use together" fell from 29% to 10%. — [OTel blog](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/)

**Trend 3. Cost is the dominant concern**
- Cost is the top selection criterion for the third straight year (65%, Grafana 2026). — [Grafana 2026](https://grafana.com/observability-survey/2026/)
- 67% regularly experience unexpected costs or overages (Elastic 2026). — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- 46% of UK leaders cite cost as their biggest challenge (LogicMonitor EMEA 2026). — [SecurityBrief UK](https://securitybrief.co.uk/story/uk-it-leaders-eye-observability-platform-consolidation)
- Gartner: "Telemetry cost management remains one of the top concerns for enterprise buyers", and 5% of clients spend more than $10M a year with a single provider. — [Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)
- Gartner: 40% of log telemetry will go through telemetry pipelines by 2027, up from under 20% in 2024. — [Mezmo-hosted Gartner Market Guide](https://www.mezmo.com/resources/gartner-market-guide-for-telemetry-pipelines)
- Chronosphere: log data grew 250% year over year (2024). — [Chronosphere](https://chronosphere.io/learn/observability-log-data-trends/)

**Trend 4. Tool sprawl and consolidation**
- Average tool counts:
  - Dynatrace 2024 (CIOs): 10 monitoring/observability tools. — [Dynatrace PR 2024](https://www.dynatrace.com/news/press-release/annual-global-cio-report-reveals-cloud-native-technologies-produce-explosion-of-data-beyond-humans-ability-to-manage/)
  - Grafana 2025: 8 technologies. — [Grafana 2025](https://grafana.com/observability-survey/2025/)
  - Elastic 2024: more than 7 tools. — [Elastic 2024](https://www.elastic.co/pdf/dimensional-research-elastic-the-2024-observability-landscape.pdf)
  - New Relic: 4.4 tools (2025), rising to 5.0 (2026). — [NR 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf); [NR 2026 landing page](https://newrelic.com/resources/report/observability-forecast/2026)
- Problems reported with sprawl:
  - "Too many disparate tools" is the top challenge for 59% (Splunk 2025). — [Cisco/Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
  - 55% say they use too many monitoring tools (SolarWinds 2026). — [SolarWinds PR 2026](https://solarwinds.com/company/newsroom/press-releases/state-of-monitoring-observability-2026)
  - 75% use 4–12 tools, and 55% switch tools 3–5 times per incident (EMA, Sep 2026). — [EMA PR](https://www.enterprisemanagement.com/press_release/new-ema-research-finds-observability-unification-remains-a-challenge-for-most-enterprises/)
- Consolidation intent:
  - Elastic: 74% (2024) and 79% (2025) are consolidating; consolidation is the top cost lever at 51% (2026). — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
  - LogicMonitor: 84% are pursuing or considering it. — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)
  - New Relic: 52% plan to consolidate (2025). — [NR 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)

**Trend 5. AI-assisted observability (AIOps, GenAI, agents)**
- Adoption claims are near-universal:
  - Splunk: 97% use AI/ML (2024), and 76% regularly use AI-powered observability (2025). — [Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html); [Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
  - Dynatrace: 100% use AI in operations (2025). — [Dynatrace PR 2025](https://www.dynatrace.com/news/press-release/state-of-observability-2025/)
  - Elastic: 85% use GenAI for observability (2026). — [Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)
- Trust and explainability caveats:
  - 69% of AI decisions are still human-verified (Dynatrace 2025). — [Dynatrace PR 2025](https://www.dynatrace.com/news/press-release/state-of-observability-2025/)
  - 95% want AI to explain its reasoning (Grafana 2026). — [Grafana 2026](https://grafana.com/observability-survey/2026/)
  - Only 4% have fully operational AI (LogicMonitor). — [LogicMonitor PDF](https://portal.climbcs.com/content/Climb-WP/Content/Vendor-Page/LogicMonitor/LM_Report_2026ObservabilityAIOutlook_Final.pdf)
- Alert fatigue persists as the problem AI is meant to solve:
  - 57% have problematic alert volumes (Splunk 2024). — [Splunk PR 2024](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2024/m10/splunk-report-observability-leaders-achieve-increased-developer-productivity-and-speed-boosting-their-competitive-edge.html)
  - Alert fatigue is the top incident-response obstacle (Grafana 2025 and 2026). — [Grafana 2026](https://grafana.com/observability-survey/2026/)

**Trend 6. Observability *of* AI/LLMs and agents**
- 25% have AI agents in production without monitoring, and 47% have AI application observability (New Relic 2026). — [New Relic PR 2026](https://newrelic.com/press-release/20260922)
- 85% plan LLM observability, but only 8% have completed it (Elastic 2026). — [Elastic 2026 blog](https://www.elastic.co/blog/2026-observability-trends-generative-ai-opentelemetry)
- 47% say monitoring AI workloads has made their job harder (Splunk 2025). — [Splunk PR 2025](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)
- 84% have had at least one AI-related outage (PagerDuty, Sep 2025). — [PagerDuty](https://www.pagerduty.com/newsroom/ai-resilience-survey-2025/)
- Datadog telemetry: about 5% of LLM requests fail in production, and nearly 60% of those failures come from capacity limits. — [Datadog 2026](https://www.datadoghq.com/state-of-ai-engineering/)
- Gartner: 40% of AI-deploying organizations will use dedicated AI observability tools by 2028. — [TechEdgeAI coverage](https://techedgeai.com/gartner-predicts-40-of-organizations-deploying-ai-will-use-ai-observability-to-monitor-model-performance-by-2028/)
- Gartner MQ 2026 commentary: buyers want visibility into "token consumption, model latency, response quality, hallucination rates". — [Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)

**Trend 7. Profiling as a signal; eBPF**
- "Nearly 20%" of respondents use profiling in their observability stack (CNCF 2025 survey). — [CNCF PR](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/)
- OTel Profiles entered public alpha in March 2026 as the fourth signal. — [OTel blog](https://opentelemetry.io/blog/2026/profiles-alpha/)
- eBPF zero-code instrumentation: Grafana donated Beyla to OTel as OBI (2025), and Elastic donated its eBPF profiler. — [Grafana](https://grafana.com/blog/2025/05/07/opentelemetry-ebpf-instrumentation-beyla-donation/); [Elastic](https://www.elastic.co/observability-labs/blog/otel-profiling-alpha)

**Trend 8. Outage cost and MTTR as the business case**
- New Relic outage cost per hour: up to $1.9M (2024), a $2M median (2025) and a $1.85M mean (2026). Average 2026 MTTD is 41 minutes and MTTR 54 minutes. — [NR 2024](https://newrelic.com/press-release/20241022); [NR 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf); [NR 2026](https://newrelic.com/press-release/20260922)
- PagerDuty: $4,537 per minute and 175 minutes average resolution (2024). In 2026, 68% lose more than $300K per hour during incidents. — [PagerDuty 2024](https://pagerduty.com/newsroom/study-cost-of-incidents); [PagerDuty 2026](https://www.pagerduty.com/newsroom/2026-state-of-ai-first-operations/)
- Logz.io: 82% report MTTR over 1 hour (2024), up from 47% in 2021. — [Logz.io 2024](https://logz.io/observability-pulse-2024/)

### Inferences
- **The OTel story has shifted from "whether" to "how deep".** In 2024 the question was evaluation: Elastic 78% considering, Grafana 85% investing. By 2026 near-universal investment sits alongside low full-production penetration (about 10–11% per Grafana and Elastic), against a neutral CNCF figure of 49% in production in some form. The likely bottlenecks are migration effort, SDK and Collector complexity (OTel DevEx and Collector surveys), and continued reliance on Prometheus.
- **Cost and consolidation are two sides of one theme.** Vendors frame consolidation onto their own platform as the cost fix. The neutral and analyst framing leans toward telemetry pipelines and data reduction (Gartner's 40% by 2027). OTel's vendor-neutrality is the enabler for both, since it lowers switching costs.
- **The "AI" theme has split in two:**
  - AI *for* observability: AIOps, RCA, anomaly detection. Nearly universal in claims; human-verified and immature in practice.
  - Observability *for* AI: LLM/agent monitoring. Low maturity, and now a Gartner MQ criterion and a source of new telemetry-volume and cost pressure.
- **Vendor bias pattern:** reports from vendors that sell AI or full-stack platforms (Dynatrace, Splunk, New Relic) report the highest AI-adoption and ROI figures. Community-based samples (Grafana, CNCF) emphasize open source and open standards. Readers should weight the neutral CNCF numbers and the explicitly defined metrics most heavily.

### Gaps
- No neutral source measures observability cost, tool counts or AI-for-observability adoption with a large sample; all such figures are vendor-sponsored.
- Profiling adoption has only one data point (CNCF "nearly 20%"). No vendor survey reports a profiling percentage.
- Gartner Hype Cycle placements, which would show analyst views of OTel, profiling, eBPF and LLM observability maturity, could not be verified.
- Year-over-year comparisons within a vendor series are weakened by changes in sample size and composition: Grafana 306 → 1,255 → 1,363; New Relic 1,700 → 1,700 → 2,575; New Relic 16 → 23 → 24 countries.
