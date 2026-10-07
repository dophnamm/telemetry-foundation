# Emitting OCSF Security Events from an OTel Collector Pipeline and Delivering Them Reliably to Customer SIEMs (file scanning / CDR / DLP vendor)

Versions checked on 2026-10-07:
- **OCSF schema 1.9.0** is the latest release (published 2026-08-03). `main` reads `1.10.0-dev`. The public schema server API returns `{"version":"1.9.0"}`. Sources: [ocsf-schema releases](https://github.com/ocsf/ocsf-schema/releases/tag/1.9.0), [version.json on main](https://github.com/ocsf/ocsf-schema/blob/main/version.json), [schema.ocsf.io/api/version](https://schema.ocsf.io/api/version).
- **OpenTelemetry Collector v0.162.0**, both core (released 2026-09-28) and contrib (released 2026-09-29). Sources: [collector releases](https://github.com/open-telemetry/opentelemetry-collector/releases/tag/v0.162.0), [collector-contrib releases](https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/tag/v0.162.0).
- I read every Collector README and source file below at tag `v0.162.0`. I read every OCSF class and object file at tag `1.9.0`.

---

## Q1. Which OCSF classes fit malware scan results, CDR sanitization and DLP findings, and how do other vendors map similar events?

### Takeaway
In OCSF 1.9.0 the classes that fit are:
- **Detection Finding (2004)** for malicious or suspicious file verdicts. It now carries native `malware[]` and `malware_scan_info` objects.
- **Scan Activity (6007)** for the scan job or request as a whole, whatever the verdict.
- **Data Security Finding (2006)** for DLP and sensitive-data hits. This class was added in **1.2.0, not 1.4**.
- For CDR there is no dedicated class. The two candidates are **File Remediation Activity (7002)** and File System Activity (1001), each combined with the Security Control profile's `disposition_id` (`11 Corrected`, `12 Partially Corrected`, `13 Uncorrected`).

No file-scanning, sandbox or CDR vendor appears in the Amazon Security Lake source partner list, so there is no direct public precedent to copy. The published partner mappings that exist concentrate on endpoint and network activity classes and on generic "findings".

### Cited Findings

**Class UIDs and how they are computed**
- The OCSF categories (category_uid) are: System Activity = 1, Findings = 2, Identity & Access Management = 3, Network Activity = 4, Discovery = 5, Application Activity = 6, Remediation = 7, Unmanned Systems = 8. — [categories.json @1.9.0](https://github.com/ocsf/ocsf-schema/blob/1.9.0/categories.json)
- The compiler computes the final class UID as `category_uid * 1000 + cls_uid`. — [ocsf-schema-compiler scoping.py](https://github.com/ocsf/ocsf-schema-compiler/blob/main/src/ocsf_schema_compiler/scoping.py)
- Local class UIDs and their category, which give the final UIDs:

  | Class file | Local `uid` | Category | Final class_uid |
  |---|---|---|---|
  | `detection_finding.json` | 4 | findings | 2004 |
  | `data_security_finding.json` | 6 | findings | 2006 |
  | `security_finding.json` | 1 | findings | 2001 |
  | `file_activity.json` (caption "File System Activity") | 1 | system | 1001 |
  | `scan_activity.json` | 7 | application | 6007 |
  | `remediation_activity.json` | 1 | remediation | 7001 |
  | `file_remediation_activity.json` | 2 | remediation | 7002 |

  Sources: [detection_finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/detection_finding.json), [data_security_finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/data_security_finding.json), [file_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/system/file_activity.json), [scan_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/application/scan_activity.json), [file_remediation_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/remediation/file_remediation_activity.json)
- The live validator accepted a minimal Detection Finding with `class_uid: 2004`, `category_uid: 2`, `activity_id: 1` and `type_uid: 200401`, returning 0 errors and 0 warnings. — [schema.ocsf.io /api/v2/validate](https://schema.ocsf.io/api/v2/validate) (tested 2026-10-07 by POST)

**Base event requirements (apply to every class)**
- Required: `activity_id`, `category_uid`, `class_uid`, `metadata`, `severity_id`, `time`, `type_uid`.
- Recommended: `message`, `observables`, `status*`, `timezone_offset`.
- Source: [base_event.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/base_event.json)

**`metadata` object**
- Required: `product` and `version`.
- Recommended: `log_name`, `original_time`, `reporter`, `tenant_uid`.
- Optional: `extensions`, `profiles`, `sequence`, `uid`, `correlation_uid`, `processed_time`, `logged_time`.
- The dictionary says producers "**must** populate `metadata.product` ... and `metadata.version`".
- Sources: [metadata.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/metadata.json), [dictionary.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/dictionary.json)

**Findings base class (inherited by 2004 and 2006)**
- `finding_info` is required. Inside it, `finding_info.uid` is required and `title` and `analytic` are recommended.
- Activities: 1 Create, 2 Update, 3 Close. `status_id` and `confidence_id` are recommended. `vendor_attributes` is optional.
- Sources: [finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/finding.json), [finding_info.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/finding_info.json)

**Detection Finding (2004)**
- Recommended: `evidences`, `is_alert`, `resources`, `confidence_id`.
- Optional: `malware`, `malware_scan_info`, `remediation`, `vulnerabilities`, `anomaly_analyses`, `risk_*`, `impact_*`.
- The class description says: "If the event producer is a security control, the `Security Control` profile should be applied and its `attacks` information, if present, should be duplicated into the `finding_info` object."
- Source: [detection_finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/detection_finding.json)

**`malware` object**
- Required: `classification_ids`. The enum includes 1 Adware, 2 Backdoor, 10 Ransomware, 18 Trojan, 19 Virus, 22 Worm, and others.
- Recommended: `path`, `provider`, `severity_id`.
- Optional: `files`, `cves`, `num_infected`.
- Source: [malware.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/malware.json)

**`malware_scan_info` object**
- It extends `scan`. Its attributes are all optional: `num_files`, `num_infected`, `num_volumes`, `size`, `start_time`, `end_time`, `unique_malware_count`.
- The parent `scan` object requires `type_id`: 1 Manual, 2 Scheduled, 3 Updated Content, 4 Quarantined Items, 5 Attached Media, 6 User Logon, 7 ELAM, 99 Other.
- Sources: [malware_scan_info.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/malware_scan_info.json), [scan.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/scan.json)
- **Version history:** `malware_scan_info` was added in **1.5.0**. In the same release, `malware_scan_info` and `malware` were added to `detection_finding` and to the `security_control` profile. — [CHANGELOG @1.9.0](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md) (PR #1373)

**Scan Activity (6007)**
- Description: "Scan events report the start, completion, and results of a scan job. The scan event includes the number of items that were scanned and the number of detections that were resolved."
- Required: `scan`.
- Recommended: `num_files`, `num_detections`, `num_resolutions`, `num_skipped_items`, `num_trusted_items`, `total`, `policy`, `command_uid`, `schedule_uid`, `duration`, `start_time`, `end_time`.
- Activities: 1 Started, 2 Completed, 3 Cancelled, 4 Duration Violation, 5 Pause Violation, 6 Error, 7 Paused, 8 Resumed, 9 Restarted, 10 Delayed.
- Source: [scan_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/application/scan_activity.json)
- Added in **1.1.0** (PR #915). — [CHANGELOG](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md)

**Data Security Finding (2006)**
- Description: covers "detections or alerts generated by various data security products such as Data Loss Prevention (DLP), Data Classification, Secrets Management, Digital Rights Management (DRM), Data Security Posture Management (DSPM)".
- Required: `activity_id` (1 Create, 2 Update, 3 Close, 4 Suppressed).
- Recommended: `data_security`, `file`, `is_alert`, `actor`, `device`, `src_endpoint`, `dst_endpoint`, `database`, `databucket`, `table`, `resources`, `confidence_id`.
- Source: [data_security_finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/data_security_finding.json)
- **Version history:** added in **v1.2.0** (PR #953). Activity `4 Suppressed` was later deprecated because "the right place for this info is `status_id`" (PR #1245). `is_alert` and `risk_details` were added in v1.4.0. — [CHANGELOG](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md)

**`data_security` object**
- It extends `data_classification`. It has a constraint `at_least_one: [data_lifecycle_state_id, detection_pattern, detection_system_id, policy]`.
- Attributes: `detection_pattern`, `pattern_match`, `policy`, `data_lifecycle_state_id`.
- `detection_system_id` values: 1 Endpoint, 2 DLP Gateway, 3 Mobile Device Management, 4 Data Discovery & Classification, 5 Secure Web Gateway, 6 Secure Email Gateway, 7 Digital Rights Management, 8 Cloud Access Security Broker, 9 Database Activity Monitoring, 10 Application-Level DLP, 11 Developer Security, 12 Data Security Posture Management.
- Source: [data_security.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/data_security.json)

**File System Activity (1001)**
- Description: "report when a process performs an action on a file or folder."
- Required: `actor`, `file`, and `device` (inherited from System Activity).
- Recommended: `file_result`, `file_diff`, `component`, `create_mask`.
- Activities: 1 Create, 2 Read, 3 Update, 4 Delete, 5 Rename, 6 Set Attributes, 7 Set Security, 8 Get Attributes, 9 Get Security, 10 Encrypt, 11 Decrypt, 12 Mount, 13 Unmount, 14 Open.
- Sources: [file_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/system/file_activity.json), [system.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/system/system.json)

**Remediation Activity (7001) and File Remediation Activity (7002)**
- Remediation Activity: `command_uid` is required, `countermeasures` is recommended, and `remediation` and `scan` are optional. Activities: 1 Isolate, 2 Evict, 3 Restore, 4 Harden, 5 Detect, 6 Deceive.
- File Remediation Activity adds a required `file` and "report[s] on attempts at remediating files. Sub-techniques of countermeasures will include File, such as File Removal or Restore File."
- Sources: [remediation_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/remediation/remediation_activity.json), [file_remediation_activity.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/remediation/file_remediation_activity.json)
- The Remediation classes were added in **v1.3.0** (PR #1066). — [CHANGELOG](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md)

**Security Control profile**
- Recommended: `action_id`, `disposition_id`, `is_alert`, `confidence_id`.
- Optional: `malware`, `malware_scan_info`, `policy`, `attacks`, `risk_*`.
- `disposition_id` values: 1 Allowed, 2 Blocked, 3 Quarantined, 4 Isolated, 5 Deleted, 6 Dropped, 7 Custom Action, 8 Approved, 9 Restored, 10 Exonerated, **11 Corrected, 12 Partially Corrected, 13 Uncorrected**, 14 Delayed, 15 Detected, 16 No Action, 17 Logged, 18 Tagged, 19 Alert, ... 27 Error, 99 Other.
- `action_id` values: 0 Unknown, 1 Allowed, 2 Denied, 99 Other.
- Sources: [profiles/security_control.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/profiles/security_control.json), [dictionary.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/dictionary.json)

**Deprecated class**
- Security Finding (2001) has been deprecated since 1.1.0 and is superseded by `vulnerability_finding`, `compliance_finding`, `detection_finding`, `incident_finding` and `data_security_finding`. — [security_finding.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/events/findings/security_finding.json)

**What 1.9.0 added that matters here**
- A `record_integrity` profile on `base_event` that adds a cryptographic `attestation` (fingerprint and signatures), with tamper-evident chain attributes `prev_event` and `chain_uid` and an `authority_uid`.
- `download_info` on `file`.
- `notes` and `resources` on `finding`.
- Source: [CHANGELOG v1.9.0](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md) (PRs #1661, #1658, #1670)

**How other vendors map similar events (published sources)**
- **CrowdStrike** (FDR to Security Lake): "Only events classified to the following OSCF classes are mapped": DNS Activity, File Activity, Kernel Extension (Module Activity), Network Activity and Process Activity. The mapping files have to be obtained from the CrowdStrike account manager. — [CrowdStrike/aws-security-lake README](https://github.com/CrowdStrike/aws-security-lake)
- **Trend Micro** Cloud One Workload Security sends DNS Query, File, Network, Process, Registry Value and User Account activity to Security Lake. — [AWS Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)
- **Okta** sends System Logs in OCSF "related to authentication, authorization, account changes, and entity changes". — [AWS Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)
- **Other Security Lake source partners** (same page): Cisco Secure Firewall (firewall logs converted by the eNcore client), Zscaler Posture Control ("security findings"), Palo Alto Prisma Cloud (vulnerability detection data), Netskope (via a CloudExchange plugin), and Laminar and Sentra (DSPM data security events and findings). These DSPM partners are the closest analogue to DLP, but the page does not name their OCSF classes. **OPSWAT and other file-scanning, sandbox or CDR vendors are not listed.** — [AWS Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)
- **Cribl** maps Palo Alto Networks Threat and Traffic logs and Zscaler Firewall and Web logs to "OCSF Event Class 4001" (Network Activity) using its OCSF Post Processor Pack. — [Cribl docs (search result)](https://docs.cribl.io/stream/usecase-security-lake/)
- **The official OCSF examples repo** has markdown mappings only for AWS, CERT-NetSA, Cisco, Falco, GitHub, IBM, Microsoft, Okta, Prowler, SSC and Zeek. It has none for CrowdStrike, Palo Alto, Zscaler, Netskope, Trend Micro or Sophos. — [ocsf/examples mappings](https://github.com/ocsf/examples/tree/main/mappings/markdown)

### Inferences

**Recommended class choices (not an official mapping; derived from the class definitions above):**

| Product event | Class (UID) | Key fields to populate |
|---|---|---|
| Multi-engine scan of one file or one request, any verdict | Scan Activity **6007**, `activity_id` 2 Completed (6 Error, 3 Cancelled) | `scan` (`type_id` 1 Manual for on-demand, 99 Other for API/ICAP/inline), `num_files`, `num_detections`, `num_skipped_items`, `num_trusted_items`, `total`, `duration`, `policy` (the workflow or rule) |
| Infected or suspicious verdict | Detection Finding **2004**, `activity_id` 1 Create | `finding_info.uid` (stable scan ID plus file hash), `finding_info.title`, `malware[]` (one entry per engine detection: `name`, `classification_ids`, and `provider` = engine name, which fits multi-engine AV), `malware_scan_info` (`num_files`, `num_infected`, `unique_malware_count`), `evidences[].file` (hashes, name, size, mime type), `is_alert`, `severity_id`. Apply the Security Control profile and set `disposition_id` to 2 Blocked, 3 Quarantined, 15 Detected or 1 Allowed. |
| CDR sanitization outcome | File Remediation Activity **7002** (`activity_id` 4 Harden as the closest enum; `command_uid` = job ID; `file` = original), **or** File System Activity **1001** `activity_id` 3 Update | For 1001: `file` = original, `file_result` = sanitized output, `file_diff`, `actor` = CDR service process. In both cases apply the Security Control profile with `disposition_id` 11 Corrected, 12 Partially Corrected or 13 Uncorrected. |
| DLP or sensitive-data hit | Data Security Finding **2006**, `activity_id` 1 Create | `data_security` (`detection_system_id` 10 Application-Level DLP, or 6 Secure Email Gateway / 5 Secure Web Gateway when deployed inline; `detection_pattern`; `pattern_match`; `policy`), `file`, `is_alert`, `risk_level_id`, `finding_info`. Use `status_id` instead of the deprecated activity 4 Suppressed. |

Further reasoning:
- **Per-engine details** need an extension object, for example `opswat_engine_results[]` with engine version, definition date and scan time. The multi-engine aggregate verdict, CDR rule set and DLP redaction actions also have no core home.
- **Clean verdicts belong in Scan Activity, not in findings.** A finding implies a detection, so emitting a Detection Finding for clean files would flood SIEMs and break `is_alert` semantics.
- **File System Activity is a poor fit for scan results.** It models "a process performs an action on a file" and requires `actor` and `device`, which a server-side scanning service has to synthesize.
- **No core class captures CDR's "rebuild" semantics.** The `disposition_id` values Corrected and Partially Corrected are the most semantically accurate signal for CDR. Proposing a new class or an enum value upstream, for example a "Sanitize" remediation activity, is an option. Choosing between 7002 and 1001 is a product decision. 7002 makes CDR visible as remediation in SIEM content. 1001 is supported by more SIEM parsers: Splunk OCSF-CIM maps 1001 but not 7002 (see Q3).
- **Version gating:** if events also go to Amazon Security Lake, which accepts OCSF 1.3 or earlier for custom sources (see Q3), those copies cannot carry `malware_scan_info` (added in 1.5.0). Classes 2004, 2006, 6007 and 7002 all exist in 1.3.

### Gaps
- I found no published OCSF mapping from any file-scanning, sandbox or CDR vendor. Sophos, Palo Alto (Cortex/NGFW WildFire), Zscaler ZIA sandbox, Netskope DLP and Trend Vision One class-level mappings were not found in primary sources. Their Security Lake integration docs sit behind vendor portals or did not state class names.
- I did not verify a D3FEND countermeasure ID for "content rebuild" or "sanitize" to put in `countermeasures`.
- I did not read the full schema.ocsf.io class pages. The UIDs above come from the source JSON plus the compiler's scoping formula, and were cross-checked with the live validator for class 2004.

---

## Q2. How do OCSF extensions and profiles work, what tooling exists, and how does a vendor register an extension?

### Takeaway
- **Registration:** a vendor reserves a name and UID by pull request to `extensions.md` in `ocsf-schema`. A reserved UID does not oblige the vendor to publish the extension.
- **Structure:** the extension mirrors the schema layout: `extension.json`, `dictionary.json`, `objects/`, `events/`, `profiles/`, `categories.json`.
- **Adding attributes without new classes:** "patching" extensions (definitions that omit `name`) add attributes directly to core classes or objects, so events keep their core `class_uid`.
- **Tooling for event producers:** compile with `ocsf-schema-compiler -e <ext>`, serve and validate with `ocsf-server` or the `/api/v2/validate` API, and validate in-pipeline with the Go `ocsf-toolkit`.
- **`ocsf-validator` is not for events.** It validates schema source trees.
- **Without an extension, events fail validation:** an undeclared vendor attribute such as `opswat` returns `attribute_unknown`.

### Cited Findings

**Registration and registry contents**
- "In order to reserve an ID space, and make your extension public, add a unique identifier & a unique name for your extension in the OCSF Extensions Registry." — [extensions/README.md @1.9.0](https://github.com/ocsf/ocsf-schema/blob/1.9.0/extensions/README.md)
- "For a real extension, you should request a unique extension ID via a Pull Request to the ocsf-schema repository ... Note that having a reserved public extension ID does not mean your actual extensions need be made public." — [Patching the Core Schema With Extensions (ocsf-docs)](https://github.com/ocsf/ocsf-docs/blob/main/articles/patching-core-using-extensions.md)
- Current registry entries: Trellix 988, Synqly 989, US GOV `usg1` 990, Cisco 991, Sedara 992, Sciber 993, DataBee 994, Symantec 995, SentinelOne `s1` 996, Splunk 997, AWS 998, Development `dev` 999. The native platform extensions are Linux 1, Windows 2 and macOS 3. — [extensions.md](https://github.com/ocsf/ocsf-schema/blob/main/extensions.md)
- Registry versus actual files:
  - The AWS extension's `extension.json` declares `"uid": 998`, `"name": "aws"`, `"version": "1.2.0-dev"`. — [ocsf/aws extension.json](https://github.com/ocsf/aws/blob/main/extension.json)
  - The Splunk extension repo's `extension.json` declares `"uid": 1`, `"version": "1.16.3"`. This conflicts with the registry's 997 and collides with Linux's 1. — [ocsf/splunk extension.json](https://github.com/ocsf/splunk/blob/main/extension.json)

**Directory layout and UID rules**
- An extension folder holds `extension.json` (`caption`, `name`, `uid`, `version`) and optionally `categories.json`, `dictionary.json`, `events/`, `includes/`, `objects/` and `profiles/`. "To avoid collisions with the categories defined in the core schema, the category IDs must be greater than or equal to 30." — [extensions/README.md](https://github.com/ocsf/ocsf-schema/blob/1.9.0/extensions/README.md)
- Class UIDs in an extension are offset by the extension UID. The compiler computes `extension_scoped_category_uid = extension_uid * 100 + category_uid`, then `class_uid = scoped_category_uid * 1000 + cls_uid`. For example, a hypothetical extension 9xx adding class 1 to Findings (category 2) yields `(9xx*100+2)*1000+1`. — [scoping.py](https://github.com/ocsf/ocsf-schema-compiler/blob/main/src/ocsf_schema_compiler/scoping.py), [compiler.py](https://github.com/ocsf/ocsf-schema-compiler/blob/main/src/ocsf_schema_compiler/compiler.py)

**Naming guidance**
- "For vendor extensions to the dictionary, prefix attribute names with a 3-letter moniker in order to avoid name collisions. Example: `aws_finding, spk_context_ids`." — [Understanding OCSF](https://github.com/ocsf/ocsf-docs/blob/main/overview/understanding-ocsf.md)
- That guide also says: "Extended events should populate the `metadata.version` attribute with the extended schema version", and "The Schema Browser will label extensions with a superscript." — [Understanding OCSF](https://github.com/ocsf/ocsf-docs/blob/main/overview/understanding-ocsf.md)

**Patching extensions**
- "The key enabling feature is the omission of the `name` field. This indicates to the schema compilation process that no new class or object should be generated." Attributes are added directly to the core class or object.
- In a patch, profiles and attributes are merged, observables and constraints override, and caption and description are not patched.
- Patching constraints requires OCSF Schema Server 2.72.0 or later.
- Source: [patching-core-using-extensions.md](https://github.com/ocsf/ocsf-docs/blob/main/articles/patching-core-using-extensions.md)

**Profiles**
- `metadata.profiles` should "be referenced by their `name` attribute for core profiles, or `extension/name` for profiles from extensions". `metadata.extensions` holds "The schema extensions used to create the event." — [dictionary.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/dictionary.json)
- "Vendors can add profiles via extensions." — [Understanding OCSF](https://github.com/ocsf/ocsf-docs/blob/main/overview/understanding-ocsf.md)

**`unmapped` versus an extension**
- Using `unmapped` "is not recommended for event producers. A native event producer should extend the schema to properly capture the data that can't be mapped ... an extension is preferred, using either a vendor developed profile, or in some cases a new event class." — [schema FAQ](https://github.com/ocsf/ocsf-docs/blob/main/faqs/schema-faq.md)
- In 1.9.0 the dictionary describes `unmapped` as: "Consumers should not rely on a stable structure within this field. The preferred approach to unmapped attributes is to create a custom extension with the desired structure." — [dictionary.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/dictionary.json)

**Live validation test**
- POSTing a Detection Finding that contains `"opswat": {...}` to the public validator returned `{"error":"attribute_unknown","message":"Unknown attribute at \"opswat\"; attribute \"opswat\" is not defined in class \"detection_finding\" uid 2004."}`. — [schema.ocsf.io /api/v2/validate](https://schema.ocsf.io/api/v2/validate) (tested 2026-10-07)

**Tooling**
- **ocsf-schema-compiler** (Python 3.14+, PyPI): `ocsf-schema-compiler path/to/ocsf-schema > schema.json`. Other extensions are added with `-e`/`--extensions-path`, which can be repeated. Platform extensions are included by default and can be excluded with `-i`. Private extensions "should" use UIDs higher than the platform extensions. Dictionary names that shadow core names cause failures; the README's example is AWS `last_used_time`. — [ocsf-server README](https://github.com/ocsf/ocsf-server), [ocsf-schema-compiler](https://github.com/ocsf/ocsf-schema-compiler)
- **ocsf-server** (Elixir; Docker image) serves a compiled schema through the `SCHEMA_FILE` environment variable, for example `docker run ... -e SCHEMA_FILE=... -p 8080:8080 ocsf-server`. "The OCSF Server does not directly support hosting multiple versions." — [ocsf-server README](https://github.com/ocsf/ocsf-server)
  - This allows a private, air-gapped schema browser and validation API that includes the vendor extension (inference from Docker plus `SCHEMA_FILE`).
- **ocsf-validator** (`pip install ocsf-validator`; `python -m ocsf_validator ../ocsf-schema`) is "A utility to validate contributions to the OCSF schema". It checks the JSON, includes and extends, dictionary use and constraints of a **schema tree**, not of events. — [ocsf-validator](https://github.com/ocsf/ocsf-validator)
- **ocsf-toolkit** is "a Go library and a command line tool for processing OCSF events with a compiled OCSF schema". It adds enum siblings and observables and validates single events.
  - Packages: `github.com/ocsf/ocsf-toolkit/eventpipeline`, `/validation`, `/enrichment`.
  - Guidance from the README: "Do not validate every event unless the application requires it ... Prefer validating a representative sample"; run validation in CI against the production compiled schema.
  - Source: [ocsf-toolkit README](https://github.com/ocsf/ocsf-toolkit)
- **ocsf-lib-py** provides `python -m ocsf.compile`, `ocsf.compare`, `ocsf.schema 1.2.0` and `ocsf.validate.compatibility` (a breaking-change check between versions). — [ocsf-lib-py](https://github.com/ocsf/ocsf-lib-py)
- **ocsf-java-tools** provides `ocsf-parsers`, `ocsf-translator` (a JSON translation DSL) and `ocsf-schema` enrichment (adds `type_uid`, enum text and `observables`). — [ocsf-java-tools](https://github.com/ocsf/ocsf-java-tools)
- **ocsf-models-java** is described as "Java POJOs compatible with the OCSF Schema". Its README returned 404 when fetched. — [ocsf org repo list](https://github.com/ocsf)
- AWS publishes an "OCSF Validation tool" for Security Lake custom sources. — [Security Lake custom sources](https://docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html) → [aws-samples/amazon-security-lake-ocsf-validation](https://github.com/aws-samples/amazon-security-lake-ocsf-validation)

### Inferences

**Suggested path for the `opswat.*` namespace:**
1. Reserve a name and UID through a PR to `extensions.md`. The vendor range in use is 988 to 999 and counting down, so the next free number is likely below 988 and is assigned in the PR.
2. Use a short moniker prefix for dictionary attributes, for example `opswat_` or a 3-letter form, per the naming guidance. OCSF attribute names are snake_case dictionary keys, so dotted `opswat.*` names would have to become nested objects (for example an `opswat` object attribute) or prefixed attributes.
3. Prefer a **patching** extension that adds `opswat_*` objects to the core classes (2004, 2006, 6007, 7002). Events then keep their core `class_uid`, which SIEM parsers recognize. Extension classes get UIDs in the tens of millions, which no SIEM parser listed in Q3 understands.
4. Alternatively, define a vendor **profile** (for example `opswat/metadefender`) that is applied to several classes and listed in `metadata.profiles`.
5. In the pipeline, validate a sample of events with `ocsf-toolkit` or a private `ocsf-server` that loads the compiled core-plus-extension schema. Use `ocsf-validator` in CI on the extension source tree.

**Code generation:** the official options are Java POJOs (ocsf-models-java) and the Python and Go libraries. For Go and Python struct or class generation, the compiled `schema.json` from `ocsf-schema-compiler` is the usual input to a custom generator.

### Gaps
- I could not verify the third-party `ocsf-tool` (protobuf and code generation, `valllabh/ocsf-tool`); the README fetch returned 404. I found no official Go or Python model code generator in the ocsf org.
- I did not find a written governance SLA for registry PR approval.
- I did not confirm that the ocsf-server `/api/v2/validate` endpoint supports loaded private extensions. The behaviour is inferred from it serving a compiled schema.

---

## Q3. Which SIEMs and data lakes ingest OCSF natively (or via official mapping) as of 2026, and over what transport?

### Takeaway
- **Native OCSF store:** only **Amazon Security Lake** stores OCSF natively. Custom sources must deliver **Parquet, one OCSF class per source, OCSF 1.3 or earlier**.
- **Supported, but only for a subset of core classes or old versions:**
  - **Splunk:** the OCSF-CIM add-on (sourcetype `ocsf:*`, delivered over HEC) maps 19 core classes but **not** Detection Finding or Data Security Finding, and ignores vendor extensions.
  - **Google SecOps:** an `OCSF` parser for JSON, covering OCSF 1.0.0-rc.3 and 1.1.0. It includes Detection Finding but not File System Activity or Data Security Finding.
  - **Elastic:** reads Security Lake and maps OCSF 1.1.0 to ECS.
  - **QRadar:** Security Lake DSMs at OCSF 1.0RC2.
  - **CrowdStrike NG-SIEM:** a Security Lake connector that maps OCSF to CPS.
- **No native OCSF:** **Microsoft Sentinel** uses ASIM, which aligns to OSSEM, and its ASIM docs do not mention OCSF.
- **Practical consequence:** for most SIEMs a vendor needs either a per-SIEM add-on or parser, or a Security Lake path.

### Cited Findings

**Amazon Security Lake**
- Custom-source requirements:
  - "deliver each unique OCSF event class as a separate source".
  - "Each S3 object ... should be formatted as an Apache Parquet file".
  - "The same OCSF event class should apply to each record within a Parquet-formatted object".
  - Data page size of 1 MB or less, row groups of 256 MB or less, and "zstandard is preferred".
  - Prefix `{source location}/region={region}/accountId={accountID}/eventDay={yyyyMMdd}/`. For non-AWS accounts use `external` or `external_externalAccountId`.
  - Files "in increments between 5 minutes and 1 event day".
  - Records sorted by time.
  - At most **50 custom sources** per account.
  - "**For custom sources, Security Lake supports OCSF version 1.3 and earlier.**"
  - Source: [Security Lake custom sources](https://docs.aws.amazon.com/security-lake/latest/userguide/custom-sources.html)
- Source integrations arrive "in Apache Parquet format" and in OCSF. To become a partner, email securitylake-partners@amazon.com. — [Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)
- Subscribers that read Security Lake include Splunk (Add-on for AWS, app 1876), IBM QRadar, CrowdStrike NG-SIEM, Datadog, Rapid7, Sumo Logic, Securonix, SentinelOne, Panther, Devo, Stellar Cyber and Wazuh. — [Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)

**Splunk**
- The **OCSF-CIM Add-On for Splunk** (Splunkbase app 6841) is at v1.1.0, released 2026-07-30, for Splunk 9.1 to 10.6 and CIM 6.x/8.x. It maps these classes:

  | Class | CIM data model |
  |---|---|
  | 1001 File System Activity | Change |
  | 1007 Process Activity | Endpoint.Processes |
  | 2001 Security Finding | Alerts |
  | 2002 Vulnerability Finding | Vulnerabilities |
  | 3001 Account Change | Account_Management |
  | 3002 Authentication, 3003 Authorization | Authentication |
  | 3004 Entity Management | Change |
  | 3005 User Access Management | Account_Management |
  | 4001 Network Activity | Network Traffic |
  | 4002 HTTP Activity | Web |
  | 4003 DNS Activity | Network Resolution |
  | 4014 Tunnel Activity | VPN |
  | 5001 Cloud API | Change |
  | 6001 Web Resources Activity | Network_Changes |
  | 6003 API Activity | Change |
  | 6004 Web Resources Access | Data Access |
  | 6005 Datastore Activity | Change |
  | 6006 File Hosting Activity | Data Access |

  The page says "Currently, it does only map events from the core OCSF schema hosted at https://schema.ocsf.io and not vendor-specific extensions." Detection Finding (2004), Data Security Finding (2006), Scan Activity (6007) and Remediation classes are not listed. — [Splunkbase app 6841](https://splunkbase.splunk.com/app/6841)
- "You must prefix OCSF sourcetypes with `ocsf`. For example, `ocsf:aws:asl`." Adding one creates a `props.conf` stanza in `ocsf_cim_addon_for_splunk/local`. — [Configuring OCSF CIM add-on](https://help.splunk.com/en/data-management/common-information-model/8.6/introduction/overview-of-the-ocsf-cim-add-on/configuring-ocsf-cim-add-on)
- Without the add-on, `props.conf` needs `KV_MODE = json` and `TIME_FORMAT = %s%6N`. — [Working with OCSF-formatted data in Splunk and ES](https://help.splunk.com/en/splunk-cloud-platform/process-data-at-ingest-time/use-ingest-processors/process-data-using-pipelines/convert-data-to-ocsf-format-using-ingest-processor/working-with-ocsf-formatted-data-in-the-splunk-platform-and-splunk-enterprise-security)
- Edge Processor and Ingest Processor convert **known Splunk source types** to OCSF with the SPL2 `ocsf` command or the `to_ocsf` eval function. The example output shows `"version": "1.5.0"`. — [OCSF data conversion process](https://help.splunk.com/en/data-management/process-data-at-the-edge/use-edge-processors-for-splunk-cloud-platform/process-data-using-pipelines/convert-data-to-ocsf-format-using-an-edge-processor/ocsf-data-conversion-process), [Edge Processor OCSF field conversion (search result)](https://help.splunk.com/en/splunk-cloud-platform/process-data-at-the-edge/use-edge-processors-for-splunk-cloud-platform/process-data-using-pipelines/convert-data-to-ocsf-format-using-an-edge-processor/convert-data-in-a-specified-event-field-to-ocsf-format)
- Splunk maintains its own OCSF extension repository at `ocsf/splunk`. — [ocsf/splunk](https://github.com/ocsf/splunk)

**Microsoft Sentinel**
- The ASIM page (ms.date 2026-09-10) says "ASIM aligns with the Open Source Security Events Metadata (OSSEM) common information model". It does not mention OCSF.
- ASIM schemas: Agent, Alert, Audit, Authentication, DHCP, DNS, Email, File Activity, Network Session, Process, Registry, User Management, Web Session, plus the Asset Entity.
- Ingest-time normalized tables include `ASimFileEventLogs`, `ASimAuditEventLogs` and `ASimNetworkSessionLogs`. Otherwise ASIM relies on query-time KQL parsers.
- Source: [ASIM normalization (Microsoft Learn)](https://learn.microsoft.com/azure/sentinel/normalization)
- A Microsoft Tech Community blog, "Amazon Security Lake Integration with Microsoft Sentinel: Parquet at the Gates", describes Security Lake Parquet → SQS → Lambda (converts rows to JSON) → Azure Event Hub → DCR → Sentinel custom table. I verified only the title. The architecture comes from the search-result summary. — [Tech Community blog](https://techcommunity.microsoft.com/blog/microsoft-security-blog/amazon-security-lake-integration-with-microsoft-sentinel-parquet-at-the-gates/4516635)

**Google SecOps (Chronicle)**
- There is a parser with the `OCSF` ingestion label. "The OCSF parser supports logs in JSON format." The page was last updated 2026-10-05.

  | Supported class | OCSF versions |
  |---|---|
  | Authentication, Authorize Session, FTP Activity, Process Activity, HTTP Activity, Network Activity, API Activity, DNS Activity | 1.0.0-rc.3 and 1.1.0 |
  | Security Finding, Network File Activity | 1.0.0-rc.3 only |
  | **Detection Finding**, File Hosting Activity | 1.1.0 only |

  The page notes "fields for these versions is not fully covered as per the schema". File System Activity, Data Security Finding and Scan Activity are not listed. — [Collect OCSF logs (Google SecOps)](https://docs.cloud.google.com/chronicle/docs/ingestion/default-parsers/ocsf)
- Ingestion methods named in the docs include the Bindplane agent, the Ingestion API, Cloud Storage feeds and webhooks. This comes from the fetch summary, not quoted text. — [Collect OCSF logs](https://docs.cloud.google.com/chronicle/docs/ingestion/default-parsers/ocsf)

**Elastic Security**
- The Amazon Security Lake integration is v2.10.1. It "follows the OCSF Schema Version v1.1.0" and maps to ECS. It reads in S3 polling mode or S3-SQS mode.
- Limitation: "Some important objects like 'Actor', 'User' and 'Product' have more fleshed-out mappings compared to others which get flattened after the initial 2-3 levels of nesting."
- Source: [Elastic Amazon Security Lake integration](https://www.elastic.co/docs/reference/integrations/amazon_security_lake)

**IBM QRadar**
- "The supported OCSF version of the DSM is OCSF 1.0RC2. The version OCSF 1.1 is not currently supported." QRadar uses the Amazon AWS S3 REST API protocol with SQS against Security Lake Parquet. — [IBM DSM: GuardDuty via Security Lake](https://www.ibm.com/docs/en/SS42VS_DSM/com.ibm.dsm.doc/t_dsm_guide_amazon_guardduty_security_lake.html)

**CrowdStrike Falcon Next-Gen SIEM**
- The Amazon Security Lake Data Connector: "The parser included in this connector normalizes OCSF data to CrowdStrike Parsing Standard (CPS)." — [CrowdStrike Marketplace listing](https://marketplace.crowdstrike.com/listings/amazon-security-lake-data-connector)
- Generic ingestion uses a HEC/HTTP Event Connector with an assigned parser. This comes from third-party docs via search, not CrowdStrike docs. — [Tenzir CrowdStrike integration (search result)](https://docs.tenzir.com/integrations/crowdstrike/)

**Cribl**
- The Stream Amazon Security Lake destination "sends the Parquet files in batches" and requires a custom source that is "dedicated to a single OCSF event class". It can generate the Parquet schema automatically or use a manual one. It lists "**PQ Support: No**" (no persistent queue). — [Cribl Security Lake destination](https://docs.cribl.io/stream/destinations-security-lake/)
- An OCSF Post Processor Pack exists (`Cribl-OCSF_Post_Processor`). — [Cribl use case (search result)](https://docs.cribl.io/stream/usecase-security-lake/)

**Sumo Logic**
- A blog dated 2025-09-30 says Security Hub "Findings are delivered in OCSF, and automation rules can act on those attributes without custom parsing". It does not discuss arbitrary third-party OCSF. — [Sumo Logic blog](https://www.sumologic.com/blog/sumo-logic-aws-ocsf-security-hub)
- Sumo Logic is also a Security Lake subscriber. — [Security Lake third-party integrations](https://docs.aws.amazon.com/security-lake/latest/userguide/integrations-third-party.html)

**Datadog Cloud SIEM**
- An Observability Pipelines OCSF processor allows "custom mappings ... to normalize your security logs according to the OCSF framework". Datadog also has out-of-the-box OCSF pipelines for certain integrations. — [Datadog OCSF processor](https://docs.datadoghq.com/security/cloud_siem/ingest_and_enrich/open_cybersecurity_schema_framework/ocsf_processor/)

### Inferences

**Delivery strategy by target:**

| Target | Format and transport | Notes |
|---|---|---|
| Splunk | HEC to sourcetype `ocsf:opswat:<product>` | The OCSF-CIM add-on gives free CIM mapping only for 1001 (and 2001, deprecated). 2004, 2006, 6007 and 7002 need a vendor TA with CIM mappings: 2004 → Malware/Alerts, 2006 → DLP. |
| Amazon Security Lake | Parquet on S3, one class per custom source, OCSF 1.3 or earlier | Needs a Parquet conversion step. The OTel S3 exporter cannot write Parquet (see Q4). Options are Cribl, OpenSearch Ingestion, Lambda/Glue, or a custom component. Fields added after 1.3 (`malware_scan_info`, the 1.9 `record_integrity`) would have to be dropped or moved into an extension. |
| Google SecOps | OCSF JSON to the `OCSF` label | Detection Finding works. DLP (2006) and CDR events would probably need a parser extension or custom parser. |
| Sentinel, Elastic, QRadar, CrowdStrike NG-SIEM | Vendor-specific mappings | Map to ASIM (File Activity, Alert) through DCR transforms, ECS through an ingest pipeline, a QRadar DSM, or CrowdStrike CPS. Raw OCSF into these platforms lands as custom JSON without built-in content. |

- **Version strategy:** the safest common baseline across SIEM parsers today is OCSF **1.1 to 1.3**. Google supports 1.1, Elastic 1.1, Security Lake up to 1.3, and QRadar 1.0RC2. That argues for emitting 1.3-compatible core fields with vendor data in an extension, and declaring `metadata.version` accurately.

### Gaps
- I found no primary source on Exabeam OCSF support. Exabeam material refers only to its own "Common Information Model".
- I found no Microsoft Learn page describing a first-party Sentinel connector for Security Lake or for OCSF.
- I did not verify the Logs Ingestion API (DCR) as the recommended transport for raw JSON into Sentinel in this session. It is the standard Azure Monitor custom-log path.
- I did not verify Google SecOps' maximum OCSF version beyond the 1.1.0 table, or whether parser extensions accept OCSF extension attributes.
- The Splunk docs do not state how the add-on behaves with OCSF versions newer than its maps (for example 1.9 attributes).
- Security Lake docs do not say whether custom sources can carry OCSF extension attributes or classes in Parquet.

---

## Q4. Which OTel Collector exporters can deliver raw OCSF JSON bodies, and what delivery guarantees and data-loss cases apply with `sending_queue`, `file_storage` and `retry_on_failure`?

### Takeaway
At v0.162.0, five exporters can emit the log body without an OTLP envelope:

| Exporter | Stability (logs) | How to get the raw body | Main gotcha |
|---|---|---|---|
| `kafka` | beta | `logs::encoding: raw` | Body must be a Map or Bytes; a string body is JSON-quoted |
| `awss3` | alpha | `marshaler: body` | Writes NDJSON, not Parquet |
| `splunk_hec` | beta | Default event mode puts the body in `event`; `export_raw: true` sends body lines | — |
| `elasticsearch` | beta | `bodymap` mapping mode | Mode is marked unstable |
| `syslog` | alpha | Body must be copied into the `message` attribute | It ignores the body |

`file` cannot produce pure NDJSON of bodies, and `otlphttp` only sends OTLP.

At-least-once delivery holds only between successful enqueue to a persistent queue (`sending_queue.storage: file_storage`) and backend acknowledgement. Data is still **dropped** when:
- the queue is full or the disk is full or failing,
- the backend returns a permanent error,
- retries pass `max_elapsed_time`,
- the Collector shuts down while the backend is down (open bug #15677).

### Cited Findings

**Kafka exporter (logs: beta)**
- Config key: `logs::encoding` (default `otlp_proto`). Encoding extensions are also supported.
- "`raw`: if the log record body is a byte array, it is sent as is. Otherwise, it is serialized to JSON. Resource and record attributes are discarded."
- Source: [kafkaexporter README @v0.162.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/kafkaexporter/README.md)
- In the code, `ValueTypeStr` goes through `json.Marshal(value.Str())`, so a string body containing JSON text becomes a **quoted JSON string**. `ValueTypeMap` goes through `json.Marshal(value.Map().AsRaw())`, which produces a JSON object. `ValueTypeBytes` is sent as is. — [raw_marshaler.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/kafkaexporter/internal/marshaler/raw_marshaler.go)
- Durability-related keys:
  - `producer::required_acks` (default = 1) "controls when a message is regarded as transmitted".
  - `producer::max_message_bytes` (default 1000000).
  - `retry_on_failure` and `sending_queue` are the standard exporterhelper settings. "The number of produce retries is governed by `retry_on_failure` and `timeout`, not by `metadata::retry::max`."
  - The exporter "uses a synchronous producer that blocks and does not batch messages".
  - Source: [kafkaexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/kafkaexporter/README.md)
- Partitioning and topics: `partition_logs_by_resource_attributes`, `partition_logs_by_trace_id`, `message_key_from_metadata_key`, `topic_from_attribute`, `record_headers`, `include_metadata_keys`. — [kafkaexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/kafkaexporter/README.md)

**AWS S3 exporter (logs: alpha)**
- Marshalers: `otlp_json` (default), `otlp_proto`, `sumo_ic`, and "`body`: export the log body as string. **This format is supported only for logs.**" An `encoding` setting overrides `marshaler`. — [awss3exporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/awss3exporter/README.md)
- The `body` marshaler writes `body.AsString()` followed by `"\n"` for every record, which produces NDJSON (a Map body renders as JSON). — [body_marshaler.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/awss3exporter/body_marshaler.go)
- Other keys (all from the [awss3exporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/awss3exporter/README.md)):
  - Compression: `none`, `gzip`, `zstd`.
  - Layout: `s3_partition_format` (strftime, default `year=%Y/month=%m/day=%d/h...`), `s3_base_prefix`, `resource_attrs_to_s3`.
  - Object keys: `unique_key_func_name: uuidv7`.
  - Queue and retry: `sending_queue` is **disabled by default**. `retry_mode` (`standard`/`adaptive`/`nop`), `retry_max_attempts` (default 3) and `retry_max_backoff` (20s) control the AWS SDK retryer. `retry_on_failure` is also available.
  - On-prem endpoints: `endpoint` and `s3_force_path_style`, which allow S3-compatible stores such as MinIO.
- There is **no Parquet marshaler**. — [awss3exporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/awss3exporter/README.md)

**Splunk HEC exporter (logs: beta)**
- "`export_raw` (default = false): send only the log's body, targeting a Splunk HEC raw endpoint."
- `sending_queue` is enabled by default.
- Metadata mapping: `source`, `sourcetype` and `index`, overridable per record through `otel_attrs_to_hec_metadata/*` (defaults `com.splunk.source`, `com.splunk.sourcetype`, `com.splunk.index`).
- Size limits: `max_content_length_logs` (default 2 MiB) and `max_event_size` (default 5 MiB).
- Health checks: `heartbeat/interval`.
- Source: [splunkhecexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/splunkhecexporter/README.md)
- In event mode the HEC event's `event` field is `lr.Body().AsRaw()`, so a Map body becomes a JSON object. Record attributes go into indexed `fields`. **Records with an empty body are dropped**: `LogToSplunkEvent` returns nil, and the client simply `continue`s with the comment `// TODO record this drop as a metric`. — [logs_to_splunk.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/pkg/translator/splunk/logs_to_splunk.go), [client.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/splunkhecexporter/client.go)
- In raw mode the client writes `logRecord.Body().AsString() + "\n"`. Events whose JSON exceeds `max_event_size` are appended to `permanentErrors` (`consumererror.NewPermanent`) and are not retried. — [client.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/splunkhecexporter/client.go)

**Syslog exporter (logs: alpha)**
- Config: `endpoint`, `network` (tcp/udp/unix/unixgram), `port` (514), `protocol` (`rfc5424` default, or `rfc3164`), `enable_octet_counting` (default false; RFC 6587), and `tls`.
- `retry_on_failure.max_elapsed_time` defaults to **120s**.
- `sending_queue.enabled` defaults to **false**. `queue_size` defaults to 5000, and `storage` enables persistence.
- Source: [syslogexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/syslogexporter/README.md)
- The message text comes from the **`message` record attribute**, not the body. The README lists the attributes `appname`, `hostname`, `message`, `msg_id`, `priority` (default 165), `proc_id`, `structured_data` and `version`, and shows an example with `"body": ""`. The code uses `formatMessage` → `getAttributeValueOrDefault(logRecord, message, emptyMessage)`. — [syslogexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/syslogexporter/README.md), [rfc5424_formatter.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/syslogexporter/rfc5424_formatter.go)

**Elasticsearch exporter (logs: beta)**
- Mapping modes are `none`, `ecs`, `otel` (default), `raw` and `bodymap`. In `bodymap` mode the exporter "will take the 'body' of a log record as the exact content of the Elasticsearch document without any transformation". The README warns: "The Bodymap mode mapping mode is currently undergoing changes, and its behaviour is unstable."
- `mapping::mode` is deprecated. The mode is set with the scope attribute `elastic.mapping.mode` or the client metadata key `X-Elastic-Mapping-Mode`. `mapping::allowed_modes` restricts which modes clients may request.
- Source: [elasticsearchexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/elasticsearchexporter/README.md)
- With `logs_dynamic_id.enabled`, a record attribute `elasticsearch.document_id` sets the document `_id`.
- Retry settings: `retry::max_retries` (default 2), `retry_on_status` (default `[429]`; "To avoid duplicates, it defaults to `[429]`"), and `retry_on_document_status` for per-document failures inside successful bulk responses.
- Default queue: `queue_size: 10` (requests), `batch.flush_timeout: 10s`.
- Source: [elasticsearchexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/elasticsearchexporter/README.md)

**File exporter (logs: alpha)**
- With `format: json` (default), each line is an OTLP JSON object (an envelope).
- "when using `proto` format or any kind of encoding, each encoded object is preceded by 4 bytes (an unsigned 32 bit integer)". So `encoding: text_encoding` gives length-prefixed records, **not** pure NDJSON.
- Other keys: `rotation`, `append`, `compression: zstd`, `flush_interval` (1s), `group_by`.
- Source: [fileexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/fileexporter/README.md)

**text_encoding extension (beta)**
- "When marshaling logs, the extension will return the body content, separated by a separator." The default `marshaling_separator` is `"\n"`. — [textencodingextension README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/extension/encoding/textencodingextension/README.md)
- It can be plugged into exporters that accept `encoding`, such as kafka and awss3.

**OTLP/HTTP exporter**
- `encoding` (default = proto) accepts only `proto` or `json`, so output is always an OTLP envelope. — [otlphttpexporter README @v0.162.0](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.162.0/exporter/otlphttpexporter/README.md)

**exporterhelper semantics (queue and retry)**
- `retry_on_failure` defaults: `initial_interval` 5s, `max_interval` 30s, `max_elapsed_time` 300s ("If set to 0, the retries are never stopped"), `multiplier` 1.5.
- `sending_queue` defaults: `enabled` true, `num_consumers` 10, `wait_for_result` false, `block_on_overflow` false, `sizer` requests, `queue_size` 1000, and `batch` (disabled unless set).
- Source: [exporterhelper README @v0.162.0](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.162.0/exporter/exporterhelper/README.md)
- Failure behaviour, from the same README:
  - "If data cannot be added to the sending queue, it is typically dropped ... when the queue has reached its configured capacity or, for persistent queues, when the underlying storage cannot accept additional data (for example, due to insufficient disk space or I/O errors)."
  - "If data is rejected before entering the queue, it does not reach the exporter retry logic. Such enqueue failures are reported by the `otelcol_exporter_enqueue_failed_*` metrics."
  - Its diagram shows "Permanent → X failure" and "Retry limit exceeded" leading to X (dropped).
- Persistent queue, from the same README:
  - "`storage` (default = none): When set, enables persistence ... There is no in-memory queue when set."
  - "If the collector instance is killed while having some items in the persistent queue, on restart the items will be picked and the exporting is continued."
  - Caveat: "context set by Auth extensions is **not** propagated through the persistent queue".

**file_storage extension**
- `fsync` "will force the database to perform an fsync after each write"; it defaults to `false` in `factory.go`.
- Other keys: `directory` (default `/var/lib/otelcol/file_storage`), `create_directory`, `recreate` (renames a corrupted bbolt DB and creates a new one), and the `compaction.on_start` / `on_rebound` / `max_size` options.
- Sources: [filestorage README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/extension/storage/filestorage/README.md), [factory.go](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/extension/storage/filestorage/factory.go)

**Collector resiliency docs**
- The docs list seven data-loss circumstances:
  1. Network unavailability beyond `max_elapsed_time`.
  2. Queue overflow.
  3. A crash with an in-memory-only queue.
  4. Persistent storage failure or a full disk.
  5. Message queue failure without local buffering.
  6. Misconfiguration.
  7. Disabled resilience.
- On the WAL: "Guarantees might not be as strong as dedicated message queues."
- Recommendations: always use sending queues; monitor `otelcol_exporter_queue_size`, `otelcol_exporter_queue_capacity` and `otelcol_exporter_send_failed_*`; use a WAL on gateways; use Kafka for critical hops.
- Source: [opentelemetry.io/docs/collector/resiliency](https://opentelemetry.io/docs/collector/resiliency/)

**Known open bugs and issues**
- **#15677 (open, 2026-07-28):** "Persistent queue deletes queued items on shutdown while the destination is unavailable". Shutdown drains the queue with retry stopped. If the backend is down, each item "fails once with an ordinary error ... and `itemDispatchingFinish` **deletes it from persistent storage**". The keep-on-shutdown path triggers only when a retry backoff is interrupted. Fix PR #15680 is open. — [issue #15677](https://github.com/open-telemetry/opentelemetry-collector/issues/15677), [PR #15680](https://github.com/open-telemetry/opentelemetry-collector/pull/15680)
- **#7460 (open):** "Ensure reliable data delivery in erroneous situations". It notes that many receivers don't follow the contract that non-permanent errors should be retried, and that acknowledgement and checkpointing are incomplete. — [issue #7460](https://github.com/open-telemetry/opentelemetry-collector/issues/7460)
- **#5902 (open):** "Drain persistent queue on shutdown". — [issue #5902](https://github.com/open-telemetry/opentelemetry-collector/issues/5902)

**Failover connector**
- `priority_levels` with `retry_interval` (default 10m) routes to lower-priority pipelines when a higher level fails. "TBD: `contains` is not honored yet and all errors trigger failover." — [failoverconnector README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/connector/failoverconnector/README.md)

### Inferences

**Body type for raw JSON.** Emit the OCSF event as a structured **Map body** in the OTel log record, or as Bytes containing JSON. Do not use a Str body if you use kafka `raw`, because that path double-encodes strings. Map bodies serialize correctly in kafka `raw`, S3 `body`, HEC event mode and ES `bodymap`.
- Caveat: Go's `encoding/json` on `map[string]any` sorts keys alphabetically. This matters only if downstream signatures are computed over byte order, which is relevant to the 1.9 `record_integrity` attestation `serialization` setting.

**Syslog.** Add a `transform` processor that copies the JSON body into the `message` attribute, then set `protocol: rfc5424`, `enable_octet_counting: true` and TLS.
- The exact OTTL function to serialize a Map to a JSON string was not verified this session; Q4 Gaps lists it.
- Syslog has no application-level acknowledgement, so TCP and TLS success is the strongest "delivered" signal. For SIEMs this makes it the weakest at-least-once option.

**Most reliable raw-JSON paths, in order:**
1. **Kafka**: `encoding: raw`, `required_acks: -1` (all), and the persistent `sending_queue`. Customers' SIEM connectors consume from Kafka, and consumer-side offsets give replay.
2. **Splunk HEC**: event mode with `sourcetype: ocsf:opswat:...` and a persistent queue.
3. **Elasticsearch** `bodymap` with `logs_dynamic_id` set to the OCSF `metadata.uid`, which makes retries idempotent.
4. **S3 (or MinIO)** with `marshaler: body` for NDJSON batches. A separate step converts to Parquet for Security Lake.

**Draft configuration** (keys quoted from the READMEs; values are suggestions):

```yaml
extensions:
  file_storage/q:
    directory: /var/lib/otelcol/q
    fsync: true
    create_directory: true
exporters:
  kafka/ocsf:
    logs:
      encoding: raw
    producer:
      required_acks: -1
    sending_queue:
      storage: file_storage/q
      sizer: items
      queue_size: 5000000
      block_on_overflow: true
    retry_on_failure:
      max_elapsed_time: 0
```

How these settings work:
- `max_elapsed_time: 0` means "retries are never stopped" per the exporterhelper README. Combined with a persistent queue and `block_on_overflow`, data is not dropped because of retry timeouts. Backpressure moves upstream instead, so the receiver must surface refusals to the services that emit events.
- `fsync: true` trades throughput for crash-consistency. The default is `false`.

**Remaining loss windows even with this setup:**
- Permanent errors: HTTP 4xx, oversize events, and HEC empty bodies.
- The shutdown-drain deletion in #15677. For orderly restarts, enable `retry_on_failure` (required for the shutdown-error path) and track the fix.
- Disk exhaustion.
- Data in memory before the persistent enqueue, for example in a `batch` processor. Prefer exporter-level `sending_queue.batch` over a separate batch processor.

**Duplicates.** Retries, and replay after a crash between send and dequeue-ack, make delivery **at-least-once, not exactly-once**. Include a stable `metadata.uid` so SIEMs or consumers can deduplicate.

### Gaps
- I did not verify how exporterhelper handles OTLP partial success (`rejected_log_records`), or whether partially rejected items are counted in `send_failed`.
- I did not verify whether `splunk_hec` supports HEC indexer acknowledgement. A grep of `client.go` found no ack-ID handling, so the exporter appears to treat HTTP 200 as delivered.
- I did not verify the exact OTTL function name for Map-to-JSON-string conversion (needed for the syslog `message` attribute).
- I did not test kafka-exporter idempotent producer settings (`producer` idempotence or `max_in_flight`). The README excerpt reviewed did not list an idempotence key.
- I did not check whether `awss3` honours `sending_queue.storage`. The exporterhelper base suggests it does, but the README only says "disabled" by default.
- There is no built-in Parquet or Security Lake exporter in contrib v0.162.0. I found none in the exporters reviewed and did not scan the full contrib exporter list.

---

## Q5. What approaches exist for end-to-end reconciliation and audit of security event delivery?

### Takeaway
The Collector exposes per-component counters at the default `basic` level, which allow a per-hop count balance:
- `otelcol_receiver_accepted_log_records`
- `otelcol_exporter_sent_log_records`
- `otelcol_exporter_send_failed_log_records`
- `otelcol_exporter_enqueue_failed_log_records`
- `otelcol_exporter_queue_size` and `otelcol_exporter_queue_capacity`

The Collector has **no native dead-letter queue**. The failover connector is the closest substitute. Reconciliation that survives pipeline restarts, and that works on-prem and air-gapped, needs producer-side identity and sequence fields, which OCSF provides. Delivered counts are then computed from those fields at the SIEM and compared with producer-side emitted counts, for example through the `count` connector or application metrics.

The relevant OCSF fields are:
- `metadata.uid` (event UID)
- `metadata.sequence`
- `metadata.correlation_uid`
- `metadata.processed_time` and `metadata.logged_time`
- the 1.9 `record_integrity` profile's `prev_event` and `chain_uid` hash chain

### Cited Findings

**Collector internal metrics**
- `basic`-level metrics include:
  - `otelcol_exporter_enqueue_failed_log_records` ("Number of logs that exporter(s) failed to enqueue")
  - `otelcol_exporter_in_flight_requests`
  - `otelcol_exporter_queue_capacity` and `otelcol_exporter_queue_size` (in batches)
  - `otelcol_exporter_send_failed_log_records`
  - `otelcol_exporter_sent_log_records` ("successfully sent to destination")
  - `otelcol_processor_incoming_items` and `otelcol_processor_outgoing_items`
  - `otelcol_receiver_accepted_log_records` and `otelcol_receiver_refused_log_records`
- On interpretation: "These metrics do not inherently imply data loss since there could be retries." For data flow, ingress is measured by `otelcol_receiver_accepted_*` and egress by `otelcol_exporter_sent_*`. Check the logs for "Dropping data because sending_queue is full".
- Source: [Collector internal telemetry](https://opentelemetry.io/docs/collector/internal-telemetry/)

**Collector components that help**
- The `count` connector "can be used to count spans, span events, metrics, data points, and log records". For logs the default metric is `log.record.count`. — [countconnector README @v0.162.0](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/connector/countconnector/README.md)
- The failover connector routes data to lower-priority pipelines when a higher-priority pipeline errors. — [failoverconnector README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/connector/failoverconnector/README.md)
- No DLQ feature exists. A search of `open-telemetry/opentelemetry-collector` issues for "dead letter" returned no dedicated DLQ feature. — [GitHub issue search](https://github.com/open-telemetry/opentelemetry-collector/issues?q=%22dead+letter%22)
- The exporterhelper `send_failed` and `enqueue_failed` counters are the drop signals. Permanent errors and retry exhaustion end in drop. — [exporterhelper README](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.162.0/exporter/exporterhelper/README.md)

**OCSF fields for reconciliation**
- `metadata.uid`: "A unique identifier assigned to the OCSF event ... distinct from the original event identifier in the source system (see `original_event_uid`)."
- `metadata.sequence`: "Sequence number of the event ... to make the exact ordering of events unambiguous."
- `metadata.correlation_uid`: links related OCSF events.
- `metadata.logged_time`: "The ultimate logged time in the event pipeline - when the event reached its final destination (e.g., SIEM, data lake)".
- `metadata.processed_time`: "when the event was processed by an intermediate system ... Can be used with `logged_time` to calculate queuing duration via `total_queued_duration`".
- Sources: [metadata.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/objects/metadata.json), [dictionary.json](https://github.com/ocsf/ocsf-schema/blob/1.9.0/dictionary.json)
- 1.9.0 `record_integrity` profile: an "`attestation` object carrying a `fingerprint` of and digital `signatures` over an event, with optional tamper-evident chain attributes (`prev_event`, `chain_uid`) and an `authority_uid`". `prev_event` "referenc[es] the previous event in a tamper-evident chain by its `fingerprint` ... together with `uid` and `type_uid`". `serialization` and `serialization_id` "record the canonical serialization or signing-envelope scheme". — [CHANGELOG v1.9.0](https://github.com/ocsf/ocsf-schema/blob/1.9.0/CHANGELOG.md) (PRs #1661, #1662)

**Destination-side helpers**
- Elasticsearch: `logs_dynamic_id` with an `elasticsearch.document_id` attribute makes retried writes overwrite rather than duplicate. — [elasticsearchexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/elasticsearchexporter/README.md)
- Kafka: `message_key_from_metadata_key` and the partition options give per-key ordering. — [kafkaexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/kafkaexporter/README.md)
- Splunk HEC: `heartbeat/interval` sends heartbeats, and `telemetry/enabled` exposes exporter heartbeat metrics (`otelcol_exporter_splunkhec_heartbeats_sent` and `_failed`). — [splunkhecexporter README](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/v0.162.0/exporter/splunkhecexporter/README.md)

### Inferences

**A practical reconciliation design** for SaaS and for on-prem or air-gapped deployments (none of these steps needs an external service):

1. **At the producer**, each service stamps:
   - `metadata.uid` (UUIDv7),
   - `metadata.sequence` (a monotonic counter per `(tenant, service instance, stream)`),
   - `metadata.correlation_uid` (scan or job ID linking 6007, 2004, 2006 and 7002 events from one file).

   The service increments a local "emitted" counter metric per class_uid and tenant, and exports it over OTel metrics.
2. **In the Collector**:
   - Use a `count` connector after the receiver, keyed by attributes such as `class_uid`, tenant and stream, to produce "accepted" counts.
   - Use `otelcol_exporter_sent_log_records` and `send_failed`/`enqueue_failed`, labelled by exporter, as per-hop counters.
   - Alert on `enqueue_failed > 0`, on `send_failed` growth without matching later `sent` growth, and on `queue_size/queue_capacity` approaching 1.
3. **At the destination**, run a periodic query, for example a Splunk saved search or a SIEM/ES aggregation over `metadata.sequence` per stream. It finds gaps (missing sequence numbers) and duplicates (repeated `metadata.uid`), and compares counts per time window against the producer's emitted-counter metric. `metadata.logged_time` minus `time` gives the end-to-end latency SLO.
4. **For tamper-evident audit** (useful for regulated or air-gapped customers), use the 1.9 `record_integrity` profile: `chain_uid` per stream plus `prev_event.fingerprint`. Any deleted or altered record breaks the chain, which can be verified offline. This collides with Security Lake's OCSF 1.3 or earlier limit, so the Security Lake copy would drop these fields or move them into an extension.
5. **DLQ substitute.** The Collector has no DLQ, so:
   - route permanent-error-prone exports through a failover connector to a local `file` exporter or a separate Kafka topic,
   - keep the primary persistent queue large,
   - treat any `send_failed` without later recovery as a reconciliation incident.

   Note that the failover connector triggers on any error and does not by itself capture the individual records that were dropped as permanent errors inside an exporter. Those still need the producer-side sequence-gap detection in step 3.

**Air-gapped specifics.** All required components run offline: Kafka, MinIO through `awss3` with `endpoint` and `s3_force_path_style`, `file_storage`, a private `ocsf-server` Docker image for schema browsing and validation, and `ocsf-toolkit` for in-pipeline validation.

### Gaps
- I found no official OTel guidance titled "end-to-end reconciliation" or "audit" for log delivery. The resiliency and internal-telemetry pages cover only monitoring signals.
- I did not verify whether `otelcol_exporter_sent_log_records` counts records acknowledged by the backend as partially rejected.
- I did not check the label sets (for example `exporter`, `data_type`) and the `normal` versus `detailed` level details beyond the `basic` table.
- I found no SIEM vendor documentation on native sequence-gap detection for OCSF `metadata.sequence`.
