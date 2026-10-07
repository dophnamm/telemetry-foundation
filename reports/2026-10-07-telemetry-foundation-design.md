# Telemetry Foundation: Design Spec

| | |
|---|---|
| **Ngày** | 2026-10-07 |
| **Trạng thái** | Draft v2, chờ team review |
| **Team** | Telemetry/Observability & Diagnostic/Support Package |
| **Phạm vi spec này** | Dự án con số 1, "Nền móng": Telemetry Standard và SDK framework |
| **Tài liệu liên quan** | [Tổng hợp nghiên cứu observability](./Tổng%20hợp%20nghiên%20cứu%20observability.md) · [Nghiên cứu bổ sung kiến trúc telemetry](./Nghiên%20cứu%20bổ%20sung%20kiến%20trúc%20telemetry.md) |

Các điểm đánh dấu **[Mới, cần duyệt]** là phần chưa được duyệt trong buổi thiết kế:
- Vòng 1 lấy từ báo cáo "Tổng hợp nghiên cứu observability".
- Vòng 2 lấy từ báo cáo "Nghiên cứu bổ sung kiến trúc telemetry", cộng một số đề xuất của Claude.

Danh sách thay đổi vòng 2 và các đề xuất không áp dụng nằm ở **mục 14**. Mọi nội dung về license chỉ là câu hỏi cho legal, không phải kết luận pháp lý.

---

## 1. Bối cảnh và mục tiêu

Công ty đang xây một platform mới, dùng chung cho nhiều product. Team cần một **chuẩn telemetry chung cho cả công ty**. Chuẩn này phải gắn được vào từng product, và cũng phải cho một góc nhìn tổng hợp.

Sáu định hướng của team:

1. Telemetry framework là một phần của platform, mang đủ thông tin bắt buộc, có metrics, logs và traces, được lưu tập trung.
2. Cấu hình log level cho từng service.
3. Dịch vụ log tập trung, có UI để khách hàng tự tìm log và tự xử lý sự cố. Có self-healing bằng AI.
4. Luôn ghi log ở mức debug, chỉ giữ 15 phút gần nhất (sliding window).
5. Tạo support package, gửi về OPSWAT hoặc xuất ra shared folder khi khách hàng air-gapped.
6. Dùng định dạng OCSF cho audit event và file processing event.

**Thành công được đo bằng:**
- Mọi service của platform phát telemetry có đủ attribute bắt buộc. Metric `telemetry.noncompliant` bằng 0 ở các service đã onboard.
- Khi có sự cố, lấy được log debug của 15 phút trước sự cố, kể cả khi app đã crash.
  - **[Mới, cần duyệt]** Ngoại lệ đã biết: trên đường OTLP, các bản ghi còn trong hàng đợi SDK lúc crash có thể mất. Hàng đợi tối đa 2048 bản ghi, chu kỳ export 1 giây. Giảm thiểu bằng cách flush trong handler FATAL/panic (6.4). Đường stdout thì không mất phần này.
- Đổi log level của một service có hiệu lực trong dưới 10 giây, không phải restart.
- Audit event và file processing event tới SIEM của khách và không bị mất. Việc không mất được kiểm chứng bằng đối soát `metadata.sequence` (9.4).
  - **[Mới, cần duyệt]** Event phải hợp lệ theo OCSF 1.9.0, đồng thời **chỉ dựa vào tập trường lõi tương thích OCSF 1.3**, để SIEM thực tế đọc được.
- **[Mới, cần duyệt]** Có hai ngân sách CPU, đều phải đo trong Phase 0:
  - **App**: CPU trong cgroup của app tăng thêm dưới 5%, so với cùng service đó khi tắt telemetry, ở cùng mức tải.
  - **Node**: tổng CPU dùng cho telemetry của agent, containerd và kubelet tạm đặt **≤ 0.5 core mỗi node**. Theo báo cáo, agent tốn khoảng 0.2–0.5 core cho mỗi ~11 nghìn dòng/giây. Con số chính thức chốt sau Phase 0.

## 2. Các quyết định đã chốt

| # | Chủ đề | Quyết định | Lý do |
|---|---|---|---|
| D1 | Mục tiêu | Dựng hệ thống observability, áp dụng thành chuẩn chung của công ty | Nhiều product dùng chung một platform |
| D2 | Hosting | Self-host, dữ liệu không rời hạ tầng nếu không được phép | Yêu cầu bảo mật |
| D3 | Môi trường chạy | Kubernetes, 20–100 service | |
| D4 | Ngôn ngữ của platform mới | Go, C/C++/Rust, Java/.NET, Node.js | |
| D5 | Triển khai | Có cả bản on-prem tại khách, kể cả air-gapped | Kit phải tự chạy được, không cần hub |
| D6 | Phone-home | "Có thể có": thiết kế sẵn, **mặc định tắt**, khách tự bật, chỉ gửi metrics tổng hợp. **[Mới, cần duyệt]** Với khách air-gapped, metrics tổng hợp có thể đi kèm support bundle thay cho phone-home | Chờ legal và security chốt |
| D7 | Kiến trúc | Phương án A: OTel SDK, Collector hai tầng, Helm kit có `mode: hub \| standalone`, hub multi-tenant (mỗi product là một tenant). **[Mới, cần duyệt]** Backend của kit standalone **mặc định dùng stack Apache 2.0/MIT**. Grafana chỉ là add-on tuỳ chọn, không sửa đổi. Hub do OPSWAT tự vận hành vẫn có thể dùng Grafana stack (chờ legal xác nhận, L7) | Không phụ thuộc vendor; rủi ro AGPL chỉ tập trung ở phần ship tới khách |
| D8 | Debug 15 phút | **Luôn ghi debug** vào ring buffer, kiểu hộp đen máy bay | Có ngữ cảnh *trước* sự cố |
| D9 | Vị trí logic | Phương án A: SDK mỏng, logic nằm ở Collector agent | Buffer vẫn còn khi app crash, với phần dữ liệu đã tới agent (xem §1); chỉ viết một lần bằng Go |
| D10 | Snapshot | Giữ thêm snapshot 24 giờ khi có FATAL hoặc lỗi tăng đột biến | Support package tạo sau sự cố vẫn có dữ liệu |
| D11 | Dung lượng buffer | Mặc định tối đa 2 GiB mỗi node, chỉnh được. **[Mới, cần duyệt]** Chia công bằng theo service, và luôn giữ tối thiểu 15% disk trống | Một pod ồn ào không được làm co cửa sổ của mọi pod khác, và không được đẩy node tới ngưỡng eviction |
| D12 | Tenant | Chưa thêm `opswat.tenant.id` | Bổ sung khi platform có multi-tenant |
| D13 | Event cho file sạch | Mặc định không sinh event riêng cho từng file; bật được bằng cấu hình | Tránh bùng nổ dung lượng; khớp ngữ nghĩa OCSF, vì verdict sạch thuộc về Scan Activity |

## 3. Phạm vi

**Trong spec này:** F1 (Telemetry Standard), F2 (lớp SDK), F3 (Collector agent), F4 (điều khiển log level), F5 (OCSF events).

**Ngoài spec này** (mỗi mục sẽ có spec riêng, xem mục 12):
- Gateway và backend lưu trữ: chọn backend, kèm quyết định về license
- Hub và phone-home
- Diagnostic service và support package
- Customer Log UI, xuất event ra SIEM ở mức sản phẩm
- AI self-healing

