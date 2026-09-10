Tôi giải thích theo thứ tự phụ thuộc — mấy khái niệm này xây lên nhau, đọc rời rạc sẽ khó hiểu.

## 1. SFU — Selective Forwarding Unit

Đây là **kiểu topology của server media**. Để hiểu SFU phải so với hai kiểu kia. Lấy phòng 5 người, mỗi luồng video 1 Mbps:

| Topology | Client upload | Client download | CPU server | Vấn đề |
|---|---|---|---|---|
| **Mesh** (P2P thuần) | 4 Mbps (gửi riêng cho từng người) | 4 Mbps | 0 | Chết ở 4G/upload ADSL. Không quá 4–5 người |
| **MCU** (Multipoint Control Unit) | 1 Mbps | 1 Mbps | **Rất cao** — decode 5 luồng, trộn thành 1 khung, encode lại cho từng người | Đắt, thêm 200–500ms latency, client không tự chọn layout |
| **SFU** | 1 Mbps | 4 Mbps | Thấp — chỉ đọc header RTP rồi forward | Client phải decode nhiều luồng |

Chữ **"Selective"** là điểm cốt lõi: SFU **không decode media**, nó chỉ nhìn RTP header và quyết định *forward packet nào cho ai*. Nó không biết trong payload là hình gì.

Ví dụ dễ hình dung với nền tảng iOS của bạn:

- **MCU** = bạn render tất cả video vào một `UIImage` duy nhất rồi gửi cái ảnh đó đi. Người nhận không thể tách ra.
- **SFU** = bạn gửi từng `CALayer` riêng, client tự `addSublayer` và tự sắp layout.

Vì không decode nên SFU rẻ và scale tốt — đây là kiến trúc mặc định của mọi hệ thống hiện đại: LiveKit, mediasoup, Janus, Jitsi, Zoom, Google Meet. MCU giờ chỉ còn dùng khi cần xuất một luồng duy nhất ra ngoài (ví dụ ghi file, hoặc bridge sang RTMP để đẩy lên YouTube).

## 2. Origin, Edge, CDN

Ba tầng của một hệ thống phân phối:

**Origin** — server gốc, nơi duy nhất có bản dữ liệu thật. Trong live stream, origin là chỗ nhận stream từ broadcaster.

**Edge** — server trung gian đặt **gần người xem về mặt network**, không phải "gần" theo km mà là ít hop, ít RTT. Còn gọi là **PoP** (Point of Presence). Việt Nam có PoP của Cloudflare, Akamai, AWS ở Hà Nội và TP.HCM.

**CDN** (Content Delivery Network) = tập hợp hàng trăm–hàng nghìn edge + cơ chế tự động đưa user tới edge gần nhất (anycast IP hoặc GeoDNS) + logic cache.

Con số cụ thể: user Hà Nội xem stream có origin ở Singapore.

| | Không CDN | Có CDN |
|---|---|---|
| RTT | ~40–60 ms | ~5–10 ms (PoP Hà Nội) |
| 100k viewer xin cùng 1 segment | Origin phải gửi 100k lần | Edge fetch origin **1 lần**, phục vụ 100k lần từ cache |
| Băng thông origin | 200 Gbps | ~2 Mbps |

Cái "fetch 1 lần, phục vụ 100k lần" chính là lý do CDN giải quyết được mega live. Nhưng nó **chỉ hoạt động với dữ liệu cache được** — tức file HTTP tĩnh, có URL cố định.

Chỗ hay gây nhầm: trong WebRTC người ta cũng nói "edge SFU", nhưng **edge SFU không cache được** vì media realtime là unicast riêng cho từng người, không có URL, không lặp lại. Edge SFU giảm được latency và cho phép chia tải, nhưng mỗi viewer vẫn tốn một luồng riêng. Đó là lý do WebRTC không scale rẻ như HTTP.

Bạn thực ra dùng CDN mỗi ngày: `pub.dev`, CocoaPods CDN, Firebase Hosting đều là CDN.

## 3. WHIP (và WHEP)

