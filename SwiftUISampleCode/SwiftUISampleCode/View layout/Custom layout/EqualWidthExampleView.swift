import SwiftUI

// MARK: - Màn hình hiển thị ví dụ
struct EqualWidthExampleView: View {
    var body: some View {
        VStack(spacing: 50) {
            
            // 1. So sánh với HStack thông thường
            VStack {
                Text("HStack Mặc định")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Các nút sẽ có kích thước lộn xộn, phụ thuộc vào độ dài của chữ
                HStack(spacing: 15) {
                    ActionLayoutButton(title: "OK", color: .blue)
                    ActionLayoutButton(title: "Hủy", color: .red)
                    ActionLayoutButton(title: "Đồng ý điều khoản", color: .green)
                }
            }
            
            // 2. Sử dụng MyEqualWidthHStack
            VStack {
                Text("MyEqualWidthHStack")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Tất cả các nút sẽ tự động rộng bằng nút lớn nhất ("Đồng ý điều khoản")
                MyEqualWidthHStack {
                    ActionLayoutButton(title: "OK", color: .blue)
                    ActionLayoutButton(title: "Hủy", color: .red)
                    ActionLayoutButton(title: "Đồng ý điều khoản", color: .green)
                }
            }
        }
        .padding()
    }
}

// MARK: - Component Nút bấm dùng chung
struct ActionLayoutButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            print("Đã bấm: \(title)")
        }) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                // LƯU Ý QUAN TRỌNG: Phải có .frame(maxWidth: .infinity)
                // Để View con chịu "phình to" ra lấp đầy kích thước mà Custom Layout đề xuất
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(10)
        }
    }
}

// MARK: - Kéo class MyEqualWidthHStack của bạn vào đây (để chạy được trên 1 file)
struct MyEqualWidthHStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }
        return CGSize(
            width: maxSize.width * CGFloat(subviews.count) + totalSpacing,
            height: maxSize.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let placementProposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
        var nextX = bounds.minX + maxSize.width / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: nextX, y: bounds.midY),
                anchor: .center,
                proposal: placementProposal)
            nextX += maxSize.width + spacing[index]
        }
    }

    private func maxSize(subviews: Subviews) -> CGSize {
        let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return subviewSizes.reduce(.zero) { currentMax, subviewSize in
            CGSize(width: max(currentMax.width, subviewSize.width), height: max(currentMax.height, subviewSize.height))
        }
    }

    private func spacing(subviews: Subviews) -> [CGFloat] {
        subviews.indices.map { index in
            guard index < subviews.count - 1 else { return 0 }
            return subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
        }
    }
}

// MARK: - Preview
#Preview {
    EqualWidthExampleView()
}
