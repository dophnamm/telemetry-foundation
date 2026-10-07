# Hai thập kỷ nghiên cứu định hình OpenTelemetry

Những tài liệu về observability đáng đọc nhất chia thành bốn lớp. Đáng chú ý là gần như mỗi thành phần trong stack Prometheus + Loki + Tempo + Grafana của bạn đều truy được về một bài báo gốc cụ thể. Tempo và mô hình span của OpenTelemetry kế thừa **Dapper (Google, 2010)** và **X-Trace (NSDI 2007)**. Phần nén dữ liệu trong TSDB của Prometheus lấy từ **Gorilla (VLDB 2015)**. Tính năng pattern của Loki cài đặt trực tiếp thuật toán **Drain (ICWS 2017)**. Baggage của OTel bắt nguồn từ **Pivot Tracing (SOSP 2015)**. Nghiên cứu học thuật 2021–2026 bổ sung hai lời cảnh báo có số liệu. Thứ nhất, một nghiên cứu peer-reviewed tại ICPE 2025 đo được OpenTelemetry làm giảm throughput **19–80%** tùy cấu hình, và thủ phạm chính là bước serialization khi export. Thứ hai, các benchmark AI agent cho root cause analysis (OpenRCA, ITBench, ORCA-bench) chỉ đạt khoảng **10–25%** thành công. Trong các khảo sát ngành, nguồn trung lập đáng tin nhất là **CNCF Annual Survey**, với 49% dùng OTel và 77% dùng Prometheus trong production. Các báo cáo của vendor thì cho tỷ lệ áp dụng OTel từ **10.3% đến 85%**, tùy câu hỏi được đặt ra sao, nên con số nào cũng phải đọc cùng định nghĩa của nó. Với tài liệu riêng về OTel, nên đọc trước ba nguồn: CNCF Observability Whitepaper, trang Status của dự án (trang này cho biết logs SDK của JavaScript và Python vẫn ở mức "Development"), và sách *Learning OpenTelemetry* (O'Reilly, 2024). Hiện vẫn chưa có nghiên cứu peer-reviewed nào về mức độ áp dụng OTel, và cũng chưa có benchmark overhead chính thức cho Node.js hay Python. Vì vậy, với stack của bạn, tự đo là việc bắt buộc. Lộ trình đọc ở cuối báo cáo bắt đầu từ whitepaper và `docker-otel-lgtm`, đi qua Dapper và các case study trên Kubernetes, rồi tới các bài về sampling và chi phí.

## Mỗi thành phần trong stack của bạn đều có một bài báo gốc

Đọc các bài nền tảng không phải để học lịch sử. Chúng giải thích vì sao công cụ hoạt động như hiện nay, và ở vài chỗ mối liên hệ nằm ngay trong mã nguồn.

### Tracing: từ X-Trace đến header `traceparent` nối Node.js với Python

Trước Dapper có ba hướng nghiên cứu. **Pinpoint** (DSN 2002) gắn tag cho request thật của client khi chúng đi qua hệ thống, rồi dùng data mining để tìm component có khả năng gây lỗi cao nhất ([Pinpoint PDF](http://roc.cs.berkeley.edu/papers/roc-pinpoint-ipds.pdf)). **Magpie** (OSDI 2004) dùng một event schema riêng cho từng ứng dụng để ghép các sự kiện từ kernel, middleware và ứng dụng thành luồng điều khiển của từng request ([Magpie PDF](https://www.usenix.org/legacy/event/osdi04/tech/full_papers/barham/barham.pdf)). **X-Trace** (NSDI 2007) chèn vào request một bộ metadata gồm TaskID, ParentID và OpID, rồi truyền nó xuống mọi tầng giao thức và theo mọi request đệ quy ([X-Trace PDF](https://www.usenix.org/legacy/event/nsdi07/tech/full_papers/fonseca/fonseca.pdf)). Bộ ba này gần như trùng khớp với trace_id/span_id/parent_span_id của OTel. Đây là ánh xạ do suy luận, nhưng chính nhóm tác giả Dapper viết rằng Dapper "shares conceptual similarities with other tracing systems, particularly Magpie and X-Trace" ([Dapper PDF](https://static.googleusercontent.com/media/research.google.com/en//archive/papers/dapper-2010-1.pdf)).

**Dapper** (Google Technical Report, 4/2010) tổng kết hơn hai năm chạy tracing trong production ở quy mô Google. Ba mục tiêu thiết kế của nó là "low overhead, application-level transparency, and ubiquitous deployment", và nó đạt được nhờ hai lựa chọn: dùng sampling, và chỉ instrument một số ít thư viện dùng chung ([Dapper PDF](https://static.googleusercontent.com/media/research.google.com/en//archive/papers/dapper-2010-1.pdf)). Bảng 2 của bài là bằng chứng sớm nhất cho vai trò của sampling. Trace mọi request (tỷ lệ 1/1) làm latency trung bình tăng **16.3%**. Ở tỷ lệ 1/16, mức tăng còn **2.12%**. Ở 1/1024, con số là **−0.20%**, tức nằm trong sai số đo ([Dapper PDF](https://static.googleusercontent.com/media/research.google.com/en//archive/papers/dapper-2010-1.pdf)).

Các hệ thống mã nguồn mở nối tiếp nhau từ đó. Twitter viết Zipkin trong một Hack Week như "a basic version of the Google Dapper paper for Thrift" ([Twitter Engineering, 2012](https://blog.x.com/engineering/en_us/a/2012/distributed-systems-tracing-with-zipkin)). Uber xây Jaeger theo kiểu "Dapper-style" ([Uber Engineering, 2017](https://www.uber.com/en-DE/blog/distributed-tracing/)). Mốc thời gian của Jaeger có chút mâu thuẫn: tài liệu Jaeger ghi mã nguồn mở năm 2016 ([Jaeger docs](https://www.jaegertracing.io/docs/latest/)), còn blog Uber ghi "officially open source" ngày 15/4/2017. OpenTelemetry ra đời từ việc sáp nhập OpenTracing và OpenCensus ([opentelemetry.io](https://opentelemetry.io/docs/what-is-opentelemetry/)). Chuẩn **W3C Trace Context** (Recommendation ngày 23/11/2021, Yuri Shkuro của Jaeger là một trong các editor) định nghĩa header `traceparent` và `tracestate`, chính là propagator mặc định trong các OTel SDK ([W3C](https://www.w3.org/TR/trace-context/)). Với bạn, `traceparent` là sợi dây nối span của Node.js frontend với span của Python worker. Khi một trace bị "đứt" giữa hai service, lỗi gần như luôn nằm ở khâu propagation.

Dòng nghiên cứu của Facebook chuyển tracing từ việc "xem một cây request" sang việc "phân tích cả tập dữ liệu trace". **The Mystery Machine** (OSDI 2014) dựng mô hình thực thi chỉ từ log có sẵn, kiểm chứng trên hơn 1.3 triệu request ([PDF](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-chow.pdf)). **Canopy** (SOSP 2017) xử lý hơn 1 tỷ trace mỗi ngày và tách riêng ba phần: instrumentation, trace model và feature extraction ([Canopy PDF](https://cs.brown.edu/people/jcmace/papers/kaldor2017canopy.pdf)). Cách tách này giống với việc OTel tách API/SDK, OTLP và Collector/backend, và báo trước kiểu metrics sinh ra từ trace như metrics-generator của Tempo (cả hai liên hệ này là suy luận). Hai bài về design space của Sambasivan và cộng sự cho bạn bộ từ vựng để quyết định nên propagate gì và sample thế nào. Báo cáo kỹ thuật CMU-PDL-14-102 (2014) ghi nhận tracing có dùng sampling chỉ tốn dưới 1% overhead ([CMU-PDL](https://www.pdl.cmu.edu/PDL-FTP/SelfStar/CMU-PDL-14-102.pdf)). Bản peer-reviewed tại SoCC 2016 có Ben Sigelman, tác giả chính của Dapper, đứng tên đồng tác giả ([SoCC'16 PDF](https://cs.brown.edu/people/jcmace/papers/sambasivan16principled.pdf)).

### Nhóm Brown/MPI-SWS đặt nền cho Baggage và tail sampling

**Pivot Tracing** (SOSP 2015, Best Paper) kết hợp dynamic instrumentation với một toán tử mới là "happened-before join". Nhờ đó người dùng có thể định nghĩa metric ở một điểm trong hệ thống rồi group theo sự kiện ở một service khác ([PDF](https://cs.brown.edu/people/jcmace/papers/mace15pivot.pdf)). Theo chính tác giả Jonathan Mace, bài này "introduced baggage", khái niệm sau đó được Zipkin và OpenTracing dùng rộng rãi ([Mace homepage](https://cs.brown.edu/people/jcmace/)). **Universal Context Propagation** (EuroSys 2018) đề xuất tách hẳn việc propagate context ra khỏi logic của từng công cụ ([PDF](https://cs.brown.edu/people/jcmace/papers/mace18universal.pdf)). Đây là tư tưởng đứng sau việc OTel tách Context/Propagators API khỏi các signal (suy luận).

Về sampling, ba bài nối tiếp nhau giải bài toán head vs tail:

- **Weighted Sampling** (SoCC 2018) chỉ ra uniform sampling tiêu phần lớn ngân sách vào những request "bình thường" ([DOI](https://doi.org/10.1145/3267809.3267841)).
- **Sifter** (SoCC 2019) thiên lệch sampling về các edge case ([DOI](https://doi.org/10.1145/3357223.3362736)).
- **Hindsight** (NSDI 2023) đề xuất "retroactive sampling": chỉ thu dữ liệu trace sau khi đã phát hiện triệu chứng, giống camera hành trình trên ô tô ([Hindsight PDF](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf)).

Đây đúng là bài toán bạn gặp khi cấu hình Collector. Tài liệu OTel nói rõ head sampling một mình không thể đảm bảo giữ lại mọi trace có lỗi ([OTel Sampling](https://opentelemetry.io/docs/concepts/sampling/)). Còn tail sampling processor đòi hỏi mọi span của cùng một trace phải đến cùng một Collector instance ([tailsamplingprocessor README](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/processor/tailsamplingprocessor)). Hindsight nhắm thẳng vào hai điểm yếu đó: trạng thái phải giữ và chi phí ingest.

### Metrics: Borgmon và Gorilla nằm ngay trong mã nguồn Prometheus

Chương 10 của sách SRE mô tả Borgmon, hệ thống monitoring Google xây sau Borg (2003), và viết thẳng: "Prometheus shares many similarities with Borgmon, especially when you compare the two rule languages" ([SRE ch.10](https://sre.google/sre-book/practical-alerting/)). Prometheus bắt đầu ở SoundCloud từ 2012 và vào CNCF năm 2016, là dự án thứ hai sau Kubernetes ([Prometheus docs](https://prometheus.io/docs/introduction/overview/)).

**Gorilla** (VLDB 2015) nén timestamp bằng delta-of-delta và giá trị float bằng XOR, đạt trung bình **1.37 byte/điểm dữ liệu, nhỏ hơn 12 lần** ([Gorilla PDF](https://www.vldb.org/pvldb/vol8/p1816-teller.pdf)). Đây là liên hệ cụ thể nhất từ bài báo đến code mà nhóm nghiên cứu tìm được. File `tsdb/chunkenc/xor.go` của Prometheus ghi rằng code chủ yếu lấy từ go-tsz, kèm chú thích "Gorilla has a max resolution of seconds, Prometheus milliseconds" ([Prometheus source](https://github.com/prometheus/prometheus/blob/main/tsdb/chunkenc/xor.go)). Bản thân go-tsz tuyên bố cài đặt thuật toán nén của Gorilla ([go-tsz](https://github.com/dgryski/go-tsz)).

**Monarch** (VLDB 2020) liệt kê các điểm yếu của Borgmon: nhiều instance chạy biệt lập, không có schema cho các chiều đo, và hỗ trợ histogram kém ([Monarch PDF](https://www.vldb.org/pvldb/vol13/p3181-adams.pdf)). Ba điểm yếu này ứng với ba hướng phát triển sau đó (suy luận): Thanos/Mimir để query toàn cục, native histogram và ExponentialHistogram cho phân phối, semantic conventions cho schema. **DDSketch** (VLDB 2019) là sketch quantile mergeable với relative error ([DDSketch PDF](https://www.vldb.org/pvldb/vol12/p2195-masson.pdf)). UDDSketch dựa trên nó ([arXiv](https://arxiv.org/abs/2004.08604)), và OTEP 149 trích UDDSketch khi định nghĩa ExponentialHistogram base-2 của OTel, loại mà "Any 2 histograms in the series can be merged without artifacts" ([OTEP 149](https://github.com/open-telemetry/opentelemetry-specification/blob/main/oteps/0149-exponential-histogram.md)). Khi bạn chọn giữa explicit bucket và exponential histogram cho metric latency của Node.js, đó là dòng nghiên cứu bạn đang dựa vào.

### Logs: thuật toán Drain đang chạy bên trong Loki

Xu và cộng sự (SOSP 2009) parse console log bằng cách kết hợp phân tích source code với information retrieval, rồi dùng machine learning để phát hiện sự cố. Hệ thống xử lý 24 triệu dòng log trong 3 phút ([PDF](https://people.eecs.berkeley.edu/~jordan/papers/xu-etal-sosp09.pdf)). **Scuba** (VLDB 2013) của Facebook ingest hàng triệu event mỗi giây và cho phép mỗi dòng mang một sample rate riêng, thường từ 1/100 đến 1/1.000.000 ([Scuba PDF](https://www.vldb.org/pvldb/vol6/p1057-wiener.pdf)). Đó là tiền thân của mô hình "wide event" và của việc gắn trọng số sampling vào chính telemetry. **Drain** (ICWS 2017) parse log theo thời gian thực bằng một cây có độ sâu cố định ([Drain PDF](https://jiemingzhu.github.io/pub/pjhe_icws2017.pdf)). File `pkg/pattern/drain/drain.go` của Loki trích trực tiếp link PDF của bài này trong comment ([Loki source](https://github.com/grafana/loki/blob/main/pkg/pattern/drain/drain.go)). **Loghub** (ISSRE 2023) là bộ dataset chuẩn để benchmark log parsing ([arXiv](https://arxiv.org/abs/2008.06448), [GitHub](https://github.com/logpai/loghub)).

Ba bài này cộng lại giải thích một lựa chọn thiết kế của Loki: nó "only indexes metadata about your logs as a set of labels" ([Loki docs](https://grafana.com/docs/loki/latest/get-started/overview/)) và chỉ khai thác template khi cần. TraceQL của Tempo cũng được mô tả là "Inspired by PromQL and LogQL" ([Tempo docs](https://grafana.com/docs/tempo/latest/)). Mô hình label xuất phát từ Borgmon/Prometheus nay đã lan sang cả logs lẫn traces trong stack Grafana.

### Từ vựng của ngành: golden signals, USE, RED và "three pillars"

Bản thân từ "observability" đến từ lý thuyết điều khiển. R. E. Kalman đưa ra khái niệm này năm 1960 cho hệ động lực tuyến tính: một hệ là observable nếu có thể ước lượng trạng thái bên trong chỉ từ output ([DOI](https://doi.org/10.1016/S1474-6670%2817%2970094-8), [Wikipedia](https://en.wikipedia.org/wiki/Observability)). Bài "Observability at Twitter" (2013) là một trong những lần dùng thuật ngữ này sớm nhất trong ngành phần mềm ([Twitter Engineering](https://blog.x.com/engineering/en_us/a/2013/observability-at-twitter)), dù khẳng định "lần đầu tiên" chưa được xác minh.

Bộ từ vựng phương pháp gồm ba nguồn. Chương 6 sách SRE đưa ra bốn **golden signals**: latency, traffic, errors, saturation ([SRE ch.6](https://sre.google/sre-book/monitoring-distributed-systems/)). Brendan Gregg đưa ra **USE method** trên ACM Queue năm 2012 ([ACM Queue](https://queue.acm.org/detail.cfm?id=2413037), [Gregg](https://www.brendangregg.com/usemethod.html)). Tom Wilkie tạo ra **RED method** năm 2015 ([Grafana blog](https://grafana.com/blog/the-red-method-how-to-instrument-your-services/)). URL gốc của RED trên Weaveworks nay chuyển hướng sang một trang không liên quan, nên đừng dùng nó.

Cụm "three pillars" là phân loại của giới thực hành, không phải của giới học thuật. Nó đến từ bài blog dùng sơ đồ Venn của Peter Bourgon (2/2017) ([Bourgon](https://peter.bourgon.org/blog/2017/02/21/metrics-tracing-and-logging.html)) và báo cáo O'Reilly của Cindy Sridharan (2018) ([O'Reilly](https://www.oreilly.com/library/view/distributed-systems-observability/9781492033431/)). Áp vào stack của bạn: RED lấy từ span metrics của dịch vụ Node.js/Python, còn USE lấy từ metrics của node và container.

| Tài liệu nền tảng | Năm, nơi công bố | Thứ nó để lại trong stack của bạn |
|---|---|---|
| [Dapper](https://static.googleusercontent.com/media/research.google.com/en//archive/papers/dapper-2010-1.pdf) | 2010, Google TR | Mô hình trace/span và sampling, nền của Tempo và span OTel |
| [X-Trace](https://www.usenix.org/legacy/event/nsdi07/tech/full_papers/fonseca/fonseca.pdf) | 2007, NSDI | Propagation metadata trong request, tiền thân của `traceparent` |
| [Magpie](https://www.usenix.org/legacy/event/osdi04/tech/full_papers/barham/barham.pdf) | 2004, OSDI | Ghép event theo schema; Dapper trích làm tiền thân |
| [The Mystery Machine](https://www.usenix.org/system/files/conference/osdi14/osdi14-paper-chow.pdf) | 2014, OSDI | Suy ra quan hệ nhân quả từ log; cầu nối log và trace |
| [So, you want to trace…](https://www.pdl.cmu.edu/PDL-FTP/SelfStar/CMU-PDL-14-102.pdf) | 2014, CMU-PDL | Không gian thiết kế tracing; overhead dưới 1% khi có sampling |
| [Canopy](https://cs.brown.edu/people/jcmace/papers/kaldor2017canopy.pdf) | 2017, SOSP | Trace như dataset để phân tích; tiền thân của metrics sinh từ trace |
| [Pivot Tracing](https://cs.brown.edu/people/jcmace/papers/mace15pivot.pdf) | 2015, SOSP (Best Paper) | Baggage |
| [Universal Context Propagation](https://cs.brown.edu/people/jcmace/papers/mace18universal.pdf) | 2018, EuroSys | Tách propagation khỏi công cụ, giống Context/Propagators API |
| [Hindsight](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf) | 2023, NSDI | Retroactive sampling, phương án thay cho tail sampling |
| [SRE ch.6](https://sre.google/sre-book/monitoring-distributed-systems/) và [ch.10](https://sre.google/sre-book/practical-alerting/) | 2016, O'Reilly (miễn phí) | Golden signals; Borgmon là khuôn mẫu của Prometheus |
| [Gorilla](https://www.vldb.org/pvldb/vol8/p1816-teller.pdf) | 2015, VLDB | Nén XOR trong TSDB của Prometheus |
| [Monarch](https://www.vldb.org/pvldb/vol13/p3181-adams.pdf) | 2020, VLDB | Giới hạn của Borgmon, lý do có Mimir và native histogram |
| [DDSketch](https://www.vldb.org/pvldb/vol12/p2195-masson.pdf) | 2019, VLDB | Dòng nghiên cứu dẫn tới ExponentialHistogram của OTel |
| [Xu et al.](https://people.eecs.berkeley.edu/~jordan/papers/xu-etal-sosp09.pdf) | 2009, SOSP | Log mining, nền của structured logging và AIOps |
| [Scuba](https://www.vldb.org/pvldb/vol6/p1057-wiener.pdf) | 2013, VLDB | Wide event, sample rate gắn theo từng event |
| [Drain](https://jiemingzhu.github.io/pub/pjhe_icws2017.pdf) | 2017, ICWS | Tính năng pattern trong Loki |
| [USE Method](https://queue.acm.org/detail.cfm?id=2413037) | 2012, ACM Queue | Dashboard theo tài nguyên (node, container) |

## Nghiên cứu 2021–2026 đo được cái giá thật của telemetry

Các bài nền tảng giải thích vì sao stack được xây như vậy. Nghiên cứu 2021–2026 trả lời hai câu hỏi khác: nó tốn bao nhiêu, và còn thiếu gì. Có hai khoảng trống nên biết trước. Chưa có systematic review peer-reviewed nào dành riêng cho OpenTelemetry. Cũng chưa có nghiên cứu peer-reviewed nào đo mức độ áp dụng OTel, chẳng hạn bằng cách khai thác dữ liệu GitHub. Phần lớn tài liệu học thuật tập trung vào RCA và AIOps.

### Bốn bài survey nên đọc trước

- **Soldani & Brogi** (ACM Computing Surveys 2022) là taxonomy chuẩn cho anomaly detection và RCA, phân loại phương pháp theo loại telemetry mà nó dùng: logs, traces hay metrics ([DOI](https://doi.org/10.1145/3501297), [arXiv](https://arxiv.org/abs/2105.12378)).
- **Usman et al.** (IEEE Access 2022) là survey chung về observability cho microservice chạy trên container và edge ([DOI](https://doi.org/10.1109/ACCESS.2022.3193102)).
- **"Enjoy your observability"** của Li et al. (Empirical Software Engineering 2022) phỏng vấn kỹ sư ở 10 công ty. Kết quả: visualization và thống kê là cách phân tích trace phổ biến nhất, còn ML và data mining hiếm khi được dùng ([DOI](https://doi.org/10.1007/s10664-021-10063-9)). Nghĩa là cách bạn đang làm với Grafana/Tempo cộng RED metrics chính là cách làm chủ đạo trong ngành, chứ không lạc hậu.
- **Zhang et al.** (ACM Computing Surveys 2025) phân tích 183 bài về LLM cho AIOps giai đoạn 2020–2024. Đây là bản đồ đầy đủ nhất nếu bạn định cân nhắc các "AI assistant" chạy trên dữ liệu Grafana ([arXiv](https://arxiv.org/abs/2507.12472), [DOI](https://doi.org/10.1145/3746635)).

Ngoài bốn bài trên, preprint của Fang et al. (2025) gom 135 bài RCA theo mục tiêu sử dụng (triage nhanh hay sửa lỗi triệt để) thay vì theo loại dữ liệu ([arXiv](https://arxiv.org/abs/2510.19593)). Notaro et al. (ACM TIST 2021) là taxonomy AIOps của thời kỳ trước LLM ([DOI](https://doi.org/10.1145/3483424)).

### Overhead của OpenTelemetry phụ thuộc cấu hình, và export là điểm nghẽn

Bằng chứng peer-reviewed trực tiếp nhất về chi phí của OTel là bài của **Nõu, Talluri, Iosup và Bonetta** (ICPE 2025 Companion, Vrije Universiteit Amsterdam). Nhóm so sánh OpenTelemetry với Elastic APM trên workload microservice và serverless. Kết quả: throughput giảm **19–80%** và latency tăng tới **175%**, tùy cấu hình và môi trường. Kết luận then chốt là "Serializing trace data for export is the largest cause of overhead", và các biện pháp được thử là batching và compression ([PDF](https://atlarge-research.com/pdfs/2025-tracing-overhead-anou.pdf), [DOI](https://doi.org/10.1145/3680256.3721316), [code](https://github.com/atlarge-research/serverless-tracing-overhead)).

**Reichelt, Kühne và Hasselbring** (SSP 2021) mở rộng benchmark MooBench cho OTel Java agent và chạy trên Raspberry Pi 4. Kết quả là Kieker tốn overhead ít hơn inspectIT và OpenTelemetry một chút ([CEUR-WS](https://ceur-ws.org/Vol-3043/short3.pdf)). Thiết lập của hai nghiên cứu khác nhau quá xa nên không thể khái quát con số. Dù vậy, cả hai cùng chỉ về bước export/serialization. Với Node.js và Python, các đòn bẩy thực tế vì thế là BatchSpanProcessor, sampling sớm ngay trong SDK, một Collector agent chạy cục bộ và nén OTLP (suy luận).

**Borges et al.** (ICSA 2024, TU Berlin) nhận xét rằng các quyết định instrument hiện nay dựa vào "professional intuition". Nhóm đề xuất một phương pháp thực nghiệm để đánh giá các đánh đổi trong thiết kế observability, kèm công cụ OXN ([arXiv](https://arxiv.org/abs/2403.00633), [OXN](https://arxiv.org/abs/2407.09644)). Đây là khung lý thuyết cho việc chọn sampling rate dựa trên số liệu đo được thay vì cảm tính.

### Sampling và lưu trữ: từ "sample ít hơn" sang "lưu thông minh hơn"

Hướng nghiên cứu mạnh nhất hiện nay cho rằng đừng chọn giữa giữ hay bỏ trace nữa, mà hãy giữ mọi request ở dạng nén.

- **Hindsight** chỉ tốn overhead cỡ nano giây khi sinh dữ liệu trace và chịu được tải cỡ GB/s mỗi node ([arXiv](https://arxiv.org/abs/2202.05769)).
- **Mint** (ASPLOS 2025) tách trace thành pattern chung và tham số biến đổi. Nó thu mọi request nhưng chỉ tốn trung bình **2.7%** dung lượng lưu trữ và **4.2%** băng thông mạng ([arXiv](https://arxiv.org/abs/2411.04605)).
- **Tracezip** (ISSTA 2025) nén span trước khi truyền đi ([arXiv](https://arxiv.org/abs/2502.06318)).
- **AutoScope** (ACM TOSEM 2026) sample theo từng span thay vì cả trace. Nó giảm **81.2%** kích thước trace mà vẫn giữ **98.1%** span có lỗi ([arXiv](https://arxiv.org/abs/2509.13852)).
- **TraStrainer** (FSE 2024) dùng runtime state, tức metrics, để quyết định giữ trace nào ([DOI](https://doi.org/10.1145/3643748)). Ý tưởng tương ứng trong stack của bạn là giữ nhiều trace hơn khi Prometheus báo bất thường.
- **RADAR** (preprint 2026) là prototype dùng reinforcement learning, xây trực tiếp trên OpenTelemetry ([arXiv](https://arxiv.org/abs/2609.31292)).

Về phía log, LogShrink (ICSE 2024), LogLite (VLDB 2025) và LogFold (ICSE 2026) liên quan trực tiếp đến chi phí lưu trữ của Loki ([LogShrink](https://arxiv.org/abs/2309.09479), [LogLite](https://arxiv.org/abs/2507.10337), [LogFold](https://arxiv.org/abs/2603.20618)).

Cần nói rõ: tất cả các hệ thống trên đều là prototype nghiên cứu, không phải processor của Collector. Nhiều bài đến từ cùng vài nhóm (Sun Yat-sen University, CUHK), nên việc kiểm chứng độc lập còn hạn chế. Nhóm nghiên cứu cũng không tìm thấy so sánh peer-reviewed nào giữa các sampler này và `tail_sampling` processor của OTel Collector.

### RCA đa tín hiệu thắng RCA đơn tín hiệu, nhưng không phương pháp nào thắng ở mọi nơi

**Nezha** (FSE 2023) chuyển metrics, traces và logs về chung một dạng event và đạt **89.77%** top-1 accuracy ở mức vùng code và loại tài nguyên ([DOI](https://doi.org/10.1145/3611643.3616249), [code](https://github.com/IntelligentDDS/Nezha)). **Eadro** (ICSE 2023) chỉ ra rằng phương pháp chỉ dùng trace sẽ bỏ sót anomaly, và học chung trên traces, logs và KPI ([arXiv](https://arxiv.org/abs/2302.05092)). Nói cách khác, có thêm logs và metrics bên cạnh Tempo thật sự đáng công.

Các đánh giá nghiêm ngặt lại cho thấy kết quả phụ thuộc mạnh vào hệ thống. Pham, Ha và Zhang (ASE 2024) thử 9 phương pháp causal discovery và 21 phương pháp RCA, và kết luận "no method stands out in all situations" ([arXiv](https://arxiv.org/abs/2408.13729)). Cùng nhóm này công bố **RCAEval** (WWW 2025), gồm 735 ca lỗi trên 3 hệ thống và 15 baseline có thể tái lập ([arXiv](https://arxiv.org/abs/2412.17015)). Một audit năm 2026 (preprint) chỉ ra rằng leaderboard gộp che mất phương pháp thắng riêng ở từng hệ thống, với regret lên tới **24.8 điểm phần trăm** ([arXiv](https://arxiv.org/abs/2606.29159)). Các dataset mở như LO2 (PROMISE 2025) ([arXiv](https://arxiv.org/abs/2504.12067)) và PetShop của Amazon (CLeaR 2024) ([arXiv](https://arxiv.org/abs/2311.04806)) cho phép thử pipeline trước khi áp lên dữ liệu thật.

Bài học thực tế (suy luận): đầu tư vào khả năng tương quan giữa các tín hiệu. Cụ thể là resource attributes nhất quán, trace_id có mặt trong log (dùng derived fields của Loki) và exemplars trong Prometheus.

### LLM và agent cho on-call: giỏi sinh truy vấn, chưa đủ để tự tìm root cause

Nghiên cứu từ công nghiệp đã đặt nền cho hướng này. Ahmed et al. (ICSE 2023, Microsoft) là nghiên cứu quy mô lớn đầu tiên về việc dùng LLM gợi ý root cause và cách khắc phục cho sự cố cloud ([arXiv](https://arxiv.org/abs/2301.03797)). RCACopilot (EuroSys 2024) kết hợp quy trình thu bằng chứng có kịch bản với dự đoán của LLM, đạt accuracy tới 0.766 ([arXiv](https://arxiv.org/abs/2305.15778)). Xpert (ICSE 2024) dùng LLM sinh truy vấn KQL khi điều tra sự cố ([arXiv](https://arxiv.org/abs/2312.11988)).

Hai bài nhắm thẳng vào ngôn ngữ truy vấn trong stack của bạn. **PromCopilot** (preprint, DOI journal chưa xác nhận) chuyển câu hỏi tự nhiên thành PromQL nhờ một knowledge graph của hệ thống. Bài xây benchmark 280 câu hỏi và đạt **69.1%** với GPT-4 ([arXiv](https://arxiv.org/abs/2503.03114)). **"Chatting with Logs"** (preprint 2024) xây dataset NL2QL cho LogQL. Model được fine-tune sinh LogQL tốt hơn tới **75%** so với model chưa fine-tune ([arXiv](https://arxiv.org/abs/2412.03612)). Nhóm nghiên cứu không tìm thấy bài nào về việc LLM sinh TraceQL.

Các benchmark agent cho ra con số khá thực tế:

- **OpenRCA** (ICLR 2025) gồm 335 sự cố với hơn 68 GB telemetry. Model tốt nhất, Claude 3.5 chạy cùng một agent chuyên cho RCA, chỉ giải được **11.34%** ([ICLR PDF](https://proceedings.iclr.cc/paper_files/paper/2025/file/d29b8d53678015079e1d245c023e49d2-Paper-Conference.pdf)).
- **ITBench** cho thấy agent tốt nhất chỉ giải quyết **13.8%** kịch bản SRE ([arXiv](https://arxiv.org/abs/2502.05352)).
- **ORCA-bench** (preprint 2026) là benchmark gần stack của bạn nhất. Nó có 1,079 tác vụ RCA trên sáu ngày telemetry của một hệ thống instrument bằng OpenTelemetry, và agent truy vấn qua Prometheus, Jaeger và OpenSearch thông qua Grafana. Accuracy tốt nhất là **25.3%** ở mức Medium và **10.0%** ở mức Hard. Model yếu nhất bịa ra root cause trong 40% báo cáo. Bỏ quyền truy cập source code làm accuracy giảm ở mọi model ([arXiv](https://arxiv.org/abs/2607.28545)).
- **Cloud-OpsBench** (preprint 2026) cho accuracy 0.76 trên OnlineBoutique và 0.68 trên TrainTicket. Nhưng tỷ lệ "evidence closure", tức câu trả lời có bằng chứng đi kèm, chỉ là 0.38 và 0.15 ([arXiv](https://arxiv.org/abs/2603.00468)).

Một preprint khác năm 2026 cảnh báo ở chiều ngược lại. Trong 200 hệ thống microservice do agent viết, khi bị tiêm lỗi, các hệ thống này chỉ lộ tín hiệu lỗi cho tối đa **13.99%** sự cố, dù trong code có logging ([arXiv](https://arxiv.org/abs/2607.05785)). Kết luận thực tế: dùng LLM để sinh PromQL/LogQL và tóm tắt, với người duyệt mọi hành động. Nếu bạn dùng AI để viết service, hãy review riêng phần instrument OTel.

### eBPF zero-code tracing đã lên hội nghị hàng đầu

**DeepFlow** (SIGCOMM 2023) dùng eBPF để trace theo hướng network-centric, với implicit context propagation. Nó phủ cả gateway, service mesh, database, queue, DNS và NIC mà không cần sửa code ([DOI](https://doi.org/10.1145/3603269.3604823)). Nahida (preprint 2023) theo dõi được hơn 92% request khi tải đồng thời cao, đổi lại latency tăng 1.55–2.1% ([arXiv](https://arxiv.org/abs/2311.09032)). Các bài này cho thấy điểm yếu cốt lõi của zero-code tracing: ghép các span thành trace hoàn chỉnh. Hướng này bổ sung cho SDK chứ không thay thế được nó, đúng với cách OBI/Beyla tự định vị. Nhóm nghiên cứu chưa thấy nghiên cứu peer-reviewed nào đo overhead của OBI/Beyla hay của chính Collector.

| Bài 2021–2026 nên đọc trước | Nơi công bố | Con số chính | Ý nghĩa cho bạn |
|---|---|---|---|
| [Nõu et al., tracing overhead](https://atlarge-research.com/pdfs/2025-tracing-overhead-anou.pdf) | ICPE 2025 | Throughput −19–80% | Tối ưu export, batch và sample trước khi rollout |
| [Enjoy your observability](https://doi.org/10.1007/s10664-021-10063-9) | EMSE 2022 | 10 công ty, ML hiếm dùng | Visualization cộng RED metrics là chuẩn thực tế |
| [Soldani & Brogi](https://doi.org/10.1145/3501297) | ACM CSUR 2022 | Taxonomy RCA | Map từng signal sang phương pháp phân tích |
| [Hindsight](https://www.usenix.org/conference/nsdi23/presentation/zhang-lei) | NSDI 2023 | Overhead cỡ nano giây | Phương án thay cho tail sampling |
| [Mint](https://arxiv.org/abs/2411.04605) | ASPLOS 2025 | 2.7% dung lượng lưu trữ | Chi phí lưu trace (Tempo/S3) còn giảm được nhiều |
| [AutoScope](https://arxiv.org/abs/2509.13852) | TOSEM 2026 | −81.2% kích thước trace | Nhiều span auto-instrument giá trị thấp |
| [Nezha](https://doi.org/10.1145/3611643.3616249) | FSE 2023 | 89.77% top-1 | Tương quan cả ba signal mới có lợi |
| [RCA causal "How Far Are We?"](https://arxiv.org/abs/2408.13729) | ASE 2024 | 30 phương pháp, không có phương pháp thắng tuyệt đối | Hoài nghi các tuyên bố "causal AI" |
| [OpenRCA](https://proceedings.iclr.cc/paper_files/paper/2025/file/d29b8d53678015079e1d245c023e49d2-Paper-Conference.pdf) | ICLR 2025 | 11.34% | Mốc tham chiếu để đánh giá tuyên bố "AI RCA" |
| [ORCA-bench](https://arxiv.org/abs/2607.28545) | Preprint 2026 | 25.3% / 10.0% | Benchmark trên OTel + Prometheus + Grafana |
| [PromCopilot](https://arxiv.org/abs/2503.03114) | Preprint | 69.1% text-to-PromQL | Sinh PromQL từ câu hỏi tự nhiên |
| [Chatting with Logs](https://arxiv.org/abs/2412.03612) | Preprint 2024 | Fine-tune tốt hơn tới 75% | Bài duy nhất nhắm vào LogQL |
| [DeepFlow](https://doi.org/10.1145/3603269.3604823) | SIGCOMM 2023 | Zero-code | Lấp các điểm mù hạ tầng mà SDK không thấy |
| [Borges et al.](https://arxiv.org/abs/2403.00633) | ICSA 2024 | Phương pháp thực nghiệm | Chọn cấu hình observability dựa trên số liệu đo |

## Khảo sát ngành 2024–2026: OTel nằm đâu đó giữa 10% và 85%

Bài học lớn nhất từ các khảo sát ngành là con số "áp dụng OpenTelemetry" phụ thuộc gần như hoàn toàn vào cách đặt câu hỏi. Cùng một giai đoạn, các báo cáo cho ra những con số rất khác nhau:

| Câu hỏi khảo sát | Tỷ lệ OTel | Nguồn |
|---|---|---|
| "Đã đầu tư" (invested) | 85% (2024), 76% (2026) | [Grafana 2024](https://grafana.com/press/2024/03/12/grafana-labs-announces-updates-to-kubernetes-monitoring-solution-open-source-innovations-and-findings-from-2024-observability-survey/), [Grafana 2026](https://grafana.com/observability-survey/2026/) |
| "Standardized, migrating or testing" | 73% | [New Relic 2026](https://newrelic.com/press-release/20260922) |
| Đang dùng OTel | 48.5% | [EMA 2025](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf) |
| Dùng trong production (trung lập) | 39% → 49% | [CNCF 2025](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf) |
| "In production in some capacity" | 41% | [Grafana 2025](https://grafana.com/press/2025/03/25/grafana-labs-unveils-2025-observability-survey-findings-and-open-source-updates-at-kubecon-europe/) |
| Dùng trong production | 6% → 11% | [Elastic 2026](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf) |
| "Across all production workloads" | 10.3% | [Grafana 2026](https://grafana.com/observability-survey/2026/) |

Câu chuyện về OTel vì thế đã đổi từ "có dùng không" sang "dùng sâu đến đâu". Gần như ai cũng đã đầu tư, nhưng rất ít tổ chức phủ OTel kín toàn bộ production.

### Nguồn trung lập: CNCF và các khảo sát cộng đồng OTel

**CNCF Annual Survey** là nguồn nên đặt trọng số cao nhất. Bản khảo sát 2024 (công bố 1/4/2025, n=750) cho thấy Prometheus dùng trong production 73% và đang đánh giá 12%. OTel ở mức 39% production và 23% đánh giá, đứng đầu các dự án incubating. Jaeger ở mức 14% production ([CNCF 2024 PDF](https://www.cncf.io/wp-content/uploads/2025/04/cncf_annual_survey24_031225a.pdf)). Bản 2025 (công bố 20/1/2026, n=628, sai số ±3.3% ở độ tin cậy 90%) cho thấy **Prometheus 77% production và OTel 49% production, 26% đánh giá** ([CNCF 2025 PDF](https://www.cncf.io/wp-content/uploads/2026/01/CNCF_Annual_Survey_Report_final.pdf)). Cũng trong bản này, gần 20% người trả lời đã dùng profiling, và 82% người dùng container chạy Kubernetes trong production ([CNCF PR](https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/)). Prometheus đứng ở mức cao và ổn định, còn OTel đang tăng. Kết hợp cả hai như stack của bạn chính là cách làm chủ đạo.

OTel tốt nghiệp CNCF ngày **21/5/2026** ([CNCF announcement](https://www.cncf.io/announcements/2026/05/21/cloud-native-computing-foundation-announces-opentelemetrys-graduation-solidifying-status-as-the-de-facto-observability-standard/)). Thông cáo kèm theo nêu hơn 12,000 contributor từ hơn 2,800 công ty, cùng 1.36 tỷ lượt tải gói JS API và 1.3 tỷ lượt tải gói Python API trong 12 tháng. Cần cẩn thận khi trích số contributor, vì có ba con số đo ba thứ khác nhau: 12,000+ là tổng tích lũy từ 2019; 1,756 là số tác giả trong riêng năm 2025 ([CNCF velocity](https://www.cncf.io/blog/2026/02/09/what-cncf-project-velocity-in-2025-reveals-about-cloud-natives-future/)); còn con số 24,000+ trong thông cáo khảo sát không được giải thích. Linux Foundation Research không có báo cáo observability riêng nào trong giai đoạn 2024–2026 ([LF Research](https://www.linuxfoundation.org/research)).

Các khảo sát của chính các SIG trong OTel là nguồn thực dụng nhất cho bạn, dù mẫu là tự nguyện tham gia:

- **Prometheus–OTel interoperability** (22/9/2026, 81 người trả lời hợp lệ) là khảo sát liên quan nhất đến một stack OTel dùng backend Prometheus. Điểm dễ dùng tăng từ 3.1 lên 3.6/5, và tỷ lệ cho rằng hai công cụ "khó dùng chung" giảm từ 29% xuống 10%. 49% kết hợp Prometheus exporter với OTel receiver. Các điểm đau còn lại là label vs attribute, resource attributes, và quy tắc đặt tên cùng UTF-8 ([OTel blog](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/)).
- **Collector survey 2024**: 80.6% triển khai trên Kubernetes ([OTel blog](https://opentelemetry.io/blog/2024/otel-collector-survey/)). Bản follow-up 2026: 65% chạy hơn 10 Collector, và chỉ 39% thấy Collector Builder dễ dùng ([OTel blog](https://opentelemetry.io/blog/2026/otel-collector-follow-up-survey-analysis/)).
- **DevEx survey 2025** (n=218) liệt kê các điểm đau: tài liệu, ví dụ, debug cục bộ và cấu hình SDK ([OTel blog](https://opentelemetry.io/blog/2025/devex-survey/)).

### Khảo sát của vendor: Grafana gần stack của bạn nhất, mọi khảo sát đều có thiên lệch

**Grafana Labs Observability Survey** là khảo sát vendor sát với stack của bạn nhất, và đọc được miễn phí, không cần điền form. Bản 2026 (n=1,363 từ 76 quốc gia) cho thấy:

- 77% đã đầu tư vào Prometheus nhưng chỉ 21.3% dùng nó cho toàn bộ production. Với OTel, hai con số này là 76% và **10.3%**.
- 65% đầu tư vào cả hai.
- Chi phí là tiêu chí chọn công cụ số một năm thứ ba liên tiếp (65%).
- Alert fatigue là trở ngại lớn nhất khi xử lý sự cố (30%).
- 95% muốn AI giải thích được lý do đằng sau kết luận của nó.

([Grafana 2026](https://grafana.com/observability-survey/2026/)). Lưu ý cỡ mẫu tăng từ 306 (2024) lên 1,255 (2025) rồi 1,363, nên so sánh giữa các năm khá yếu ([Grafana 2024](https://grafana.com/observability-survey/2024/), [Grafana 2025](https://grafana.com/observability-survey/2025/)).

Các vendor khác:

- **New Relic Observability Forecast 2026** (n=2,575, khảo sát do ETR thực hiện): 73% đã chuẩn hóa, đang chuyển đổi hoặc đang thử OTel, chỉ 2% đã loại bỏ nó. Chi phí sự cố nghiêm trọng trung bình là $1.85 triệu/giờ. MTTD trung bình 41 phút, MTTR 54 phút ([New Relic PR](https://newrelic.com/press-release/20260922)). Đáng chú ý, khi tìm toàn văn trong PDF bản 2025 không thấy chữ "OpenTelemetry" lần nào ([New Relic 2025 PDF](https://newrelic.com/sites/default/files/2025-09/new-relic-2025-observability-forecast-report.pdf)).
- **Elastic "Landscape of Observability" 2026** (Dimensional Research, n=526): OTel trong production tăng từ 6% lên 11%, tỷ lệ dùng OTel distribution của vendor tăng từ 44% lên 60%, và 67% thường xuyên gặp chi phí phát sinh ngoài dự kiến ([Elastic 2026 PDF](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf)). Chuỗi số liệu của Elastic không nhất quán: bản 2024 ghi 9% trong production, còn bản 2026 lại ghi năm 2025 là 6%.
- **Splunk State of Observability 2025** (n=1,855, cần điền form): 59% than có quá nhiều công cụ rời rạc, 52% than có quá nhiều cảnh báo giả ([Cisco/Splunk PR](https://newsroom.cisco.com/c/r/newsroom/en/us/a/y2025/m10/splunk-report-shows-observability-is-a-business-catalyst-for-ai-adoption-customer-experience-and-product-innovation.html)).
- **EMA, "Taking Observability to the Next Level: OpenTelemetry's Emerging Role"** (3/2025, n=400, do sáu vendor tài trợ): báo cáo phân tích riêng về OTel. 48.5% đang dùng OTel, và một nửa cho rằng OTel đã đủ trưởng thành để triển khai ([EMA PDF](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf)).
- Hai nguồn hữu ích về chi phí: **Chronosphere** (2024, n=127) ghi nhận dữ liệu log tăng trung bình **250%** mỗi năm, liên quan trực tiếp đến chi phí Loki ([Chronosphere](https://chronosphere.io/learn/observability-log-data-trends/)). **PagerDuty** (2024) đưa ra mức $4,537/phút downtime ([PagerDuty](https://pagerduty.com/newsroom/study-cost-of-incidents)). Con số của PagerDuty không so sánh được với New Relic vì khác quần thể và khác định nghĩa.

### Giới analyst: Grafana Labs là Leader ba năm liền, và OTel đã thành yêu cầu tối thiểu

**Gartner Magic Quadrant for Observability Platforms**:

- 2024: 7 Leader trong 17 vendor ([Dynatrace PR](https://www.dynatrace.com/news/press-release/2024-gartner-magic-quadrant-for-observability-platforms/)).
- 2025: 8 Leader trong 20 vendor ([Network World 2025](https://www.networkworld.com/article/4032218/in-crowded-observability-market-gartner-calls-out-ai-capabilities-cost-optimization-devops-integration.html)).
- 2026 (13/7/2026): 8 Leader trong 19 vendor là Chronosphere, Coralogix, Datadog, Dynatrace, Elastic, **Grafana Labs**, IBM và New Relic. Splunk rơi xuống nhóm Challenger ([Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)).

Nhận định Gartner được trích nhiều nhất là "Many enterprise buyers now consider OpenTelemetry support a baseline requirement rather than a differentiator". Cũng theo Gartner, thị trường đạt **$14.3 tỷ vào năm 2028** ([Network World 2026](https://www.networkworld.com/article/4197973/ai-workloads-shake-up-observability-market.html)). Market Guide for Telemetry Pipelines dự báo 40% log telemetry sẽ đi qua một telemetry pipeline vào năm 2027, tăng từ dưới 20% năm 2024 ([bản do Mezmo cung cấp](https://www.mezmo.com/resources/gartner-market-guide-for-telemetry-pipelines)).

IDC công bố MarketScape về observability lần đầu vào tháng 11/2025, và có bản reprint miễn phí ([IDC qua Elastic](https://www.elastic.co/pdf/idc-marketscape-worldwide-observability-platforms-2025.pdf)). Forrester chỉ có Wave về AIOps (Q2 2025) ([Dynatrace PR](https://www.dynatrace.com/news/press-release/forrester-wave-aiops-platforms-q2-2025/)). Phần lớn kết quả của analyst đến tay công chúng qua thông cáo của vendor, và vendor chỉ quảng bá khi kết quả có lợi cho mình. Vì vậy, việc một vendor không ra thông cáo không nói lên điều gì.

| Báo cáo | Loại và mức thiên lệch | Truy cập | Bản mới nhất |
|---|---|---|---|
| [CNCF Annual Survey](https://www.cncf.io/reports/the-cncf-annual-cloud-native-survey/) | Trung lập | Mở | Khảo sát 2025, công bố 1/2026 |
| [Khảo sát cộng đồng OTel](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/) | Gần trung lập, mẫu tự chọn | Mở | Interop, 9/2026 |
| [Grafana Observability Survey](https://grafana.com/observability-survey/2026/) | Vendor, cộng đồng Grafana | Mở | 3/2026 |
| [New Relic Observability Forecast](https://newrelic.com/resources/report/observability-forecast/2026) | Vendor tài trợ, ETR thực hiện | Form (PDF bản 2025 mở) | 9/2026 |
| [Elastic Landscape of Observability](https://www.elastic.co/pdf/dimensional-research-2026-landscape-observability-white-paper.pdf) | Vendor tài trợ, Dimensional Research | PDF mở | 2/2026 |
| [Splunk State of Observability](https://www.splunk.com/en_us/form/state-of-observability.html) | Vendor tài trợ | Form | 10/2025 |
| [EMA về OTel](https://www.elastic.co/pdf/ema-elastic-taking-observability-to-the-next-level-march-2025.pdf) | Analyst, nhiều vendor tài trợ | PDF mở | 3/2025 |
| [Dynatrace State of Observability](https://www.dynatrace.com/news/press-release/state-of-observability-2025/) | Vendor tài trợ, mẫu là CIO | Form | 10/2025 |
| [PagerDuty Cost of Incidents](https://www.pagerduty.com/resources/learn/cost-of-downtime/) | Vendor tài trợ | PDF mở | 6/2024 |
| [Gartner MQ Observability Platforms](https://www.gartner.com/en/documents/8114397) | Analyst | Trả phí (reprint qua form của vendor) | 7/2026 |
| [IDC MarketScape](https://www.elastic.co/pdf/idc-marketscape-worldwide-observability-platforms-2025.pdf) | Analyst | Reprint mở | 11/2025 |

Khi đọc các báo cáo này, hãy để ý một quy luật thiên lệch. Vendor bán nền tảng AI hoặc full-stack (Dynatrace, Splunk, New Relic) thường báo cáo tỷ lệ dùng AI và ROI cao nhất. Các mẫu lấy từ cộng đồng (Grafana, CNCF) thì nhấn mạnh open source và chuẩn mở. Hãy đặt trọng số cao nhất cho số liệu của CNCF và cho những chỉ số có định nghĩa rõ ràng.

## Tài liệu riêng về OpenTelemetry: đọc trang status trước khi đọc sách

### Spec và mức ổn định quyết định cách bạn đưa log vào Loki

Trang [Specification Status Summary](https://opentelemetry.io/docs/specs/status/) là bảng tham chiếu chính thức về mức trưởng thành của từng signal:

- Tracing: "completely stable, and covered by long term support".
- Metrics: API và protocol stable, còn SDK ở trạng thái "mixed".
- Logs: Bridge API, SDK và protocol đều stable.
- Baggage: stable.
- Profiles: protocol ở mức "Development". Trong khi đó, trang spec của Profiles đã ghi "Status: Alpha" ([Profiles spec](https://opentelemetry.io/docs/specs/otel/profiles/)), nên có vẻ trang tổng hợp đang chậm cập nhật.

Trang quan trọng hơn với bạn là [Language Status](https://opentelemetry.io/status/). Với **JavaScript và Python, traces và metrics đã Stable, nhưng logs vẫn ở mức Development**. Java đã có logs Stable, Go ở mức Release candidate. Suy ra một hướng làm an toàn cho Node.js và Python tính đến tháng 10/2026: ghi log có cấu trúc ra stdout, dùng Collector (filelog receiver hoặc log của Docker/Kubernetes) để gom, rồi đẩy vào endpoint OTLP native của Loki. Hãy coi logs bridge trong SDK là thứ có thể thay đổi không tương thích.

Thêm vào đó, OTel đang chuẩn bị deprecate `Span.AddEvent` và `Span.RecordException`. Event mới nên được phát qua Logs API và tương quan với span thông qua context ([Deprecating Span Events API](https://opentelemetry.io/blog/2026/deprecating-span-events/)). Thay đổi này ảnh hưởng trực tiếp đến cách bạn ghi exception trong code Node.js và Python.

Bốn mốc spec khác đáng biết:

- **HTTP semconv thành stable từ v1.23.0 (11/2023).** Các attribute `net.peer.*`/`net.host.*` được đổi thành `client.*`/`server.*`, kèm biến môi trường chuyển đổi `OTEL_SEMCONV_STABILITY_OPT_IN=http` hoặc `http/dup` ([OTel blog](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/)). Đây là lý do dashboard cũ hay vỡ sau khi nâng cấp. Semconv hiện ở bản 1.44.0 ([semconv](https://opentelemetry.io/docs/specs/semconv/)).
- **Attribute Kubernetes lên release candidate (3/2026)** ([OTel blog](https://opentelemetry.io/blog/2026/k8s-semconv-rc/)), và **k8sattributes processor đạt v1.0.0 (9/2026)** ([OTel blog](https://opentelemetry.io/blog/2026/k8s-attributes-processor-v1/)). Hai mốc này liên quan trực tiếp đến việc gắn nhãn Kubernetes vào dữ liệu trong Loki, Tempo và Prometheus.
- **Declarative config stable (3/2026)**, bật qua biến `OTEL_CONFIG_FILE`. JavaScript đã có bản cài đặt, còn Python vẫn "underway" ([OTel blog](https://opentelemetry.io/blog/2026/stable-declarative-config/)). Nghĩa là Node.js frontend cấu hình được bằng một file YAML, còn Python worker vẫn phải dùng biến môi trường và code.
- **Hai lưu ý riêng cho Node.js:** OTel JS khuyến nghị dùng Node.js 20 trở lên ([OTel blog](https://opentelemetry.io/blog/2026/oteljs-nodejs-dos-mitigation/)). Bài "Don't Wrap OpenTelemetry" cảnh báo rằng tự viết wrapper quanh API vừa tốn thêm bộ nhớ vừa khó bảo trì ([OTel blog](https://opentelemetry.io/blog/2026/dont-wrap-opentelemetry/)).

### Whitepaper trung lập và báo cáo của dự án

**[CNCF TAG Observability Whitepaper](https://github.com/cncf/tag-observability/blob/main/whitepaper.md)** (v1.0, 10/2023) là tài liệu nền tảng trung lập nhất. Nó giải thích observability là gì, các signal (metrics, logs, traces, profiles, dumps), cách tương quan chúng, và các use case như SLI/SLO, alerting và RCA. Repo đã được lưu trữ (chỉ đọc) từ 18/12/2025, sau khi mảng này chuyển sang [TAG Operational Resilience](https://contribute.cncf.io/community/tags/operational-resilience/).

Hai báo cáo của dự án đáng đọc kèm. [OpenTelemetry Project Journey Report](https://www.cncf.io/reports/opentelemetry-project-journey-report/) (10/2023) cho mốc cơ sở: hơn 9,160 contributor và hơn 1,100 công ty. Bài [OpenTelemetry has graduated… now what?](https://www.cncf.io/blog/2026/08/31/opentelemetry-has-graduated-now-what/) (8/2026) nêu lộ trình sau khi tốt nghiệp: GenAI và agentic workload, observability cho browser và mobile, Weaver để quản trị schema, Packaging, và OpenTelemetry Injector.

### Case study: Skyscanner giống stack của bạn nhất, Mastodon đơn giản nhất

Ba case study 2026 của Developer Experience SIG nay được gom thành [Reference implementations](https://opentelemetry.io/docs/guidance/reference-implementations/) trong tài liệu OTel.

**Skyscanner** gần stack của bạn nhất ([OTel blog](https://opentelemetry.io/blog/2026/devex-skyscanner/)). Công ty chạy hơn 1,000 microservice trên 24 cluster Kubernetes production, chủ yếu Java nhưng có cả Python và Node.js.

- Topology gồm một ReplicaSet Collector làm gateway nhận OTLP, cộng một DaemonSet agent scrape các endpoint Prometheus.
- Họ sinh platform metrics từ span của Istio để tránh bùng nổ cardinality trong Prometheus, và bỏ hẳn HTTP/RPC metrics từ SDK.
- Nâng cấp HTTP semconv buộc họ viết lại các rule trong transform processor.
- Lời khuyên của họ: "memory limiter from day one".

**Mastodon** cho thấy một đội nhỏ vẫn chạy OTel được, nên là mô hình tốt khi bạn chuyển từ Docker Compose lên Kubernetes ([OTel blog](https://opentelemetry.io/blog/2026/devex-mastodon/)). Họ phục vụ khoảng 300k người dùng hoạt động mỗi ngày và khoảng 10 triệu request mỗi phút trên 70–80 pod, và chỉ một kỹ sư lo observability.

- Mỗi namespace có một Collector, không có tầng gateway hay agent.
- Triển khai bằng OTel Operator và Argo CD.
- Giữ khoảng 0.1% trace thành công và toàn bộ trace có lỗi.

**Adobe** chạy hàng nghìn Collector theo kiến trúc ba tầng ([OTel blog](https://opentelemetry.io/blog/2026/devex-adobe/)). Họ tách pipeline theo từng signal để một backend bị rate-limit không làm nghẽn các signal khác. Bài học của họ: "OTLP success doesn't guarantee end-to-end delivery" khi các Collector nối thành chuỗi.

Các case study cũ hơn vẫn hữu ích:

- [GitHub 2021](https://github.blog/engineering/infrastructure/why-and-how-github-is-adopting-opentelemetry/): lý do kinh doanh để chọn OTel.
- [eBay 2022](https://opentelemetry.io/blog/2022/why-and-how-ebay-pivoted-to-opentelemetry/): chuyển từ Elastic Beats sang OTel Collector.
- [Lightstep 2023](https://opentelemetry.io/blog/2023/end-user-q-and-a-04/): Target Allocator để thay cấu hình scrape của Prometheus trên Kubernetes.
- [Shopify, KubeCon EU 2020](https://raw.githack.com/sbueringer/kubecon-slides/master/slides/2020-kubecon-eu/Migrating%20to%20OpenTelemetry%20From%20a%20Custom%20Distributed%20Tracing%20Pipeline%20-%20Francis%20Bogsanyi,%20Shopify%20-KubeCon%20EU%202020.pdf): bài học khi migrate từ pipeline tracing tự xây.

Không case study nào công bố, từ nguồn gốc, số liệu tiết kiệm chi phí hay giảm overhead cụ thể.

### Benchmark: chưa có con số overhead chính thức cho Node.js hay Python

Chính dự án OTel nói rằng "impossible to come up with a single agent overhead estimate" ([Java agent performance](https://opentelemetry.io/docs/zero-code/java/agent/performance/)). Trang [Collector Benchmarks](https://opentelemetry.io/docs/collector/benchmarks/) chạy load test trên mỗi commit, với các kịch bản như 10k span/s, và cho tải dữ liệu JSON. Đây là nguồn tốt để đặt resource limit cho Collector trên Kubernetes.

Hai benchmark của vendor cho kết quả ngược chiều nhau:

- **Coroot** (vendor của một giải pháp eBPF cạnh tranh) đo OTel Go SDK ở 10,000 RPS. CPU tăng từ khoảng 2 lên 2.7 core (khoảng 35%), và p99 latency tăng từ 10 ms lên khoảng 15 ms ([Coroot](https://coroot.com/blog/opentelemetry-for-go-measuring-the-overhead/)).
- **Elastic** đo EDOT Java: startup tăng 23%, p95 tăng 5%, nhưng CPU chỉ tăng 0.43 điểm phần trăm ([Elastic](https://www.elastic.co/docs/reference/opentelemetry/edot-sdks/java/overhead)).

Cả hai đều chỉ đúng trong bối cảnh đo của mình. Không có benchmark tương tự cho Node.js hay Python.

### Các mảng mới nổi tính đến tháng 10/2026

| Mảng | Trạng thái | Nguồn |
|---|---|---|
| Profiles | Public Alpha từ 26/3/2026; cần Collector ≥ v0.148.0; eBPF profiler hỗ trợ Node.js V8; "should not be used for critical production workloads" | [OTel blog](https://opentelemetry.io/blog/2026/profiles-alpha/) |
| OBI (từ Grafana Beyla) | v1.0.0-rc.1 ngày 7/10/2026; tracing mạnh nhất với Go, Node.js, Python; bổ sung cho SDK | [GitHub](https://github.com/open-telemetry/opentelemetry-ebpf-instrumentation), [OTel blog](https://opentelemetry.io/blog/2025/obi-announcing-first-release/) |
| Trace-log correlation zero-code | Mới ra ngày 6/10/2026; liên quan trực tiếp đến liên kết Tempo ↔ Loki | [OTel blog](https://opentelemetry.io/blog/2026/obi-trace-log-correlation/) |
| GenAI semconv | Toàn bộ ở mức Development; tách sang repo riêng ngày 12/6/2026, chưa có release nào | [v1.42.0](https://github.com/open-telemetry/semantic-conventions/releases/tag/v1.42.0), [repo](https://github.com/open-telemetry/semantic-conventions-genai) |
| Entities | Development | [Spec](https://opentelemetry.io/docs/specs/otel/entities/data-model/) |
| OpAMP | Beta | [Spec](https://opentelemetry.io/docs/specs/opamp/) |

Beyla nay là bản phân phối của OBI do Grafana duy trì ([Grafana docs](https://grafana.com/docs/beyla/latest/obi/)). Trong các mảng mới, OBI là thứ gần production nhất với stack của bạn.

### Sách và hướng dẫn chuyên sâu

| Sách | Tác giả, nhà xuất bản, năm | Vì sao đọc |
|---|---|---|
| [Learning OpenTelemetry](https://www.oreilly.com/library/view/-/9781098147174/) | Ted Young & Austin Parker, O'Reilly, 3/2024 | Cuốn nên đọc đầu tiên: trung lập, viết bởi đồng sáng lập dự án và một maintainer lâu năm, phủ kiến trúc, Collector và chiến lược rollout |
| [Mastering OpenTelemetry and Observability](https://www.wiley.com/en-us/Mastering+OpenTelemetry+and+Observability%3A+Enhancing+Application+and+Infrastructure+Performance+and+Avoiding+Outages-p-9781394253128) | Steve Flanders, Wiley, 2024 | Đào sâu Collector và bối cảnh doanh nghiệp |
| [Practical OpenTelemetry](https://www.oreilly.com/library/view/practical-opentelemetry-adopting/9781484290750/) | Daniel Gomez Blanco (Skyscanner), Apress, 2023 | Mặt tổ chức của việc migrate; đọc kèm case study Skyscanner |
| [Cloud-Native Observability with OpenTelemetry](https://www.oreilly.com/library/view/cloud-native-observability-with/9781801077705/) | Alex Boten, Packt, 2022 | Ví dụ Python tốt, nhưng ra trước khi logs stable và trước semconv hiện hành |
| [Observability Engineering, 2nd ed.](https://www.honeycomb.io/observability-engineering-oreilly-book) | Majors, Fong-Jones, Miranda, Parker; O'Reilly, 6/2026 | Gần như viết lại hoàn toàn; thêm LLM và agent, frontend, chi phí, open source |
| [Distributed Tracing in Practice](https://www.oreilly.com/library/view/distributed-tracing-in/9781492056621/) | Parker, Spoonhower, Mace, Sigelman, Isaacs; O'Reilly, 2020 | Lý thuyết tracing từ chính tác giả Dapper, Magpie và Canopy; API đã cũ |
| [SRE Book](https://sre.google/sre-book/monitoring-distributed-systems/) và [SRE Workbook](https://sre.google/workbook/monitoring/) | Google, miễn phí | Nền tảng cho RED/USE và alert theo SLO |

Các hướng dẫn riêng cho stack của bạn:

- **[Using Prometheus as your OpenTelemetry backend](https://prometheus.io/docs/guides/opentelemetry/).** Bật cờ `--web.enable-otlp-receiver`; endpoint là `/api/v1/otlp/v1/metrics` và chỉ nhận OTLP/HTTP. Resource attributes trở thành metric `target_info`, với `job` lấy từ `service.name`.
- **Loki native OTLP.** Có từ Loki 3.0. Attribute được lưu dưới dạng structured metadata, và `lokiexporter` của Collector đã bị deprecate từ tháng 7/2024 ([Loki docs](https://grafana.com/docs/loki/latest/send-data/otel/native_otlp_vs_loki_exporter/)).
- **[docker-otel-lgtm](https://github.com/grafana/docker-otel-lgtm).** Một container gồm Collector, Prometheus, Tempo, Loki, Pyroscope và Grafana, tùy chọn thêm OBI. Chỉ dùng cho dev và demo ([Grafana docs](https://grafana.com/docs/opentelemetry/docker-lgtm/)).
- **[Tổng kết năm 2026 của Grafana về OTel](https://grafana.com/blog/opentelemetry-and-grafana-labs-whats-new-and-whats-next-in-2026/).** Đáng chú ý nhất là resource attributes nay có thể được nâng thành label trong endpoint OTLP của Prometheus.
- **[OpenTelemetry Demo](https://opentelemetry.io/docs/demo/) (Astronomy Shop).** Có sẵn các service viết bằng Node.js và Python.

### Thought leadership: cuộc tranh luận "Observability 2.0"

Hai bài phê bình định hình cuộc tranh luận về khái niệm. Ben Sigelman, đồng tác giả Dapper và đồng sáng lập OpenTracing, viết "Three Pillars with Zero Answers" (2019). Ông lập luận rằng metrics, logs và traces chỉ là dữ liệu, và observability phải được đo bằng khả năng phát hiện và thu hẹp vấn đề ([InfoQ](https://www.infoq.com/news/2019/02/rethinking-observability)). Charity Majors (8/2024) định nghĩa "Observability 1.0" là ba trụ cột với nhiều nguồn sự thật tách rời, và "Observability 2.0" là wide structured events làm nguồn sự thật duy nhất ([charity.wtf](https://charity.wtf/2024/08/07/is-it-time-to-version-observability-signs-point-to-yes/), [SREcon24](https://www.usenix.org/conference/srecon24americas/presentation/majors-plenary)).

Theo định nghĩa của Majors, stack Prometheus + Loki + Tempo là kiến trúc "1.0" nhiều kho lưu trữ (suy luận). Việc tương quan giữa các kho dựa vào exemplars, derived fields và tính năng trace-to-logs. Bạn vẫn mượn được thực hành wide event mà không cần đổi backend. Jeremy Morrell hướng dẫn cách làm: biến một span "chính" thành wide event bằng cách cho middleware gắn thêm hàng trăm attribute vào nó ([Morrell](https://jeremymorrell.dev/blog/a-practitioners-guide-to-wide-events/)). Sau đó bạn truy vấn các attribute này bằng TraceQL. Boris Tane có một bài nhập môn ngắn về chủ đề này ([Tane](https://boristane.com/blog/observability-wide-events-101/)). Chỉ cần cẩn thận với cardinality khi chuyển span thành metric cho Prometheus.

## Lộ trình đọc sáu chặng cho Node.js frontend và Python worker

Lộ trình đi theo nguyên tắc làm trước, lý thuyết sau. Bạn dựng stack và nhìn thấy dữ liệu trước, rồi đọc bài báo để giải thích những gì vừa thấy, sau đó mới lo đến quy mô, chi phí và tầm nhìn nghiên cứu. Thứ tự này khác với danh sách đọc thuần học thuật, vốn bắt đầu từ Kalman và Magpie. Với người đang học, đọc Dapper sẽ dễ hiểu hơn nhiều sau khi đã từng thấy một trace bị đứt giữa Node.js và Python trong Tempo.

| Chặng | Đọc gì | Mục tiêu với stack của bạn |
|---|---|---|
| 1. Khái niệm | [CNCF Observability Whitepaper](https://github.com/cncf/tag-observability/blob/main/whitepaper.md); [SRE ch.6](https://sre.google/sre-book/monitoring-distributed-systems/) | Nắm signal, cách tương quan, golden signals trước khi đọc tài liệu vendor |
| 2. Dựng stack trên Docker Compose | [docker-otel-lgtm](https://grafana.com/docs/opentelemetry/docker-lgtm/); *[Learning OpenTelemetry](https://www.oreilly.com/library/view/-/9781098147174/)*; [Prometheus OTLP guide](https://prometheus.io/docs/guides/opentelemetry/); [Loki native OTLP](https://grafana.com/docs/loki/latest/send-data/otel/); [Language Status](https://opentelemetry.io/status/) | Đẩy trace và metric từ Node.js và Python vào LGTM; chọn đường đi an toàn cho log vì logs SDK của JS/Python còn ở mức Development |
| 3. Propagation giữa frontend và worker | [Dapper](https://static.googleusercontent.com/media/research.google.com/en//archive/papers/dapper-2010-1.pdf); [X-Trace](https://www.usenix.org/legacy/event/nsdi07/tech/full_papers/fonseca/fonseca.pdf); [W3C Trace Context](https://www.w3.org/TR/trace-context/); [OTel Sampling](https://opentelemetry.io/docs/concepts/sampling/) | Hiểu `traceparent`, vì sao trace bị đứt, và head vs tail sampling |
| 4. Chuyển lên Kubernetes | [Mastodon](https://opentelemetry.io/blog/2026/devex-mastodon/); [Skyscanner](https://opentelemetry.io/blog/2026/devex-skyscanner/); [Adobe](https://opentelemetry.io/blog/2026/devex-adobe/); [k8sattributes v1.0](https://opentelemetry.io/blog/2026/k8s-attributes-processor-v1/); [Collector Benchmarks](https://opentelemetry.io/docs/collector/benchmarks/); [Prometheus–OTel interop survey](https://opentelemetry.io/blog/2026/otel-prometheus-interoperability/) | Chọn topology Collector, bật memory_limiter, kiểm soát cardinality, gắn attribute Kubernetes |
| 5. Hiệu năng và chi phí | [Nõu et al. ICPE 2025](https://atlarge-research.com/pdfs/2025-tracing-overhead-anou.pdf); [Hindsight](https://www.usenix.org/system/files/nsdi23-zhang-lei.pdf); [Mint](https://arxiv.org/abs/2411.04605); [Grafana Survey 2026](https://grafana.com/observability-survey/2026/) | Tự đo overhead trên chính service của mình; biết các lựa chọn ngoài head/tail sampling |
| 6. Chiều sâu và tương lai | [Observability Engineering 2nd ed.](https://www.honeycomb.io/observability-engineering-oreilly-book); [Gorilla](https://www.vldb.org/pvldb/vol8/p1816-teller.pdf); [Drain](https://jiemingzhu.github.io/pub/pjhe_icws2017.pdf); [Pivot Tracing](https://cs.brown.edu/people/jcmace/papers/mace15pivot.pdf); [ORCA-bench](https://arxiv.org/abs/2607.28545); [CNCF Annual Survey](https://www.cncf.io/reports/the-cncf-annual-cloud-native-survey/) (đọc hàng năm) | Hiểu cơ chế bên trong Prometheus và Loki, triết lý wide event, giới hạn của AI RCA |

Một vài lưu ý riêng cho tổ hợp Node.js và Python:

- **Node.js frontend:** dùng được declarative config ngay, nên chạy Node.js 20 trở lên ([OTel JS](https://opentelemetry.io/blog/2026/oteljs-nodejs-dos-mitigation/)), và bài wide events của Morrell viết đúng cho kiểu service này.
- **Python worker:** vẫn phải cấu hình bằng biến môi trường. Sách của Boten có nhiều ví dụ Python, nhưng cần đối chiếu tên API với semconv hiện hành.
- **Cả hai:** eBPF profiler của OTel hỗ trợ cả Node.js V8 lẫn Python ([OTel blog](https://opentelemetry.io/blog/2024/elastic-contributes-continuous-profiling-agent/)), nên profiling sẽ là signal thứ tư bạn thử nghiệm được khi nó ra khỏi giai đoạn alpha.

## Kết luận

Các bài báo nền tảng có giá trị thực tế cao vì một số hành vi của stack chính là hệ quả trực tiếp của chúng. Thuật toán nén chunk của Prometheus và tính năng pattern của Loki là hậu duệ ở mức mã nguồn của Gorilla và Drain. Những hạn chế của Borgmon mà Monarch chỉ ra năm 2020, như thiếu schema và dữ liệu metadata rời rạc, khá giống các điểm đau mà khảo sát Prometheus–OTel năm 2026 vẫn còn liệt kê: label vs attribute, resource attributes, quy tắc đặt tên. Liên hệ này là suy luận, nhưng nó gợi ý rằng mismatch giữa hai mô hình dữ liệu là vấn đề cấu trúc chứ không phải lỗi tạm thời. Khi bạn gặp lỗi về `target_info` hay về việc đổi tên attribute, bài báo thường giải thích tận gốc tốt hơn tài liệu hướng dẫn.

Nghiên cứu gần đây và thực tế đang hội tụ về cùng một điểm: lợi ích lớn nhất đến từ khả năng tương quan giữa các signal, chứ không phải từ việc thu thêm dữ liệu. RCA đa tín hiệu (Nezha, Eadro) thắng RCA đơn tín hiệu. AI agent vẫn kẹt ở mức 10–25% và hay đưa ra câu trả lời không kèm bằng chứng. Các kỹ thuật tiết kiệm chi phí ấn tượng nhất (Mint, AutoScope) vẫn chỉ là prototype. Thứ rẻ nhất mà một người mới học làm đúng được ngay từ ngày đầu là resource attributes nhất quán, trace_id trong mọi dòng log, exemplars trong metrics, và semconv được ghim phiên bản. Đó cũng chính là điều kiện tiên quyết để mọi công cụ AI sau này hoạt động được. Cuối cùng, văn liệu còn thiếu benchmark overhead cho Node.js và Python, cũng như nghiên cứu peer-reviewed về mức độ áp dụng OTel. Vì vậy, một thí nghiệm đo đạc cẩn thận trên stack Docker Compose của bạn không chỉ là bài tập học. Nó lấp đúng một khoảng trống mà cả giới học thuật lẫn chính dự án OTel đều thừa nhận là chưa có câu trả lời.
