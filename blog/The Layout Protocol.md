Chào bạn, bài viết **"The Layout Protocol (Part 1)"** của objc.io hướng dẫn cách giải quyết một thử thách thiết kế giao diện (layout) phức tạp bằng cách sử dụng `Layout` protocol mới của SwiftUI (có từ iOS 16). 

Dưới đây là phần tổng hợp các ý chính và đoạn code hoàn chỉnh để bạn có thể chạy thử trực tiếp trên Xcode.

### 📝 Tổng hợp các ý chính của bài viết

1. **Vấn đề đặt ra (Thử thách Layout 5 năm tuổi):** Tác giả muốn tạo ra một nhóm gồm 3 View: 2 nhãn văn bản (Leading Label & Trailing Label) và một thanh ngang (Bar). 
   * Nếu thanh Bar đủ dài, 2 nhãn văn bản phải nằm ở 2 đầu (Leading căn theo mép trái thanh Bar, Trailing căn theo mép phải).
   * Nếu thanh Bar quá ngắn (không đủ chỗ cho cả 2 đoạn text), 2 nhãn văn bản phải tự động xếp sát cạnh nhau để không bị đè lên nhau.

2. **Cách tiếp cận cũ vs. mới:**
   * **Cũ:** Trước khi có SwiftUI `Layout` protocol, bạn phải dùng các kỹ thuật phức tạp như `GeometryReader` hoặc `Preferences`, khiến code khó bảo trì.
   * **Mới:** Sử dụng `Layout` protocol giúp chúng ta hoàn toàn làm chủ hệ thống tính toán (độ ưu tiên, kích thước, căn lề) một cách minh bạch, tự nhiên.

3. **Cơ chế hoạt động của Custom Layout:**
   Để tạo Custom Layout, bạn cần tuân thủ 2 phương thức bắt buộc:
   * `sizeThatFits`: Khai báo với View cha xem tổng kích thước của Layout này là bao nhiêu.
   * `placeSubviews`: Xác định tọa độ (X, Y) để đặt từng Subview vào đúng chỗ.

4. **Kỹ thuật xử lý logic (Gom chung tính toán):**
   Thay vì viết lại code tính toán tọa độ ở cả 2 hàm trên, tác giả tạo ra một hàm phụ trợ là `computeFrames`. 
   * **Mẹo cốt lõi:** Đầu tiên, nó xếp Text 2 nằm sát ngay sau Text 1. Sau đó nó so sánh điểm xa nhất (`maxX`) của thanh Bar. Nếu thanh Bar dài hơn, nó sẽ "đẩy" `maxX` của Text 2 ra bằng mép của thanh Bar, từ đó tạo ra khoảng trống ở giữa 2 đoạn Text.

---

### 💻 Code hoàn chỉnh (Có thể chạy ngay)

Bạn có thể copy toàn bộ đoạn code dưới đây, dán vào một file SwiftUI (ví dụ: `ContentView.swift`) để chạy thử. Mình đã thêm màu nền cho Text để bạn dễ hình dung cách chúng hoạt động.