## 4. Kiến trúc tổng

```
 CLUSTER CỦA PLATFORM (tại khách hoặc của OPSWAT)              HUB (OPSWAT)
┌───────────────────────────────────────────────┐
│ Pods ── OTel SDK / auto-inject (Operator)     │
│   │ OTLP :4317   OCSF :4319   stdout (Node.js)│
│   ▼                                           │
│ Collector AGENT (DaemonSet)        ← spec này │
│   flightrecorder (15 phút) · levelfilter      │
│   OCSF pipeline riêng · k8sattributes         │
│   ▼                                           │   mode: hub    ┌──────────────────────┐
│ Collector GATEWAY (Deployment)                │──────────────▶ │ Hub gateway (auth)   │
│   sampling · che PII khi rời site · định tuyến│                │ metrics/logs/traces  │
│   │ mode: standalone                          │                │ Grafana tổng         │
│   ▼                                           │  phone-home    │                      │
│ Backend tại chỗ (mặc định Apache 2.0) + UI    │─ ─ ─ ─ ─ ─ ─▶  │ (opt-in, metrics)    │
│ SIEM của khách                                │                └──────────────────────┘
└───────────────────────────────────────────────┘
```

- Code app giống hệt nhau ở cả hai mode. Chỉ đích gửi của gateway thay đổi.
- Mode được chọn bằng một giá trị Helm duy nhất là `mode`.
- **[Mới, cần duyệt]** Event OCSF đi qua cổng riêng `:4319`, với LoggerProvider và hàng đợi riêng ở SDK, rồi receiver và pipeline riêng ở agent (6.2, 7.2). Như vậy một đợt log debug tăng vọt không đẩy được audit event ra khỏi hàng đợi.

## 5. F1: Telemetry Standard

### 5.1 Attribute bắt buộc

| Attribute | Ví dụ | Ai gắn |
|---|---|---|
| `service.name` | `scan-engine` | Helm, qua `OTEL_RESOURCE_ATTRIBUTES` / `OTEL_SERVICE_NAME` |
| `service.version` | `2.4.1` | Helm, lấy từ image tag |
| `deployment.environment.name` | `prod` | Helm |
| `opswat.product` | `metadefender-core` | Helm |
| `opswat.deployment.id` | UUID ẩn danh, mỗi bản cài một giá trị | Sinh ra lúc cài. **Không chứa tên khách hàng** |
| `opswat.deployment.mode` | `saas`, `onprem` hoặc `airgap` | Helm |
| `k8s.namespace.name`, `k8s.pod.name`, `k8s.node.name`... | | Agent gắn qua `k8sattributes` (đã có bản v1.0.0) |

Gateway kiểm tra các attribute bắt buộc. Dữ liệu thiếu attribute **vẫn được nhận**, nhưng bị đếm vào `telemetry.noncompliant{service.name}`.

### 5.2 Quy ước

1. **Metrics**: theo OTel semantic conventions. Metric riêng có dạng `opswat.<domain>.<tên>`, dùng đơn vị UCUM, ví dụ `opswat.scan.duration` tính bằng giây.
2. **Logs**: có cấu trúc, dùng `severity_number` chuẩn của OTel (TRACE=1, DEBUG=5, INFO=9, WARN=13, ERROR=17, FATAL=21). Log nằm trong một span thì phải có `trace_id` và `span_id`.
3. **Spans**: tên ngắn, ít biến thể, ví dụ `POST /scan` hay `scan file`. Không đưa ID vào tên span.
4. **Events**: phát qua Logs API, **không dùng** `Span.AddEvent` hay `Span.RecordException`, vì OTel đã công bố deprecate Span Events API. Event OCSF có `event.name = ocsf.<class>`, xem F5.
5. **Dữ liệu nhạy cảm** (tên file, email, IP, username):
   - Trong site của khách: giữ nguyên, để khách tự tìm log.
   - Khi **rời khỏi site** (support package, phone-home): bị hash hoặc che ở gateway.
   - **[Mới, cần duyệt]** Buffer và snapshot của `flightrecorder` vì thế chứa PII thô trên hostPath, không được mã hoá. Đây là rủi ro R8 và cần security review.

### 5.3 Quản trị chuẩn

- **Ghim phiên bản semconv ở 1.44.0** (phát hành 2026-08-04). Muốn nâng phiên bản thì phải có changelog. Bản 1.44.0 đã có breaking change, ví dụ `k8s.pod.memory.usage` chuyển sang updowncounter, nên ghim là bắt buộc.
- **[Mới, cần duyệt] Chính sách chuyển đổi.** Trong một cửa sổ chuyển đổi, bật:
  - `OTEL_SEMCONV_STABILITY_OPT_IN=database/dup,code/dup`
  - `OTEL_SEMCONV_EXCEPTION_SIGNAL_OPT_IN=logs/dup`

  Trong thời gian đó, dashboard phải đọc được cả tên cũ lẫn tên mới. Java agent 3.0 (dự kiến 10/2026) đổi `db.system` thành `db.system.name` và `db.statement` thành `db.query.text`.
- **[Mới, cần duyệt] Ghim phiên bản image auto-instrumentation** trong Instrumentation CR. Nếu không ghim, Operator có thể tự nâng image Java lên 3.x.
- **Định nghĩa các attribute `opswat.*` bằng OTel Weaver** (registry YAML). Weaver sinh tài liệu và sinh hằng số cho 6 ngôn ngữ dưới dạng **code sinh sẵn**, không phải wrapper chạy lúc runtime. Weaver cũng chạy "live check" trong conformance test (mục 10).

## 6. F2: Lớp SDK `opswat-telemetry`

### 6.1 Nguyên tắc
- **Không bọc OTel API.** Code app gọi trực tiếp OTel API và logger quen thuộc của từng ngôn ngữ. Đây là kết luận của bài "Don't Wrap OpenTelemetry" (OTel blog, 2026-06-24). Bài này nói rõ: "shared helpers that configure the SDK… That's infrastructure setup, not an API wrapper".
- `opswat-telemetry` chỉ gồm 3 phần: **cấu hình mặc định**, **bước khởi tạo**, và **builder OCSF**.
- **[Mới, cần duyệt]** Builder OCSF và hằng số Weaver phải là code sinh tự động, gọi thẳng Logs API, và không nhận collection ở mỗi lần gọi. Đây là ngoại lệ hợp lệ mà bài viết nêu ra.
- **[Mới, cần duyệt] Declarative config** (`OTEL_CONFIG_FILE`): **chỉ spec và schema là stable** (spec v1.55.0 và schema 1.0.0, từ 3/2026). **Loader ở mọi ngôn ngữ vẫn experimental**:
  - Go `otelconf` v0.27.0
  - Java 1.66.0-alpha
  - C++ phải bật lúc build
  - Node.js 0.223.0
  - .NET chưa phát hành
  - Rust chưa có

  Vì vậy:
  - Ghim `file_format: "1.0"`, mức mà mọi ngôn ngữ có loader đều đọc được.
  - Ghim phiên bản loader trong bước khởi tạo.
  - **Giữ đường env var `OTEL_*`**, bắt buộc với Rust và .NET.
  - Đưa file YAML vào pod bằng mount ConfigMap kèm env `OTEL_CONFIG_FILE` trong pod spec. Cơ chế này phải được kiểm tra với từng agent được Operator inject, vì tài liệu Operator chưa đề cập.