Vấn đề gốc: **WebRTC không định nghĩa signaling**. Spec chỉ nói "hai bên phải trao đổi SDP và ICE candidate bằng cách nào đó" — cách nào là việc của bạn. Kết quả là mỗi vendor tự làm: socket.io, gRPC, JSON custom, protobuf... Đổi nhà cung cấp là viết lại toàn bộ tầng signaling của client.

**WHIP** = WebRTC-HTTP Ingestion Protocol (RFC 9725). Nó chuẩn hoá signaling cho hướng **đẩy stream lên** thành đúng một HTTP request:

```http
POST /whip/live-room-42 HTTP/1.1
Authorization: Bearer <token>
Content-Type: application/sdp

v=0
o=- 123 2 IN IP4 127.0.0.1
...SDP offer của client...
```

```http
HTTP/1.1 201 Created
Content-Type: application/sdp
Location: /whip/resource/abc123

...SDP answer của server...
```

Kết thúc stream: `DELETE /whip/resource/abc123`. Hết. Không WebSocket, không state machine riêng, không SDK độc quyền.

**WHEP** (WebRTC-HTTP Egress Protocol) là bản đối xứng cho hướng **lấy stream về để xem** — vẫn đang ở dạng draft nhưng đã được implement rộng.

Ý nghĩa thực tế: WHIP là **thứ thay thế RTMP**. RTMP sinh ra từ thời Flash, chạy trên TCP, latency 2–5s, và không có đường chuẩn để dùng codec mới. Bảng so sánh nhanh cho đường ingest:

| | RTMP | SRT | WHIP |
|---|---|---|---|
| Transport | TCP | UDP + ARQ | UDP (WebRTC) |
| Latency | 2–5 s | 0.3–1 s | 0.1–0.3 s |
| Codec | H.264/AAC (bó buộc) | tuỳ ý | tuỳ ý (VP9, AV1, Opus) |
| Chạy được từ browser | Không | Không | **Có** |

## 4. Audience

Đây **không phải thuật ngữ kỹ thuật** mà là cách phân loại role trong phòng, và ranh giới này quyết định kiến trúc:

| Role | Publish media? | Subscribe? | Số lượng |
|---|---|---|---|
| **Publisher / broadcaster / host** | Có | Có | 1 |
| **Guest / co-host** ("stage") | Có | Có | 2–20 |
| **Audience / viewer / subscriber** | **Không** | Có | 100.000+ |

Vì audience **chỉ nhận, không gửi**, luồng dữ liệu của họ là một chiều và **giống nhau cho mọi người** → cache được → phân phối được bằng HTTP CDN với giá gần như bằng 0 mỗi người thêm vào.

Còn stage thì hai chiều, mỗi người một luồng khác nhau, phải realtime → buộc dùng WebRTC/SFU, đắt.

Đây là lý do ở câu trả lời trước tôi nói phải tách hai nhóm này. Và khi bạn "mời một viewer lên sóng", về mặt kỹ thuật là **đổi role và đổi protocol** cho riêng người đó: rời HLS player, bắt tay WebRTC qua WHIP. Đó cũng là lúc duy nhất TURN có thể cần đến — cho 1 người, không phải 100k người.

## 5. LL-HLS

**HLS gốc** (2009) hoạt động rất "thô": cắt video thành từng file segment 6–10 giây, ghi ra đĩa, cập nhật một file playlist `.m3u8` liệt kê các segment. Player poll lại playlist định kỳ, thấy segment mới thì tải về.

Player cần buffer ~3 segment để chống giật → **latency 18–30 giây**. Đó là lý do bạn xem bóng đá qua app thì biết tỉ số sau người ngồi cạnh dùng TV.

**LL-HLS** (Low-Latency HLS, Apple giới thiệu 2019) giữ nguyên mô hình HTTP nhưng thêm 4 cơ chế:

