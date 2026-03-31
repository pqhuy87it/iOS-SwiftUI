import SwiftUI

// MARK: - Màn hình hiển thị ví dụ
struct RadialLayoutExampleView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 60) {
                
                // --- VÍ DỤ 1: Sắp xếp toả tròn cơ bản ---
                VStack(spacing: 15) {
                    Text("1. Toả tròn cơ bản (6 phần tử)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    MyRadialLayout {
                        ForEach(1...6, id: \.self) { index in
                            Circle()
                                .fill(Color.blue.opacity(0.8))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("\(index)")
                                        .foregroundColor(.white)
                                        .bold()
                                )
                        }
                    }
                    .frame(width: 250, height: 250)
                    // Vẽ thêm một vòng tròn mờ phía sau để dễ hình dung khung layout
                    .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                }
                
                // --- VÍ DỤ 2: Sắp xếp 3 phần tử có Phân Hạng (Rank) ---
                VStack(spacing: 15) {
                    Text("2. Phân hạng (Đúng 3 phần tử)")
                        .font(.headline)
                        .foregroundColor(.orange)
                    Text("Top 1 sẽ tự động được đẩy lên đỉnh")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    MyRadialLayout {
                        // Khai báo Top 2 trước
                        RankAvatar(name: "Bảo", rank: 2, color: .orange)
                            .rank(2) // Sử dụng modifier .rank() của Custom Layout
                        
                        // Khai báo Top 1 sau (Nhưng sẽ được layout đẩy lên Top)
                        RankAvatar(name: "Anh", rank: 1, color: .red)
                            .rank(1)
                        
                        // Khai báo Top 3
                        RankAvatar(name: "Cường", rank: 3, color: .green)
                            .rank(3)
                    }
                    .frame(width: 250, height: 250)
                    .background(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                }
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Component hiển thị Avatar người dùng
struct RankAvatar: View {
    let name: String
    let rank: Int
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 70, height: 70)
                .shadow(radius: 5)
            
            VStack(spacing: 2) {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Top \(rank)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }
}

// MARK: - Mã nguồn MyRadialLayout
struct MyRadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let radius = min(bounds.size.width, bounds.size.height) / 3.0
        let angle = Angle.degrees(360.0 / Double(subviews.count)).radians
        
        let ranks = subviews.map { subview in
            subview[Rank.self]
        }
        let offset = getOffset(ranks)

        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(rotationAngle: angle * Double(index) + offset))
            
            point.x += bounds.midX
            point.y += bounds.midY
            
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

extension MyRadialLayout {
    private func getOffset(_ ranks: [Int]) -> Double {
        guard ranks.count == 3,
              !ranks.allSatisfy({ $0 == ranks.first }) else { return 0.0 }

        var fraction: Double
        if ranks[0] == 1 {
            fraction = residual(rank1: ranks[1], rank2: ranks[2])
        } else if ranks[1] == 1 {
            fraction = -1 + residual(rank1: ranks[2], rank2: ranks[0])
        } else {
            fraction = 1 + residual(rank1: ranks[0], rank2: ranks[1])
        }
        return fraction * 2.0 * Double.pi / 3.0
    }

    private func residual(rank1: Int, rank2: Int) -> Double {
        if rank1 == 1 { return -0.5 }
        else if rank2 == 1 { return 0.5 }
        else if rank1 < rank2 { return -0.25 }
        else if rank1 > rank2 { return 0.25 }
        else { return 0 }
    }
}

private struct Rank: LayoutValueKey {
    static let defaultValue: Int = 1
}

extension View {
    func rank(_ value: Int) -> some View {
        layoutValue(key: Rank.self, value: value)
    }
}

// MARK: - Preview
#Preview {
    RadialLayoutExampleView()
}