```swift
import SwiftUI

// 1. Mở rộng CGRect để dễ dàng tinh chỉnh cạnh bên phải (maxX)
extension CGRect {
    var maxX: CGFloat {
        get { minX + width }
        set { origin.x = newValue - width }
    }
}

// 2. Định nghĩa Custom Layout theo chuẩn Layout Protocol
struct BarLayout: Layout {
    
    // Hàm phụ trợ tính toán khung hình (Frames) cho cả 3 thành phần
    func computeFrames(at startingPoint: CGPoint, proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
        // Layout này bắt buộc phải có đúng 3 thành phần truyền vào
        assert(subviews.count == 3, "BarLayout yêu cầu phải có đúng 3 subviews")
        
        // Xin kích thước của 3 thành phần
        let label1Size = subviews[0].sizeThatFits(proposal)
        let label2Size = subviews[1].sizeThatFits(proposal)
        let barSize = subviews[2].sizeThatFits(proposal)
        
        var currentPoint = startingPoint
        
        // Tính Frame cho Label 1
        let label1Frame = CGRect(origin: currentPoint, size: label1Size)
        
        // Tính Frame cho Label 2 (Xếp ngay sát Label 1)
        currentPoint.x += label1Size.width
        var label2Frame = CGRect(origin: currentPoint, size: label2Size)
        
        // Tính Frame cho Thanh Bar (Nằm bên dưới 2 text)
        currentPoint.x = startingPoint.x
        currentPoint.y = max(label1Frame.maxY, label2Frame.maxY)
        let barFrame = CGRect(origin: currentPoint, size: barSize)
        
        // LOGIC CHÍNH: 
        // Nếu thanh Bar đủ dài, kéo Label 2 sang bên phải cho bằng mép Bar.
        // Nếu thanh Bar ngắn hơn, giữ nguyên để Label 1 và Label 2 không bị đè lên nhau.
        label2Frame.maxX = max(barFrame.maxX, label2Frame.maxX)
        
        return [label1Frame, label2Frame, barFrame]
    }

    // Khai báo kích thước tổng của toàn bộ Layout
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let frames = computeFrames(at: .zero, proposal: proposal, subviews: subviews)
        // Gộp tất cả các frame lại để lấy ra kích thước bao trùm (bounding box)
        return frames.reduce(CGRect.null) { $0.union($1) }.size
    }

    // Đặt các Subview vào đúng vị trí
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = computeFrames(at: bounds.origin, proposal: proposal, subviews: subviews)
        for (view, frame) in zip(subviews, frames) {
            view.place(at: frame.origin, proposal: proposal)
        }
    }
}

// 3. Giao diện Demo
struct ContentView: View {
    @State private var containerWidth: CGFloat = 250
    @State private var barWidth: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Thử thách Layout 5 năm tuổi")
                .font(.title2).bold()
            
            // Layout được áp dụng
            BarLayout {
                Text("Leading Label")
                    .background(Color.green.opacity(0.3))
                
                Text("Trailing Label")
                    .background(Color.yellow.opacity(0.3))
                
                Color.red
                    .frame(height: 8)
                    .frame(width: barWidth)
            }
            .border(Color.blue, width: 2) // Khung viền để thấy rõ kích thước tổng
            .frame(width: containerWidth)
            
            // Khu vực điều khiển để test
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Độ rộng thanh Bar: \(Int(barWidth))")
                    Slider(value: $barWidth, in: 0...350)
                }
                
                VStack(alignment: .leading) {
                    Text("Độ rộng Container tổng: \(Int(containerWidth))")
                    Slider(value: $containerWidth, in: 0...350)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    ContentView()
}
```

*Ghi chú thêm: Trong bài viết, tác giả cũng úp mở rằng phần này mới chỉ hoàn thiện về mặt "sắp xếp vị trí". Ở "Part 2", tác giả sẽ xử lý bài toán "đề xuất kích thước" (proposal) để các dòng Text có thể bị cắt ngắn (truncate - thêm dấu ba chấm `...`) trong trường hợp tổng chiều rộng của màn hình bị thu hẹp lại.*

----

Hoàn toàn được! Đây chính là vẻ đẹp của việc hiểu bản chất vấn đề. 

Ở Part 1, lỗi tràn viền (overflow) xảy ra là do Layout của chúng ta đang hoạt động theo kiểu "đem con bỏ chợ". Nó nhận một **kích thước đề xuất (proposal)** từ View cha (ví dụ: 200px), và nó truyền y nguyên 200px đó cho Label 1, rồi lại truyền y nguyên 200px đó cho Label 2. Kết quả là mỗi Label tự tin chiếm không gian, cộng lại thành 300px -> Tràn viền!