### 6.2 Trách nhiệm
1. **Khởi tạo**: tạo đủ 3 provider. Đích OTLP là `$(HOST_IP):4317`, tức agent trên cùng node, lấy địa chỉ qua Downward API.
   - **[Mới, cần duyệt]** Tạo thêm **một LoggerProvider riêng cho OCSF**, gửi tới `$(HOST_IP):4319`, có hàng đợi riêng.
2. **Nối logger vào OTel, luôn ở mức DEBUG.** Phải theo các quy định riêng của từng ngôn ngữ trong bảng 6.3.
3. **Auto-instrumentation [Mới, cần duyệt]:**
   - OTel Operator inject cho **Java, .NET và Node.js** (mặc định bật ở Operator v0.160.0). Ghim phiên bản image.
   - **Go không inject qua Operator**, vì sidecar eBPF cần `privileged: true` và không qua được Pod Security Admission ở mức restricted. Go gắn thư viện instrumentation. **Go compile-time instrumentation** (stable v1 từ 2026-07-16) là lựa chọn zero-code lúc build, sẽ đánh giá trong pilot.
   - C++ và Rust gắn thư viện instrumentation cho HTTP/gRPC. OBI có thể bổ sung RED metrics khi lên 1.0. Hiện OBI ở v1.0.0-rc.1, và với C/C++/Rust chỉ thấy được ở tầng giao thức mạng.
4. **Builder OCSF** sinh tự động từ schema (9.3).
5. **Van an toàn**: biến `OPSWAT_TELEMETRY_MIN_LEVEL`, mặc định `DEBUG`. Đây là núm chỉnh log level duy nhất nằm trong app, chỉ dùng khi log debug làm tốn CPU quá mức. Đổi giá trị cần rolling restart. Đề xuất cho đổi lúc đang chạy không được áp dụng, lý do ở mục 14.2.

### 6.3 Đường đi của log theo từng ngôn ngữ **[Mới, cần duyệt]**
Trạng thái tại ngày 2026-10-07, lấy từ README và CHANGELOG của từng repo. Trang Language Status đang chậm hơn repo với Go và Rust.

| Ngôn ngữ | Trạng thái logs | Phần còn 0.x / alpha | Đường đi | Quy định bắt buộc |
|---|---|---|---|---|
| Java | API/SDK Stable từ 1.27.0 (2023) | Appender Log4j/Logback `2.32.0-alpha` | Logback/Log4j → Java agent → OTLP | Tắt lấy caller location (chậm 30–100 lần). Log4j2 async **mặc định chặn khi đầy**, nên bắt buộc dùng chính sách Discard |
| Go | **API/SDK Stable từ v1.47.0** (2026-10-02) | OTLP log exporter v0.23.0, `otelslog` v0.21.0 | `slog` hoặc zap → `otelslog`/`otelzap` → OTLP | Ghim phiên bản các module experimental. Dùng handler nhanh (zap) |
| Node.js | Development (cả API và SDK) | Mọi bridge (pino, winston, bunyan) đều 0.x | **JSON ra stdout → `filelog`** | Dùng pino, đẩy transport sang worker thread. Baseline Node ≥ 22.15.0 (để dùng JS SDK 3.x) |
| .NET | **Stable qua `ILogger`** | Logs Bridge API chỉ có trong pre-release | `ILogger` → `WithLogging` → OTLP | Bắt buộc `[LoggerMessage]` (source generator). Builder OCSF nhắm vào `ILogger` |
| C++ | **Stable** cả 3 signal | Bridge spdlog/glog chưa công bố mức trưởng thành | OTLP qua Logs API, **hoặc** stdout + async logger. Phase 0 chọn | Hàng đợi phải có drop, ví dụ spdlog `overrun_oldest` hoặc hàng đợi drop của Quill |
| Rust | Stable theo README, Beta theo trang status; crate 0.33.0 | Traces Beta, OTLP log exporter RC | `opentelemetry-appender-tracing` → OTLP | Ghim phiên bản crate. Dùng `release_max_level_debug` |

Benchmark của các thư viện log đều do chính tác giả thư viện chạy, nên chỉ dùng để xếp hạng, không dùng để dự đoán % CPU.

Lưu ý cho đường stdout (Node.js, có thể cả C++):
- Kubelet giữ tối đa 10 MiB × 5 file = 50 MiB cho mỗi container. Ở tốc độ 80 KB/s, con số này chỉ tương đương **khoảng 10 phút**. Agent ngừng đọc lâu hơn thế thì log mất.
- CPU của `filelog` tăng theo số file đang theo dõi. Chỉ theo dõi namespace của platform.

### 6.4 Khi gặp lỗi **[Mới, cần duyệt]**
Nguyên tắc: **bỏ log DEBUG thay vì chặn app**. Latency của app quan trọng hơn việc giữ đủ từng dòng debug.

| Đường đi | Cách hỏng | Xử lý |
|---|---|---|
| OTLP | BatchProcessor **không chặn**, nhưng **bỏ dữ liệu không báo** khi đầy (mặc định 2048 bản ghi, khoảng 0.2 giây ở 10k bản ghi/giây) | Nâng `OTEL_BLRP_MAX_QUEUE_SIZE`, giá trị chốt ở Phase 0. Gọi `ForceFlush` trong handler FATAL/panic/uncaught exception trước khi process thoát |
| Log4j2 async | Mặc định **chặn caller** khi hàng đợi đầy | Bắt buộc chính sách Discard (6.3) |
| stdout | Giữ được dữ liệu khi app crash, nhưng **có thể chặn app** khi runtime không đọc kịp pipe | Phase 0 tiêm lỗi để đo mức ảnh hưởng tới p99 |
| OCSF | Dùng chung hàng đợi với log debug thì có thể bị bỏ | LoggerProvider riêng (6.2). Phase 0 kiểm tra không mất event khi debug tăng 10 lần |

Không có nguồn nào xác nhận SDK của từng ngôn ngữ tự phát metric về số bản ghi bị bỏ. Vì vậy `telemetry.dropped{signal}` sẽ được tự đếm trong bước khởi tạo, ở những chỗ SDK không cung cấp sẵn.

### 6.5 Đóng gói
- Phát hành đồng bộ phiên bản qua Go module, Maven, NuGet, npm, CMake/vcpkg và crates.io.
- **[Mới, cần duyệt]** Ghim phiên bản mọi dependency còn 0.x/alpha/experimental. CI có bước kiểm tra riêng mỗi khi nâng các dependency này.

## 7. F3: Collector agent

### 7.1 Build
Collector được build bản riêng bằng OCB. Bản này gồm component chuẩn của core/contrib, cộng **2 component tự viết bằng Go**:
- `flightrecorder`: exporter kèm extension để đọc dữ liệu.
- `levelfilter`: processor (xem F4).

Báo cáo bổ sung xác nhận **không có component upstream nào xoá log theo cửa sổ thời gian**, nên tự viết là bắt buộc. Các phần còn lại dùng lại:
- pdata và zstd để ghi segment
- `redaction`/`transform` nếu cần che PII
- `file_storage` cho hàng đợi

