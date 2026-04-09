import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = calculateLayout(in: proposal.width ?? .infinity, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = calculateLayout(in: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.frames[index].minX,
                                y: bounds.minY + result.frames[index].minY)
            subview.place(at: point, proposal: .unspecified)
        }
    }

    // Thuật toán tính toán vị trí để tự động rớt dòng
    private func calculateLayout(in maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            // Nếu phần tử tiếp theo vượt quá chiều rộng màn hình -> Xuống dòng
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxX = max(maxX, currentX)
        }
        
        let totalSize = CGSize(width: maxWidth == .infinity ? maxX : maxWidth,
                               height: currentY + lineHeight)
        return (totalSize, frames)
    }
}

struct FlowLayoutView: View {
    let tags = [
        "Programming", "Swift", "WWDC", "Developer",
        "Code", "Mobile App Development", "UI/UX", "Xcode"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Native Flow Layout Example")
                    .font(.headline)
                
                // FlowLayout
                FlowLayout(spacing: 10) {
                    ForEach(tags, id: \.self) { tag in
                        TagView(text: tag, color: .blue)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// Giữ nguyên View hỗ trợ
struct TagView: View {
    var text: String
    var color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