### 💡 Thuật toán giải quyết (Bản chất của Part 2)

Để bắt các Text bị cắt ngắn (`...`), Custom Layout của chúng ta phải đóng vai trò là "người chia lô đất":
1. **Hỏi nhu cầu thực tế:** Xin kích thước lý tưởng (ideal size) của 2 Label bằng cách truyền `.unspecified` (không giới hạn).
2. **Kiểm tra quỹ đất:** So sánh tổng nhu cầu với độ rộng thực tế (`proposal.width`).
3. **Phân lô ép buộc:** Nếu tổng nhu cầu lớn hơn quỹ đất, Layout phải chủ động cắt giảm. Chẳng hạn, chia đôi quỹ đất cho mỗi Label, hoặc Label nào ngắn thì giữ nguyên, Label dài phải chịu thiệt.
4. **Bắt buộc trên UI:** Các `Text` phải được gắn modifier `.lineLimit(1)` để SwiftUI biết rằng khi bị ép `width`, nó phải hiện dấu `...` thay vì rớt xuống dòng.

---

### 💻 Đoạn code hoàn chỉnh xử lý Truncate

Dưới đây là đoạn code đã được mình nâng cấp thuật toán chia `width` bên trong `computeFrames`. Bạn copy và chạy thử sẽ thấy phép màu xảy ra khi kéo Slider:

```swift
import SwiftUI

// Mở rộng CGRect (Giữ nguyên từ Part 1)
extension CGRect {
    var maxX: CGFloat {
        get { minX + width }
        set { origin.x = newValue - width }
    }
}

// Custom Layout đã được nâng cấp xử lý Truncate
struct BarLayout: Layout {
    
    func computeFrames(at startingPoint: CGPoint, proposal: ProposedViewSize, subviews: Subviews) -> [CGRect] {
        assert(subviews.count == 3, "BarLayout yêu cầu phải có đúng 3 subviews")
        
        // 1. Lấy "quỹ đất" thực tế từ View cha
        // Nếu không có, mặc định cho một số rất lớn
        let availableWidth = proposal.width ?? 10000 
        
        // 2. Hỏi "nhu cầu thực tế" (Ideal Size) của 2 Label bằng .unspecified
        let idealSize1 = subviews[0].sizeThatFits(.unspecified)
        let idealSize2 = subviews[1].sizeThatFits(.unspecified)
        
        var allocatedWidth1 = idealSize1.width
        var allocatedWidth2 = idealSize2.width
        
        // 3. LOGIC XỬ LÝ TRUNCATE (PHÂN LÔ ĐẤT)
        // Nếu nhu cầu vượt quá quỹ đất, ta phải ép kích thước lại
        if allocatedWidth1 + allocatedWidth2 > availableWidth {
            let halfWidth = availableWidth / 2
            
            // Nếu Label 1 rất ngắn, cho nó giữ nguyên, Label 2 chịu phần còn lại
            if allocatedWidth1 < halfWidth {
                allocatedWidth2 = availableWidth - allocatedWidth1
            } 
            // Nếu Label 2 rất ngắn, cho nó giữ nguyên, Label 1 chịu phần còn lại
            else if allocatedWidth2 < halfWidth {
                allocatedWidth1 = availableWidth - allocatedWidth2
            } 
            // Cả 2 đều dài -> Chia đôi quỹ đất
            else {
                allocatedWidth1 = halfWidth
                allocatedWidth2 = halfWidth
            }
        }
        
        // 4. Bắt các subviews phải tính toán lại kích thước dựa trên "đất đã chia"
        let proposal1 = ProposedViewSize(width: allocatedWidth1, height: proposal.height)
        let proposal2 = ProposedViewSize(width: allocatedWidth2, height: proposal.height)
        
        let finalSize1 = subviews[0].sizeThatFits(proposal1)
        let finalSize2 = subviews[1].sizeThatFits(proposal2)
        let barSize = subviews[2].sizeThatFits(proposal) // Thanh bar tự lo liệu theo width của nó
        
        // 5. Tính toán tọa độ (Giữ nguyên logic Part 1)
        var currentPoint = startingPoint
        let label1Frame = CGRect(origin: currentPoint, size: finalSize1)
        
        currentPoint.x += finalSize1.width
        var label2Frame = CGRect(origin: currentPoint, size: finalSize2)
        
        currentPoint.x = startingPoint.x
        currentPoint.y = max(label1Frame.maxY, label2Frame.maxY)
        let barFrame = CGRect(origin: currentPoint, size: barSize)
        
        // Căn lề phải cho Label 2 theo thanh Bar (nếu thanh Bar dài hơn)
        label2Frame.maxX = max(barFrame.maxX, label2Frame.maxX)
        
        return [label1Frame, label2Frame, barFrame]
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let frames = computeFrames(at: .zero, proposal: proposal, subviews: subviews)
        return frames.reduce(CGRect.null) { $0.union($1) }.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = computeFrames(at: bounds.origin, proposal: proposal, subviews: subviews)
        for (view, frame) in zip(subviews, frames) {
            // 👉 ĐÃ SỬA TẠI ĐÂY: Truyền đúng kích thước frame vào proposal 
            // để bắt buộc Text phải cắt chữ (...) thay vì vẽ tràn ra ngoài
            view.place(at: frame.origin, proposal: ProposedViewSize(frame.size))
        }
    }
}

// Giao diện Demo
struct ContentView: View {
    @State private var containerWidth: CGFloat = 300
    @State private var barWidth: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Thử thách Layout - Part 2")
                .font(.title2).bold()
            
            BarLayout {
                // ĐIỀU KIỆN BẮT BUỘC ĐỂ CÓ DẤU "...": Phải dùng .lineLimit(1)
                Text("Đoạn Text Bên Trái Rất Dài")
                    .lineLimit(1)
                    .background(Color.green.opacity(0.3))
                
                Text("Đoạn Text Bên Phải Cũng Dài")
                    .lineLimit(1)
                    .background(Color.yellow.opacity(0.3))
                
                Color.red
                    .frame(height: 8)
                    .frame(width: barWidth)
            }
            .border(Color.blue, width: 2)
            .frame(width: containerWidth)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Độ rộng thanh Bar: \(Int(barWidth))")
                    Slider(value: $barWidth, in: 0...350)
                }
                
                VStack(alignment: .leading) {
                    Text("Độ rộng Container tổng: \(Int(containerWidth))")
                    Slider(value: $containerWidth, in: 50...350) // Kéo cái này xuống để test Truncate!
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
}

#Preview {
    ContentView()
}
```

### 🧠 Tóm tắt những thay đổi mấu chốt so với Part 1:
1. **Dùng `.unspecified`**: Bằng cách gọi `sizeThatFits(.unspecified)`, Layout "lén lút" hỏi xem nếu không bị ép buộc, 2 text kia sẽ tốn bao nhiêu diện tích.
2. **Logic Phân chia (Chia đất)**: Ở Bước 3 trong `computeFrames`, nếu tổng 2 text lớn hơn container, mình dùng hàm `if-else` để linh hoạt cắt xén. Đứa nào ngắn thì tha cho nó, đứa nào dài quá thì bị cắt, nếu cả 2 đều dài thì chia đôi màn hình mỗi đứa 50%.
3. **Cập nhật lại `ProposedViewSize`**: Sau khi đã tính xong `allocatedWidth`, ta bắt buộc phải gọi lại `sizeThatFits` một lần nữa, nhưng lần này truyền vào cục `ProposedViewSize` mới (bị giới hạn width). Lúc này SwiftUI mới kích hoạt cơ chế thêm dấu `...`.
4. Bắt buộc có `.lineLimit(1)` ngoài giao diện đối với các `Text`.
