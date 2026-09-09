Đây là sơ đồ để nắm nhanh vai trò từng thành phần:## Khác biệt cốt lõi

Điểm dễ lẫn nhất: **STUN và TURN là *server/protocol*, còn ICE là *framework/algorithm*** dùng cả hai để ra quyết định. Chúng không cùng một tầng khái niệm.

| | Bản chất | Nhiệm vụ | Media có đi qua nó? | Cost |
|---|---|---|---|---|
| **STUN** (RFC 8489) | Protocol + server rất nhẹ | Cho client biết `public IP:port` mà NAT map cho nó | ❌ Không | Gần như 0 |
| **TURN** (RFC 8656) | Protocol + relay server | Đứng làm trung gian chuyển tiếp packet khi P2P không thể thiết lập | ✅ Có, 100% traffic | Tốn bandwidth thật (đắt) |
| **ICE** (RFC 8445) | Framework/state machine trên client | Gom candidate → ghép pair → connectivity check → chọn đường tốt nhất | Không phải server | 0 |

TURN server luôn là superset của STUN server: `coturn` chạy một process phục vụ cả hai. Nên khi bạn thấy config `stun:turn.example.com:3478` và `turn:turn.example.com:3478` trỏ cùng host — đó là bình thường, không phải sai.

## ICE candidate types — nơi ba khái niệm gặp nhau

ICE gom địa chỉ ứng viên (candidate) từ nhiều nguồn:

| Type | Viết tắt trong SDP | Nguồn | Ý nghĩa |
|---|---|---|---|
| Host | `typ host` | Local NIC | IP LAN (192.168.x.x), Wi-Fi/cellular interface |
| Server reflexive | `typ srflx` | **STUN** | Public IP:port do NAT map — dùng cho P2P |
| Peer reflexive | `typ prflx` | Phát hiện trong lúc connectivity check | Địa chỉ mới lộ ra từ peer, không đoán trước được |
| Relay | `typ relay` | **TURN** | Địa chỉ trên TURN server, media bị relay |

Đọc trong SDP thực tế:

```
a=candidate:1 1 udp 2122260223 192.168.1.9 54321 typ host
a=candidate:2 1 udp 1686052607 113.161.20.44 54321 typ srflx raddr 192.168.1.9 rport 54321
a=candidate:3 1 udp 41885439 45.77.1.10 60123 typ relay raddr 113.161.20.44 rport 54321
```

Con số `2122260223 / 1686052607 / 41885439` là **priority** — ICE tự ưu tiên `host > srflx > relay`. Đây chính là lý do TURN chỉ được dùng khi hết cách: nó có priority thấp nhất.

Điều nhiều người không biết: **connectivity check của ICE cũng dùng chính STUN Binding Request**, nhưng gửi trực tiếp peer-to-peer (không qua server), có thêm attribute `USERNAME`/`MESSAGE-INTEGRITY` từ `ice-ufrag`/`ice-pwd`. Vậy nên STUN xuất hiện ở hai chỗ khác nhau: *discovery* (tới server) và *validation* (tới peer).

## Khi nào buộc phải có TURN

Phụ thuộc loại NAT của **cả hai** đầu:

| NAT A × NAT B | Kết quả |
|---|---|
| Full-cone / Restricted-cone | STUN đủ, P2P thành công |
| Port-restricted × Port-restricted | Thường vẫn được nhờ port prediction, không đảm bảo |
| **Symmetric × Symmetric** | ❌ Bắt buộc TURN |
| Firewall doanh nghiệp chặn UDP | ❌ Bắt buộc TURN over TCP/TLS 443 |
| Carrier-grade NAT (4G/5G VN rất phổ biến) | Thường phải TURN |

Thực tế production: khoảng **8–20% session** phải fallback sang TURN. Nếu bạn thấy tỉ lệ relay > 30%, thường là do thiếu candidate `srflx` (STUN bị block) chứ không phải NAT.

## Cấu hình production

Flutter (`flutter_webrtc`):

