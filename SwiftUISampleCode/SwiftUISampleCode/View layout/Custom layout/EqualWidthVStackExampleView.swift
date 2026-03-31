import SwiftUI

// MARK: - Màn hình hiển thị ví dụ
struct EqualWidthVStackExampleView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 30) {
            
            // 1. So sánh với VStack thông thường
            VStack(spacing: 20) {
                Text("VStack\nMặc định")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                // Các nút có chiều rộng lộn xộn, bám theo độ dài của chữ
                VStack(spacing: 15) {
                    ActionMenuButton(title: "Ngắn", color: .blue)
                    ActionMenuButton(title: "Trung bình", color: .green)
                    ActionMenuButton(title: "Một dòng chữ rất rất dài", color: .orange)
                }
            }
            
            Divider()
            
            // 2. Sử dụng MyEqualWidthVStack
            VStack(spacing: 20) {
                Text("MyEqualWidth\nVStack")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.blue)
                
                // Tất cả các nút sẽ tự động giãn rộng bằng nút lớn nhất
                MyEqualWidthVStack {
                    ActionMenuButton(title: "Ngắn", color: .blue)
                    ActionMenuButton(title: "Trung bình", color: .green)
                    ActionMenuButton(title: "Một dòng chữ rất rất dài", color: .orange)
                }
            }
        }
        .padding()
    }
}

// MARK: - Component Nút bấm dùng chung
struct ActionMenuButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            print("Đã bấm: \(title)")
        }) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                // LƯU Ý QUAN TRỌNG: Phải có .frame(maxWidth: .infinity)
                // Để View con chịu "phình to" ra lấp đầy kích thước mà Custom Layout cung cấp
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(10)
        }
    }
}

// MARK: - Mã nguồn MyEqualWidthVStack
struct MyEqualWidthVStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let maxSize = cache.maxSize
        let totalSpacing = cache.totalSpacing
        return CGSize(
            width: maxSize.width,
            height: maxSize.height * CGFloat(subviews.count) + totalSpacing)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CacheData) {
        guard !subviews.isEmpty else { return }
        let maxSize = cache.maxSize
        let spacing = cache.spacing
        let placementProposal = ProposedViewSize(width: maxSize.width, height: bounds.height)
        var nextY = bounds.minY + maxSize.height / 2

        for index in subviews.indices {
            subviews[index].place(
                at: CGPoint(x: bounds.midX, y: nextY),
                anchor: .center,
                proposal: placementProposal)
            nextY += maxSize.height + spacing[index]
        }
    }

    struct CacheData {
        let maxSize: CGSize
        let spacing: [CGFloat]
        let totalSpacing: CGFloat
    }

    func makeCache(subviews: Subviews) -> CacheData {
        let maxSize = maxSize(subviews: subviews)
        let spacing = spacing(subviews: subviews)
        let totalSpacing = spacing.reduce(0) { $0 + $1 }
        return CacheData(maxSize: maxSize, spacing: spacing, totalSpacing: totalSpacing)
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
            return subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .vertical)
        }
    }
}

// MARK: - Preview
#Preview {
    EqualWidthVStackExampleView()
}