### 7.2 Pipeline **[Mới, cần duyệt]**

```
[otlp :4317]  [filelog: namespace platform]     [otlp/ocsf :4319]        [kubeletstats/hostmetrics]
      │                 │                              │                           │
      ▼                 ▼                              ▼                           │
 memory_limiter → k8sattributes → resource     k8sattributes → resource            │
      │                                                │                           │
 routing connector (logs)                       logs/ocsf → exporter OCSF          │
      ├──▶ logs/flight : MỌI log → flightrecorder     (sending_queue.batch,         │
      └──▶ logs/app    : levelfilter → otlp(gateway)   file_storage fsync, retry ∞) │
 traces, metrics ───────────────────────────────────────▶ batch → otlp(gateway) ◀───┘
```

- **Event OCSF có receiver riêng.** Khi pipeline OCSF tắc, backpressure không dồn ngược qua routing connector sang log thường, và ngược lại.
- Pipeline `logs/ocsf` **bỏ `batch` processor** và dùng `sending_queue.batch` ở exporter. Nếu dùng `batch` processor, dữ liệu nằm trong memory trước khi vào hàng đợi persistent.
- Mỗi signal có **pipeline và hàng đợi riêng**, theo bài học từ Adobe.
- Có `memory_limiter` ngay từ ngày đầu, theo lời khuyên của Skyscanner.

Cấu hình phác thảo cho `logs/ocsf`. Tên key lấy từ README Collector v0.162.0; giá trị là đề xuất:

```yaml
extensions:
  file_storage/ocsf:
    directory: /var/lib/otelcol/ocsf
    fsync: true                  # mặc định false
exporters:
  otlp/ocsf:
    sending_queue:
      storage: file_storage/ocsf
      sizer: items
      block_on_overflow: true    # dồn backpressure về SDK thay vì drop
      batch: {}                  # batch ở mức exporter
    retry_on_failure:
      max_elapsed_time: 0        # không bao giờ ngừng retry
```

### 7.3 `flightrecorder`
1. **Lưu trữ**: thư mục hostPath `/var/lib/opswat-telemetry/flight`. Định dạng OTLP protobuf, nén zstd.
   - **[Mới, cần duyệt]** Mỗi segment ứng với **một service trong một phút**, để chia quota và đọc theo service.
   - Extension đọc phải tự parse, vì `otlpjsonfile` chỉ đọc JSON không nén.
2. **Xoá dữ liệu cũ**: xoá segment cũ hơn `window` (mặc định 15 phút). **[Mới, cần duyệt]** Thêm hai cơ chế:
   - **Chia công bằng**: khi chạm `maxSizePerNode` (mặc định 2 GiB), xoá trước segment cũ nhất của service đang dùng nhiều hơn phần chia đều. Ý tưởng này lấy từ "weighted fair sharing" của Hindsight. Có thể đặt thêm quota cứng cho từng service.
   - **Disk trống tối thiểu** `minFreeDiskPercent: 15`, cao hơn ngưỡng eviction cứng của kubelet (`nodefs.available<10%`). Đã xoá tới mức không còn gì mà vẫn thiếu thì ngừng ghi và tăng `flightrecorder.write_suspended`. Recorder không bao giờ được là nguyên nhân gây sự cố.
   - Metric: `flightrecorder.evicted_bytes{service, reason}`, và số byte thực lưu cho mỗi bản ghi (dùng để đo R7).
3. **[Mới, cần duyệt] Độ bền dữ liệu.** Segment của phút hiện tại nằm trong memory:
   - fsync theo chu kỳ, mặc định 5 giây.
   - **fsync ngay khi gặp FATAL**, giống cách journald làm với CRIT/ALERT/EMERG.
4. **API đọc**: `GET /flight?service=&from=&to=`, chỉ truy cập trong cluster. Xác thực bằng ServiceAccount token (TokenReview), chỉ ServiceAccount của Diagnostic service được phép gọi.
   - **[Mới, cần duyệt]** Diagnostic **chỉ đọc buffer qua API này**. Không dùng `copyFromHost` của Replicated troubleshoot cho thư mục flight, vì như vậy sẽ đi vòng qua bước xác thực và lọc.
5. **Snapshot** (D10), giữ 24 giờ, trong thư mục `snapshots/`.
   - Điều kiện kích hoạt mặc định: có log FATAL, hoặc một service có ≥ 50 log ERROR trong 1 phút, hoặc được gọi thủ công qua API.
   - **[Mới, cần duyệt]** Theo prior art (Perfetto `CLONE_SNAPSHOT`, `JFR.dump`, Hindsight):
     - **Hard-link** segment thay vì chép, để không nhân đôi I/O.
     - **Đợi `stopDelay`** (mặc định 10 giây) sau trigger rồi mới đóng băng, để có cả ngữ cảnh ngay sau lỗi.
     - Giới hạn tần suất **theo từng loại trigger**, và tối đa 48 lần mỗi 24 giờ trên mỗi node. Giới hạn này cộng thêm vào giới hạn cũ: 1 lần mỗi service trong 10 phút, 20 snapshot mỗi node.
     - Snapshot có **giới hạn dung lượng riêng**, mặc định 2 GiB, và tính chung vào ngưỡng disk trống tối thiểu. Đây là đề xuất của Claude: hard-link vẫn giữ chỗ trên disk sau khi segment gốc đã bị xoá.
   - Ngưỡng sẽ chỉnh lại sau pilot.
6. Mỗi agent chỉ giữ buffer của các pod trên node của nó. Diagnostic service gom từ mọi agent (spec riêng).
7. Ngữ cảnh runtime (Go FlightRecorder, JFR `maxage=15m`, dotnet-monitor), kích hoạt theo cùng trigger, có thể bổ sung sau. Không thuộc phạm vi Nền móng.

### 7.4 Cấu hình Helm (phác thảo)

```yaml
mode: standalone              # hub | standalone
flightRecorder:
  window: 15m
  maxSizePerNode: 2Gi
  fairShare: true             # [Mới] chia đều theo service
  perServiceQuota: {}         # [Mới] tuỳ chọn, ví dụ { scan-engine: 512Mi }
  minFreeDiskPercent: 15      # [Mới]
  fsyncInterval: 5s           # [Mới]; luôn fsync ngay khi có FATAL
  snapshot:
    enabled: true
    retention: 24h
    stopDelay: 10s            # [Mới]
    errorSpikeThreshold: 50   # số log ERROR trong 1 phút
    maxPerNode: 20
    maxPer24h: 48             # [Mới]
    maxSizePerNode: 2Gi       # [Mới]
ocsf:
  port: 4319                  # [Mới]
  emitCleanFileEvents: false
  sinks: []                   # kafka | splunk_hec | s3 | syslog | elasticsearch | file
phoneHome:
  enabled: false
```

### 7.5 Khi gặp lỗi **[Mới, cần duyệt]**