```dart
final config = <String, dynamic>{
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {
      'urls': [
        'turn:turn.example.com:3478?transport=udp',
        'turn:turn.example.com:3478?transport=tcp',
        'turns:turn.example.com:5349?transport=tcp', // vượt firewall
      ],
      'username': cred.username,   // time-limited, KHÔNG hardcode
      'credential': cred.password,
    },
  ],
  'iceTransportPolicy': 'all',        // 'relay' để force test TURN
  'bundlePolicy': 'max-bundle',
  'rtcpMuxPolicy': 'require',
  'iceCandidatePoolSize': 2,
  'sdpSemantics': 'unified-plan',
};
```

iOS (`WebRTC` framework, Swift):

```swift
let ice = RTCIceServer(
    urlStrings: [
        "turn:turn.example.com:3478?transport=udp",
        "turns:turn.example.com:5349?transport=tcp"
    ],
    username: cred.username,
    credential: cred.password
)
let config = RTCConfiguration()
config.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"]), ice]
config.sdpSemantics = .unifiedPlan
config.continualGatheringPolicy = .gatherContinually  // quan trọng khi đổi Wi-Fi ↔ 4G
config.iceTransportPolicy = .all
config.bundlePolicy = .maxBundle
```

`continualGatheringPolicy = .gatherContinually` là thứ hay bị bỏ sót trên mobile — nó cho phép ICE restart mượt khi user rời Wi-Fi ra 4G.

**TURN credential phải là time-limited (RFC 5766 §10.2)**, sinh ở backend chứ không nhét trong app binary:

```dart
// Backend logic, minh hoạ phía Dart
String username = '${DateTime.now().add(Duration(hours: 12))
    .millisecondsSinceEpoch ~/ 1000}:$userId';
String password = base64Encode(
  Hmac(sha1, utf8.encode(turnSharedSecret)).convert(utf8.encode(username)).bytes,
);
```

Tương ứng trong `turnserver.conf`:

```conf
listening-port=3478
tls-listening-port=5349
external-ip=45.77.1.10/10.0.0.5    # public/private nếu chạy sau NAT (AWS/GCP)
realm=turn.example.com
use-auth-secret
static-auth-secret=<shared-secret>
fingerprint
no-multicast-peers
total-quota=1200
```

## Cách verify (theo thứ tự)

1. **Trickle ICE tool** — `https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/`. Nhập server của bạn. Phải thấy đủ `srflx` **và** `relay`. Chỉ có `host` ⇒ server sai hoặc port bị block.
2. **Test TURN riêng biệt** — force relay bằng `iceTransportPolicy: 'relay'`. Nếu call vẫn chạy ⇒ TURN OK. Đây là bài test quan trọng nhất, vì lỗi TURN thường bị che bởi P2P thành công.
3. **CLI kiểm tra server** — `turnutils_uclient -T -u user -w pass turn.example.com`.
4. **Kiểm tra pair đã chọn trong app**:

```dart
final stats = await pc.getStats();
for (final r in stats) {
  if (r.type == 'candidate-pair' && r.values['state'] == 'succeeded' 
      && r.values['nominated'] == true) {
    print('RTT: ${r.values['currentRoundTripTime']}');
  }
  if (r.type == 'local-candidate') print(r.values['candidateType']); // host/srflx/relay
}
```

5. **`chrome://webrtc-internals`** khi debug với web client — xem `ICE connection state` chuyển `checking → connected → completed`.

## Một điểm liên quan trực tiếp tới stream media

Với kiến trúc **SFU** (LiveKit, mediasoup, Janus) — tức phần lớn hệ thống livestream nhiều người — server có public IP nên nó thường chạy **ICE-lite**: chỉ trả `host` candidate, không gom srflx/relay, không chủ động check. Client chạy full ICE và chịu trách nhiệm tìm đường. Hệ quả thực tế:

- **Không cần TURN cho phía server**, chỉ cần cho client bị chặn UDP.
- Nếu SFU chạy trong Docker/K8s, phải khai báo đúng announced IP (`rtcAnnouncedIp` trong mediasoup, `node_ip` trong LiveKit) — không thì candidate sẽ là IP container và ICE fail 100%.

Còn nếu bạn làm **HLS/DASH streaming** thuần thì cả ba khái niệm này không liên quan: đó là HTTP over TCP, không có NAT traversal. ICE/STUN/TURN chỉ xuất hiện khi có WebRTC hoặc SIP/RTP peer-to-peer.
