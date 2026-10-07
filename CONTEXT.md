# CONTEXT: Telemetry Foundation

Tài liệu này tóm tắt bối cảnh, các quyết định và trạng thái hiện tại của repo, để người hoặc agent làm tiếp không phải đọc lại toàn bộ lịch sử trao đổi. Cập nhật lần cuối: **2026-10-07**.

## Repo này gồm gì

| Thư mục | Nội dung |
|---|---|
| `labs/`, `compose/`, `k8s/`, `app-versions/`, `README.md` | Tài liệu khoá học *OpenTelemetry for Observability* (Lauro Mueller), dùng để học OTel với stack Prometheus, Loki, Tempo, Grafana. `README.md` là README gốc của khoá học |
| `reports/` | Spec thiết kế và hai báo cáo nghiên cứu (tiếng Việt) |
| `research_notes/` | Ghi chú nghiên cứu chi tiết, kèm nguồn, làm đầu vào cho hai báo cáo |
| `presentation/deck/` | Mã nguồn deck trình bày kiến trúc (bản chụp ngày 2026-10-07) |

## Chạy stack local

1. `cp compose/.env.example compose/.env`, rồi đặt `GF_SECURITY_ADMIN_PASSWORD` (file `.env` đã được gitignore)
2. `make up`

## Dự án

Team **Telemetry/Observability & Diagnostic/Support Package** của OPSWAT xây chuẩn telemetry chung cho platform mới, dùng cho nhiều product. Chuẩn này vừa gắn được vào từng product, vừa cho góc nhìn tổng hợp ở hub.

Sáu định hướng của team:
1. Telemetry framework có thông tin bắt buộc; metrics, logs và traces được lưu tập trung
2. Cấu hình log level theo từng service
3. UI để khách tự tìm log và tự xử lý sự cố; AI self-healing ở giai đoạn sau
4. Luôn ghi DEBUG, chỉ giữ 15 phút gần nhất (flight recorder)
5. Support package gửi về OPSWAT, hoặc xuất ra shared folder cho khách air-gapped
6. Audit event và file processing event theo định dạng OCSF

## Ràng buộc đã chốt

- Self-host; dữ liệu không rời hạ tầng nếu không được phép
- Kubernetes, 20–100 service
- Ngôn ngữ: Go, C/C++/Rust, Java/.NET, Node.js
- Có bản on-prem tại khách, kể cả air-gapped
- Phone-home: thiết kế sẵn, mặc định tắt, khách tự bật, chỉ gửi metrics tổng hợp

## Quyết định kiến trúc chính

Chi tiết đầy đủ (D1–D13) nằm ở [spec](reports/2026-10-07-telemetry-foundation-design.md), mục 2.

- **Hub-and-spoke.** Mỗi product dùng chung một Helm kit với `mode: hub | standalone`. Hub do OPSWAT vận hành, multi-tenant, mỗi product là một tenant.
- **SDK mỏng, logic nằm ở Collector agent.** Agent là một bản Collector build riêng, có hai component tự viết bằng Go: `flightrecorder` (hộp đen 15 phút) và `levelfilter` (log level theo service). Không bọc OTel API.
- **Pipeline OCSF riêng.** Event OCSF đi qua LoggerProvider riêng, cổng `:4319` riêng và hàng đợi bền riêng. Đối soát bằng `metadata.sequence`.
- **OCSF:** soạn theo 1.9.0, nhưng chỉ cam kết các trường tương thích 1.3 (SIEM thực tế đọc 1.1–1.3).
- **License:** kit standalone ship tới khách mặc định dùng stack Apache 2.0/MIT. Grafana/Loki/Tempo/Mimir dùng AGPLv3, nên chỉ là add-on tuỳ chọn. Hub vẫn có thể dùng Grafana stack (chờ legal xác nhận).
- **Lộ trình:** Phase 0 đo overhead và tiêm lỗi → Nền móng (F1–F5) → pilot trên một product → các dự án con 2–6.

## Năm khối của Nền móng

| Khối | Nội dung |
|---|---|
| F1 | Telemetry standard: attribute bắt buộc, semconv ghim ở 1.44.0, quản lý bằng OTel Weaver |
| F2 | SDK mỏng cho 6 ngôn ngữ: cấu hình, khởi tạo, builder OCSF sinh tự động. Node.js ghi log ra stdout |
| F3 | Collector agent: flight recorder, levelfilter, pipeline OCSF |
| F4 | Điều khiển log level: theo service và logger, hiệu lực dưới 10 giây, tự hết hạn, có audit |
| F5 | Event OCSF: 8 class audit và file processing, đối soát đầu cuối |

## Tiến trình (2026-10-07)

1. Đọc ebook "22 winning observability strategies" của New Relic để lấy ý tưởng
2. Brainstorm: chốt mục tiêu, ràng buộc, kiến trúc A, thiết kế F1–F5
3. Spec v1 → báo cáo "Tổng hợp nghiên cứu observability" → báo cáo "Nghiên cứu bổ sung kiến trúc telemetry" → **Spec v2**. Các thay đổi chưa duyệt được đánh dấu `[Mới, cần duyệt]`; danh sách nằm ở mục 14 của spec
4. Deck tiếng Anh 10 slide (6 sơ đồ) để trình bày với cấp trên

## Trạng thái và bước tiếp theo

- [ ] Team review spec v2, đặc biệt mục 14 (thay đổi vòng 2 và các đề xuất không áp dụng)
- [ ] Trình bày deck và xin chấp thuận hướng kiến trúc
- [ ] Sau khi được duyệt: viết kế hoạch triển khai cho phần Nền móng, bắt đầu bằng Phase 0 (giao thức ở spec §12.1)

## Câu hỏi còn mở

- **Legal:** 11 câu hỏi AGPL (spec §11.1, L1–L11)
- **Security review:** PII thô trong flight recorder và snapshot (R8)
- **Quyết định sản phẩm:** chọn class OCSF cho CDR, 7002 hay 1001 (§9.1.1)
- Platform có multi-tenant không, tức có cần `opswat.tenant.id` (D12)
- Phone-home: legal và security cần chốt (D6)
- Chọn product để pilot; nguồn lực và thời gian cho Phase 0

## Quy ước làm việc

- Spec và báo cáo viết vào `reports/`, bằng tiếng Việt, thuật ngữ kỹ thuật giữ tiếng Anh.
- Mọi thay đổi chưa được duyệt đánh dấu `[Mới, cần duyệt]`.
- Nội dung về license chỉ là câu hỏi cho legal, không phải tư vấn pháp lý.
- Deck chỉnh trực tiếp trên claude.ai. Bản trong `presentation/deck/` chỉ là ảnh chụp, có thể cũ hơn bản trên claude.ai.