| Tình huống | Log thường | OCSF |
|---|---|---|
| Gateway không truy cập được | Hàng đợi trên disk, fsync tắt. Có thể mất phần chưa fsync nếu agent restart (bug contrib #50102). Chấp nhận được với log thường | Hàng đợi trên disk, fsync bật, retry vô hạn, `block_on_overflow` dồn backpressure về SDK |
| Agent quá tải | `memory_limiter` từ chối nhận, SDK bỏ bớt dữ liệu (6.4) | Receiver riêng; SDK retry trong giới hạn hàng đợi riêng |
| Agent restart | Buffer còn trên hostPath; có thể mất tối đa một chu kỳ fsync của segment hiện tại | Bug collector #15677: persistent queue có thể xoá item khi shutdown lúc đích không truy cập được. Phát hiện bằng đối soát (9.4) |
| Disk đầy | `flightrecorder` xoá theo thứ tự ở 7.3 mục 2 | `file_storage` từ chối ghi, dữ liệu mới nhất bị bỏ. Phát hiện bằng đối soát |
| App crash | OTLP: mất phần còn trong hàng đợi SDK. stdout: không mất | `ForceFlush` trong handler; phần còn lại phát hiện bằng đối soát |
| Lỗi permanent (4xx, event quá lớn) | Bỏ | Bị bỏ, đếm lại, phát hiện bằng đối soát |

Tài liệu Collector cũng ghi rằng WAL "Guarantees might not be as strong as dedicated message queues". Vì vậy đối soát ở 9.4 là cơ chế phát hiện mất dữ liệu bắt buộc, không phải tuỳ chọn.

## 8. F4: Điều khiển log level

Log level quyết định **những log nào được đẩy lên kho trung tâm**. Ring buffer luôn có đủ log debug, bất kể level đang đặt là gì.

```yaml
# ConfigMap: telemetry-log-levels
default: INFO
services:
  scan-engine:
    level: INFO
    scopes:
      com.opswat.parser: DEBUG          # theo tên logger (InstrumentationScope)
  api-gateway:
    level: DEBUG
    expiresAt: 2026-10-08T10:00:00Z     # tự về default khi hết hạn
```

1. Processor `levelfilter` theo dõi ConfigMap qua K8s informer. Thay đổi có hiệu lực trong **dưới 10 giây**, không cần restart. Agent cần quyền RBAC `get/watch` trên ConfigMap này.
2. Lọc theo `service.name`, rồi theo scope (tên logger), rồi theo `severity_number`. Log không có severity, ví dụ dòng stdout parse không được, được tính là INFO.
3. Chỉ admin mới được đổi, qua API, CLI hoặc UI của platform (RBAC). **Mỗi lần đổi sinh một audit event OCSF**, class API Activity (6003).
4. Event OCSF đi pipeline riêng, không bao giờ qua `levelfilter`.
5. Khi gặp lỗi:
   - ConfigMap sai cú pháp: giữ cấu hình hợp lệ gần nhất, tăng `levelfilter.config_errors`.
   - Mất kết nối tới K8s API: dùng cấu hình đã biết gần nhất.
6. Chưa dùng OpAMP: spec đang Beta, phải dựng thêm server, và OpAMP không có TTL cho log level, nên `expiresAt` dù sao cũng phải tự viết.
   - **[Mới, cần duyệt]** Khi `levelfilter` cần một định dạng chuẩn, bám theo Telemetry Policy (OTEP 4738, đã merge, có sẵn ví dụ policy "drop-debug-logs").

## 9. F5: OCSF events

**[Mới, cần duyệt]** Tách hai khái niệm:
- **Phiên bản dùng để soạn** là OCSF 1.9.0 (phát hành 2026-08-03), ghi chính xác trong `metadata.version`.
- **Cam kết với SIEM** là tập trường lõi tương thích **OCSF 1.3**, vì SIEM thực tế chỉ đọc OCSF 1.1–1.3. Các trường mới hơn là tuỳ chọn, ví dụ `malware_scan_info` (từ 1.5) và `record_integrity` (từ 1.9).

### 9.1 Ánh xạ sự kiện
UID của các class đều đã được xác nhận khớp với file nguồn của schema.

| Nhóm | Sự kiện của platform | OCSF class (uid) |
|---|---|---|
| Audit | Đăng nhập, đăng xuất, MFA | Authentication (3002) |
| | Tạo/xoá user, đổi mật khẩu | Account Change (3001) |
| | Cấp/thu quyền, role | User Access Management (3005) |
| | Đổi config, policy, log level | API Activity (6003) |
| File processing | Một job scan bắt đầu/kết thúc, kèm số liệu tổng kết | Scan Activity (6007) |
| | File có mã độc (multiscan, sandbox) | Detection Finding (2004) |
| | **[Mới, cần duyệt]** File bị quarantine hoặc block | Dùng `disposition_id` 3 (Quarantined) hoặc 2 (Blocked) **ngay trên Detection Finding 2004**, không sinh event thứ hai |
| | Phát hiện dữ liệu nhạy cảm (DLP) | Data Security Finding (2006) |
| | **[Mới, cần duyệt]** File bị CDR sanitize | Đề xuất: File Remediation Activity (7002), `activity_id` 4 (Harden), kèm `disposition_id` 11/12/13 (Corrected / Partially Corrected / Uncorrected). **Quyết định sản phẩm còn mở**, xem mục 9.1.1 |
| | File sạch (D13) | Mặc định chỉ được tính trong Scan Activity; khi bật `emitCleanFileEvents` thì sinh event riêng |

#### 9.1.1 Lựa chọn class cho CDR (chờ quyết định sản phẩm)

| Phương án | Ưu | Nhược |
|---|---|---|
| **7002** File Remediation Activity | Đúng ngữ nghĩa nhất: một hành động khắc phục trên file | SIEM ít map. Splunk OCSF-CIM không map 7002 |
| **1001** File System Activity (`activity_id` 3 Update, `file_result`) | Nhiều parser SIEM hỗ trợ hơn | Bắt buộc `actor` và `device`, mà service quét phía server phải tự dựng |

Hiện chưa vendor quét file hay CDR nào công bố mapping OCSF. OPSWAT có thể là vendor đầu tiên, và có thể đề xuất enum "Sanitize" lên upstream.

### 9.2 Trường bắt buộc **[Mới, cần duyệt]**
**Mọi event:** `class_uid`, `category_uid`, `activity_id`, `type_uid` (= `class_uid × 100 + activity_id`), `time`, `severity_id`, `metadata.version`, `metadata.product.name`, `metadata.product.vendor_name = "OPSWAT"`, `metadata.product.version`, cộng:
- `metadata.uid`: UUIDv7, dùng để lọc trùng.
- `metadata.sequence`: tăng đơn điệu theo từng service instance và từng stream, dùng để đối soát.
- `metadata.correlation_uid`: ID của job, nối các event 6007, 2004, 2006 và 7002 của cùng một file.

**Theo từng class** (thiếu thì builder sinh ra event không hợp lệ):

| Class | Trường bắt buộc thêm |
|---|---|
| Findings (2004, 2006) | `finding_info.uid` |
| 2006 | `data_security`, có ít nhất một trong: `data_lifecycle_state_id`, `detection_pattern`, `detection_system_id`, `policy` |
| 6007 | `scan`, với `scan.type_id` |
| 7002 | `command_uid`, `file` |

**Trường riêng của OPSWAT:** **đăng ký ngay một OCSF extension kiểu patching**, thay cho `unmapped.opswat.*`.
- OCSF khuyên producer không dùng `unmapped`, và validator công khai trả về `attribute_unknown` cho object lạ.
- Extension kiểu patching giữ nguyên `class_uid` gốc, nên SIEM vẫn hiểu event.
- Giữ một ID trong registry không tốn gì và không bắt buộc công khai.
- Thuộc tính đặt tên snake_case có tiền tố, theo hướng dẫn OCSF. Tên cụ thể chốt khi đăng ký.

### 9.3 Sinh code **[Mới, cần duyệt]**
- Input của generator là `schema.json`, do `ocsf-schema-compiler` biên dịch từ lõi 1.9.0 cộng extension của OPSWAT.
- Hiện chưa có generator chính thức, nên team tự viết.
- Code sinh ra gọi thẳng Logs API (6.1).
- Builder chỉ có cho các class trong 9.1.

### 9.4 Truyền đi và đảm bảo giao
1. **[Mới, cần duyệt]** Event là một OTLP log record có `event.name = ocsf.<class_name>`. **Body là Map có cấu trúc, không phải chuỗi JSON.** Nếu body là chuỗi, đường Kafka `raw` sẽ mã hoá JSON hai lần.
2. Event đi qua LoggerProvider riêng (6.2), rồi receiver và pipeline riêng ở agent (7.2): không qua lọc level, không bị sampling.
3. **[Mới, cần duyệt] Sink SIEM** (đã kiểm tra trên Collector v0.162.0):

   | Sink | Cách cấu hình | Lưu ý |
   |---|---|---|
   | `kafka` | `logs.encoding: raw`, `required_acks: -1` | Đường giao chắc chắn nhất |
   | `splunk_hec` | Chế độ event hoặc `export_raw` | Record có body rỗng bị bỏ âm thầm. Event vượt `max_event_size` là lỗi permanent |
   | `awss3` | `marshaler: body`, ra NDJSON | **Phải bật `sending_queue`**, vì mặc định tắt. Không có Parquet |
   | `syslog` | Thêm `transform` chép body vào attribute `message` | Mặc định tắt `sending_queue`; không có xác nhận ở tầng ứng dụng, nên là đường yếu nhất |
   | `elasticsearch` | `bodymap` | README ghi chế độ này "unstable" |
   | `file` | Không xuất được NDJSON thuần | Cần encoder tự viết |

   Security Lake cần Parquet và OCSF ≤ 1.3. Splunk cần một TA của OPSWAT để map 2004/2006 sang CIM. Sentinel dùng ASIM. Cả ba thuộc dự án con số 5.
4. Giao ít nhất một lần, với các khoảng hở đã biết ở 7.5. Phía nhận lọc trùng bằng `metadata.uid`.
5. **[Mới, cần duyệt] Đối soát ba lớp.** `otelcol_exporter_sent_*` chỉ chứng minh dữ liệu đã tới hop kế tiếp.
   - **Producer**: gắn `metadata.sequence` (9.2).
   - **Mỗi hop**: đếm bằng `otelcol_receiver_accepted_log_records`, `otelcol_exporter_sent_log_records` và connector `count`.
   - **Ở đích**: một truy vấn định kỳ tìm khoảng trống trong chuỗi `metadata.sequence` và các `metadata.uid` trùng. Có khoảng trống thì phát alert.
   - Cả ba lớp chạy được offline. `record_integrity` (chuỗi băm) là tuỳ chọn cho khách có yêu cầu kiểm toán, và phải bỏ khỏi bản gửi Security Lake.
6. **[Mới, cần duyệt]** Ở runtime chỉ validate **một mẫu** event, bằng `ocsf-toolkit` (Go). Vì vậy `ocsf.invalid` là số đếm trên mẫu. Event sai schema vẫn được gửi đi, nhưng bị gắn cờ.

## 10. Kiểm thử

| Loại | Nội dung |
|---|---|
| **Conformance suite** (chạy trong CI của cả 6 SDK) | Một OTLP receiver giả kiểm tra: attribute bắt buộc, log có `trace_id`, event OCSF hợp lệ, và Weaver live-check cho các attribute `opswat.*`. **[Mới, cần duyệt]** Validate bằng schema đã biên dịch (lõi cộng extension), qua `ocsf-toolkit` hoặc một `ocsf-server` riêng. Cả hai chạy được khi air-gapped. Không dùng `ocsf-validator`, vì công cụ này chỉ kiểm tra cây schema |
| **Unit test component** | `flightrecorder`: xoá theo thời gian, chia công bằng, quota, disk trống tối thiểu, snapshot bằng hard-link, `stopDelay`, fsync khi FATAL, API đọc, xác thực. `levelfilter`: lọc theo service/scope/severity, hết hạn, cấu hình sai |
| **Integration test trên Kind** | Sinh log, kill pod app, rồi đọc được 15 phút trước đó. Đổi ConfigMap, kiểm tra log DEBUG tới backend trong dưới 10 giây rồi tự tắt khi hết hạn. Ngắt gateway, kiểm tra dữ liệu được gửi lại. **[Mới]** Tăng debug lên 10 lần, kiểm tra không mất event OCSF và đối soát không thấy khoảng trống |
| **Phase 0** | Xem mục 12 |

## 11. Rủi ro và câu hỏi mở

| # | Rủi ro / câu hỏi | Mức | Cách xử lý |
|---|---|---|---|
| R1 | **[Mới, cần duyệt] Overhead của việc luôn ghi debug.** Hai số liệu đang dẫn (ICPE 2025: throughput giảm 19–80%; Coroot: CPU tăng khoảng 35% ở 10k RPS) **đều đo tracing, không đo log**. Chúng chỉ là bằng chứng gián tiếp cho thấy serialization và export tốn kém. Chưa có nguồn công khai nào so OTLP với stdout cho log | **Cao** | **Phase 0 là nguồn số liệu duy nhất.** Có sẵn van an toàn và đường stdout |
| R2 | **[Mới, cần duyệt] License AGPLv3** của Grafana/Loki/Tempo/Mimir. Ship tới khách, kể cả bản không sửa đổi, vẫn có thể là "conveying" và kéo theo nghĩa vụ cung cấp source. Rủi ro thực tế lớn nhất là **rủi ro thương mại**: khách bị chính sách mua sắm cấm AGPL | **Cao** | Kit standalone mặc định dùng stack permissive (D7). Grafana chỉ là add-on không sửa đổi, hoặc mua OEM. Nếu ship Grafana thì tắt `reporting_enabled`, `check_for_updates`, `check_for_plugin_updates`. MinIO đã archived và dùng AGPL; cần object store thì dùng SeaweedFS hoặc RustFS. Câu hỏi cho legal ở 11.1 |
| R3 | **[Mới, cần duyệt]** Mức ổn định SDK. Hiện chỉ Node.js còn Development, nhưng đường đi ở Go và Java vẫn phụ thuộc module 0.x hoặc alpha | Trung bình | Bảng 6.3. Mỗi quý theo dõi README/CHANGELOG của từng repo (không dựa vào trang status). Ghim phiên bản và kiểm tra trong CI (6.5) |
| R4 | Phone-home cần legal/security chốt. **[Mới, cần duyệt]** Ngoài ra, context do auth extension đặt không đi qua được persistent queue. Cần kiểm tra nếu hub định tuyến tenant dựa trên auth | Trung bình | Mặc định tắt. Khách air-gapped gửi metrics kèm bundle (D6). Xử lý trong spec Hub |
| R5 | Platform có multi-tenant hay không | Thấp | Thêm `opswat.tenant.id` vào F1 khi cần |
| R6 | **[Mới, cần duyệt]** Exporter SIEM xuất body JSON thuần: **gần như đã giải** (9.4 mục 3) | Thấp | Còn lại: encoder cho `file`, Parquet cho Security Lake (dự án con số 5) |
| R7 | **[Mới, cần duyệt] 2 GiB mỗi node có thể không đủ.** 2 GiB / 900 giây ≈ 2.39 MB/s. Con số này tương đương khoảng 11k dòng/giây nếu mỗi dòng 216 byte, hoặc khoảng 950 dòng/giây nếu 2.5 KB (khi đã gắn attribute k8s). Chỉ một service 500 RPS ghi 10 dòng debug cho mỗi request đã là 5k dòng/giây | Trung bình–Cao | Chia công bằng và quota (7.3). Đo số byte thực cho mỗi bản ghi trong Phase 0 |
| R8 | **[Mới, cần duyệt] PII thô trên hostPath.** Buffer và snapshot 24 giờ chứa tên file, email, IP mà không mã hoá, và không component OTel nào mã hoá at-rest | **Cao** | **Security review** chọn một trong ba: mã hoá disk ở node; mã hoá từng snapshot (envelope); đặt `redaction` trước buffer cho các trường nhạy cảm nhất |
| R9 | **[Mới, cần duyệt]** OCSF 1.9.0 đi trước SIEM (đa số đọc 1.1–1.3). Splunk OCSF-CIM không map 2004/2006/6007/7002; Sentinel không dùng OCSF | Trung bình | Cam kết tập trường lõi 1.3 (§9). TA Splunk và mapping ASIM ở dự án con số 5 |
| R10 | **[Mới, cần duyệt]** At-least-once của Collector có lỗ hổng đã biết: bug #15677 và #50102, lỗi permanent, disk đầy | Trung bình | Cấu hình ở 7.2, đối soát ở 9.4 mục 5 |

### 11.1 Câu hỏi cho legal **[Mới, cần duyệt]**
Chi tiết và nguồn nằm ở phần 4 của báo cáo "Nghiên cứu bổ sung kiến trúc telemetry". Đây là câu hỏi, không phải kết luận.

| # | Câu hỏi | Liên quan |
|---|---|---|
| L1 | Container Grafana/Loki/Tempo/Mimir không sửa đổi, giao tiếp qua HTTP, có được coi là "aggregate" theo điều 5 AGPLv3 không? | R2 |
| L2 | Với khách air-gapped, cung cấp Corresponding Source theo cách nào: điều 6(a) trên media, 6(b) written offer 3 năm, hay 6(d) link? Dockerfile và script build có thuộc Corresponding Source không? | R2, D5 |
| L3 | EULA cần điều khoản loại trừ nào cho component open source (điều 10)? | R2 |
| L4 | Ranh giới của "sửa đổi": file cấu hình, dashboard JSON, Helm values, so với patch source, rebuild, white-label, tự backport bản vá? | R2 |
| L5 | Plugin Grafana độc quyền chạy trong process Grafana có bị coi là tác phẩm phái sinh không? | Dự án con số 5 |
| L6 | Customer Log UI nhúng Grafana bằng iframe hoặc gọi HTTP API, so với tái dùng code AGPL? | Dự án con số 5 |
| L7 | Grafana không sửa đổi ở hub do OPSWAT tự vận hành: xác nhận không có "conveying" | D7 |
| L8 | Giấy phép OEM của Grafana có bao gồm Loki, Mimir, Tempo không? | R2 |
| L9 | Chính sách cấm AGPL phía khách hàng: đây là rủi ro mua sắm, không phải pháp lý | R2 |
| L10 | Điều khoản enterprise của VictoriaMetrics; thư mục `ee/` của SigNoz; ELv2/SSPL nếu xét Elastic | Dự án con số 2 |
| L11 | sos dùng GPL-2.0: chỉ gọi như một công cụ riêng, so với nhúng hoặc sửa đổi | Dự án con số 3 |

## 12. Lộ trình

| Bước | Nội dung | Đầu ra |
|---|---|---|
| **Phase 0: Nghiên cứu đo đạc và tiêm lỗi [Mới, cần duyệt]** | Xem giao thức ở 12.1 | Số liệu thật cho R1 và R7. Quyết định đường đi log của từng ngôn ngữ (bảng 6.3). Giá trị cho `OTEL_BLRP_MAX_QUEUE_SIZE`, ngân sách node, quota theo service |
| **1. Nền móng** (spec này) | F1–F5 | Chuẩn, SDK cho 6 ngôn ngữ, Collector bản riêng, conformance suite, đăng ký OCSF extension |
| Pilot | Áp dụng cho **một product** | Bài học trước khi phổ biến cho cả công ty |
| 2. Pipeline và backend | Gateway, bản standalone. **[Mới, cần duyệt]** Chọn một trong ba stack permissive: "Victoria" (VictoriaMetrics + VictoriaLogs + VictoriaTraces/Jaeger, UI vmui + Perses); "chỉ CNCF/LF" (Prometheus + Thanos, Jaeger v2, OpenSearch, Perses); hoặc ClickStack/HyperDX + ClickHouse. Ưu tiên dự án do quỹ quản trị. Grafana là add-on tuỳ chọn | Spec riêng |
| 3. Diagnostic và Support package | **[Mới, cần duyệt]** Dùng Replicated troubleshoot (Apache 2.0) làm khung. Đọc buffer qua API `/flight` (7.3 mục 4). Che dữ liệu nhất quán, với mapping file do khách giữ (theo `sos clean`, must-gather-clean). Mã hoá GPG tới public key của OPSWAT. Manifest SHA-256 cho từng file. Khách air-gapped nộp bundle định kỳ | Spec riêng |
| 4. Hub và phone-home | Multi-tenant, Grafana tổng, OpAMP. Kiểm tra định tuyến tenant qua persistent queue (R4) | Spec riêng |
| 5. Customer Log UI và SIEM | UI tìm log. Sink Security Lake (Parquet, OCSF 1.3), TA Splunk, mapping ASIM cho Sentinel. UI chỉ link/iframe tới Grafana, không biên dịch code AGPL vào (L5, L6) | Spec riêng |
| 6. AI self-healing | **Người duyệt mọi hành động.** Benchmark AI RCA hiện chỉ đạt 10–25% (OpenRCA, ITBench, ORCA-bench), nên giai đoạn đầu AI chỉ gợi ý và sinh truy vấn, không tự sửa | Spec riêng |

### 12.1 Giao thức Phase 0 **[Mới, cần duyệt]**

| Thành phần | Nội dung |
|---|---|
| Ma trận cấu hình | Mỗi ngôn ngữ một service mẫu, chạy 5 cấu hình: tắt telemetry; chỉ INFO; DEBUG qua stdout JSON; DEBUG qua OTLP; DEBUG có guard/sampling. Cùng image, cùng loại node, ghim phiên bản Collector |
| Tải | Open-model ở tốc độ cố định, tại khoảng 50% và 80% năng lực (wrk2 `-R` hoặc k6 constant-arrival-rate). Warm-up ≥ 30 giây, lâu hơn với JVM/.NET. Mỗi lần chạy 10–20 phút, lặp ≥ 10 lần, đảo thứ tự cấu hình ngẫu nhiên |
| Metric trong app | CPU của cgroup app, số lần và thời gian bị throttle, RSS/heap, GC pause, tốc độ cấp phát. p50/p99/p99.9 đã hiệu chỉnh coordinated omission (HdrHistogram) |
| Metric trên node | CPU của Collector, containerd và kubelet, **đo riêng từng thứ**. Số byte ghi xuống disk. Số phút thực sự còn giữ trong buffer. Bộ đếm drop ở cả SDK lẫn Collector |
| Tiêm lỗi | SIGSTOP Collector; giới hạn Collector còn 0.25 core; disk chậm hoặc `/var/log` gần đầy; tăng DEBUG gấp 10 lần; restart Collector. Với mỗi kịch bản, ghi lại p99 của app (rủi ro của stdout) và lượng dữ liệu mất (rủi ro của OTLP), kể cả event OCSF |
| CPU limit | Chạy với CPU limit giống production, rồi chạy lại không có limit, để tách hiệu ứng throttle khỏi chi phí CPU thuần |
| Báo cáo | Overhead là hiệu số so với cấu hình tắt telemetry, kèm khoảng tin cậy, quy ra cả chi phí cho mỗi node |

## 13. Tham khảo
- Báo cáo nội bộ: [Tổng hợp nghiên cứu observability](./Tổng%20hợp%20nghiên%20cứu%20observability.md) và [Nghiên cứu bổ sung kiến trúc telemetry](./Nghiên%20cứu%20bổ%20sung%20kiến%20trúc%20telemetry.md). Phần lớn số liệu, phiên bản và nguồn trong spec này lấy từ hai báo cáo đó, kiểm tra ngày 2026-10-07.
- OCSF schema 1.9.0: https://schema.ocsf.io
- OTel Collector resiliency: https://opentelemetry.io/docs/collector/resiliency/
- OTel Collector Builder (OCB): https://opentelemetry.io/docs/collector/custom-collector/
- OTel Weaver: https://github.com/open-telemetry/weaver
- Replicated troubleshoot: https://github.com/replicatedhq/troubleshoot

## 14. Thay đổi vòng 2 và đề xuất không áp dụng

### 14.1 Thay đổi so với Draft v1
**Từ báo cáo "Nghiên cứu bổ sung kiến trúc telemetry":**
1. §1: hai ngân sách CPU (app và node); khoảng hở khi crash trên đường OTLP; cam kết tương thích OCSF 1.3.
2. D6, D7, D11: metrics đi kèm support bundle cho khách air-gapped; kit standalone mặc định dùng stack permissive; chia công bằng và giữ tối thiểu 15% disk trống.
3. 5.3: chính sách chuyển đổi semconv với `…/dup`; ghim image auto-instrumentation.
4. 6.1: sửa câu về declarative config (chỉ spec và schema là stable); builder là code sinh sẵn.
5. 6.2 mục 3: Go không inject qua Operator; ghi Go compile-time instrumentation là một lựa chọn; OBI để sau.
6. 6.3: viết lại bảng theo trạng thái thật, thêm quy định bắt buộc cho từng ngôn ngữ.
7. 6.4: viết lại cách xử lý lỗi theo từng đường đi; nguyên tắc bỏ debug thay vì chặn app; `ForceFlush` khi FATAL.
8. 6.5: ghim các dependency 0.x/alpha.
9. 7.2 và 7.5: pipeline OCSF bỏ `batch` processor, bật fsync và retry vô hạn; bảng lỗi ghi rõ các bug đã biết.
10. 7.3: chia công bằng, disk trống tối thiểu, fsync, snapshot bằng hard-link, `stopDelay`, giới hạn tần suất theo trigger và theo 24 giờ, chỉ đọc buffer qua API.
11. §8: bám Telemetry Policy (OTEP 4738).
12. §9: tách phiên bản soạn và phiên bản cam kết; quarantine/block dùng `disposition_id`; CDR là quyết định mở; trường bắt buộc theo class; `metadata.sequence` và `correlation_uid`; extension kiểu patching; sinh code từ schema đã biên dịch; body là Map; bảng sink; đối soát ba lớp; validate theo mẫu.
13. §10, §11, §12: conformance validate bằng schema đã biên dịch; viết lại R1, R2, R3, R6, R7; thêm R8, R9, R10 và bảng câu hỏi legal; giao thức Phase 0; lộ trình bước 2, 3, 5.

**Đề xuất của Claude** (không có trong báo cáo, cần duyệt riêng):
14. LoggerProvider riêng cho OCSF ở SDK, cộng receiver `:4319` riêng ở agent (§4, 6.2, 7.2). Lý do: log debug tràn hàng đợi 2048 bản ghi dùng chung có thể làm mất audit event ngay tại SDK. Còn backpressure từ `block_on_overflow` có thể dồn ngược qua routing connector, làm tắc cả log thường. Phase 0 cần kiểm chứng giả định thứ hai.
15. Mỗi segment ứng với một service trong một phút (7.3 mục 1), để chia quota theo service.
16. Snapshot có giới hạn dung lượng riêng (7.3 mục 5), vì hard-link vẫn giữ chỗ trên disk sau khi segment gốc đã bị xoá.

### 14.2 Đề xuất không áp dụng hoặc chỉ áp dụng một phần

| Đề xuất của báo cáo | Quyết định | Lý do |
|---|---|---|
| Van an toàn đổi được lúc đang chạy, kiểu `slog.LevelVar` (độ tin cậy Thấp) | **Không áp dụng** | Muốn đổi lúc chạy thì cả 6 SDK phải tự theo dõi cấu hình, tức là đưa logic quay lại vào app, ngược với D9. Van này chỉ dùng trong tình huống khẩn cấp hiếm gặp, nên rolling restart là chấp nhận được. Sẽ xem lại nếu Phase 0 cho thấy van phải dùng thường xuyên |
| Đặt `redaction` trước buffer | **Không làm mặc định**, chỉ là một trong ba phương án của R8 | Buffer chủ yếu phục vụ support package. Che dữ liệu nhất quán lúc xuất bundle, với mapping do khách giữ, vẫn giữ được khả năng debug. Che trước buffer thì mất thông tin vĩnh viễn. Quyết định cuối thuộc security review |
| Sink Security Lake hạ xuống 1.3 và chuyển sang Parquet | **Hoãn** sang dự án con số 5 | Nằm ngoài phạm vi Nền móng. Spec chỉ ghi cam kết tương thích 1.3 |
| OBI làm lớp RED metrics cho C++/Rust | **Hoãn** tới khi OBI lên 1.0 | Hiện là rc.1, và chỉ thấy được ở tầng giao thức mạng |
| Go compile-time instrumentation | **Áp dụng một phần**: ghi là lựa chọn, chưa bắt buộc | Cần đánh giá với build pipeline thật trong pilot |
| Chọn class cho CDR (7002 hay 1001) | **Chưa tự chốt**: đề xuất 7002, để mở cho quyết định sản phẩm | Đây là đánh đổi giữa đúng ngữ nghĩa và mức hỗ trợ của SIEM, thuộc về product owner |