| Cơ chế | Làm gì |
|---|---|
| **Partial segment** (`#EXT-X-PART`) | Chia segment thành "part" 200–500 ms, publish ngay khi encode xong thay vì chờ đủ 6s |
| **Blocking playlist reload** | Client gửi request kèm `_HLS_msn`/`_HLS_part`; **server giữ request lại** đến khi có part mới mới trả về. Không còn polling, không còn độ trễ do chờ chu kỳ poll |
| **Preload hint** (`#EXT-X-PRELOAD-HINT`) | Client request trước part chưa tồn tại, server trả dần khi có |
| **Delta playlist** | Chỉ trả phần playlist thay đổi, không gửi lại toàn bộ danh sách |

Kết quả: **latency 2–5 giây**, vẫn chạy trên HTTP CDN thông thường, vẫn cache được.

Bảng chọn protocol theo yêu cầu latency:

| Protocol | Latency | Cache/CDN | Chi phí mỗi viewer thêm |
|---|---|---|---|
| HLS thường | 15–30 s | Có | ~0 |
| **LL-HLS / LL-DASH (CMAF chunked)** | 2–5 s | Có | ~0 |
| WebRTC qua SFU | 0.1–0.5 s | **Không** | Tuyến tính, đắt |

Với iOS: `AVPlayer` hỗ trợ LL-HLS native từ iOS 14, không cần thư viện gì. Flutter `video_player` bọc `AVPlayer`/`ExoPlayer` nên cũng dùng được — chỉ cần server trả playlist đúng chuẩn.

## 6. Simulcast vs SVC

Cả hai giải cùng một vấn đề: **người xem có băng thông rất khác nhau** (một người 4G 500 kbps, một người fiber 50 Mbps), nhưng broadcaster chỉ encode một lần.

**Simulcast** — encode **nhiều lần độc lập**, tạo ra N bitstream riêng biệt, gửi tất cả lên SFU. SFU chọn một cái để forward cho từng viewer.

```
Camera ──> Encoder ×3 ──> [240p 200k] ┐
                          [480p 700k] ├──> SFU ──> chọn 1 cho mỗi viewer
                          [1080p 2.5M]┘
```

**SVC** (Scalable Video Coding) — encode **một lần**, ra **một bitstream duy nhất có cấu trúc phân lớp lồng nhau**. Layer thấp tự giải mã được; layer cao cần layer thấp làm nền.

```
Camera ──> Encoder ×1 ──> [base 240p | +480p | +1080p] ──> SFU ──> chỉ DROP packet layer trên
```

Khác biệt thực tế:

| | Simulcast | SVC |
|---|---|---|
| Upload của broadcaster | ~1.3–1.5× layer cao nhất | ~1.1–1.2× |
| CPU encode | ×N | ×1 (nhưng mỗi lần phức tạp hơn) |
| Hạ layer khi mạng xấu | Phải **chờ keyframe** của layer đích → 1–2 s mờ/đóng băng | **Tức thì**, chỉ bỏ packet |
| Codec cần | H.264 là đủ | VP9 hoặc AV1 |
| Hardware encoder mobile | Hỗ trợ tốt | Hạn chế |

`scalabilityMode` trong code có 3 trục:

- **L** = spatial layer (độ phân giải): `L3` = 3 mức resolution
- **T** = temporal layer (framerate): `T3` = 30/15/7.5 fps
- `L1T3` = 1 resolution, 3 mức framerate. `L3T3` = 3×3 = 9 tổ hợp.

Ở câu trả lời trước tôi để `L1T3` cho từng rid của simulcast — nghĩa là mỗi độ phân giải còn chia thêm 3 mức framerate, cho SFU thêm lựa chọn khi mạng xấu mà không cần đổi resolution.

Lưu ý thực tế cho iOS: Apple silicon có hardware **decode** AV1 (từ A17 Pro) nhưng chưa có hardware **encode** AV1 — encode AV1/VP9 SVC trên iPhone phải làm bằng software, tốn pin và nóng máy. Nên trên mobile hiện tại **H.264 simulcast vẫn là lựa chọn mặc định**, còn SVC hợp lý hơn khi encode ở server. Điểm này thay đổi theo từng thế hệ chip nên bạn nên kiểm tra lại `VTCopyVideoEncoderList()` trên thiết bị đích trước khi chốt.
