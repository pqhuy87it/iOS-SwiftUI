import SwiftUI

// MARK: - 1. Dữ liệu giả lập (Mock Data)
struct Song: Identifiable {
    let id = UUID()
    let title: String
    let person2CalledDibs: Bool
}

struct Songs {
    static let fromPerson2 = [
        Song(title: "Shape of You", person2CalledDibs: false),
        Song(title: "Blinding Lights", person2CalledDibs: true) // Bị đánh dấu Rejected
    ]
    static let fromPerson3 = [
        Song(title: "Bohemian Rhapsody", person2CalledDibs: false),
        Song(title: "Hotel California", person2CalledDibs: false)
    ]
}

// MARK: - 2. Màn hình chính (Chạy Preview ở đây)
struct DisplayBoardContainerView: View {
    var body: some View {
        VStack {
            DisplayBoardV5 {
                Section("Person 1’s\nFavorites") {
                    Text("Song 1")
                        .displayBoardCardRejected(true)
                        .displayBoardCardRotation(.degrees(-5))
                    Text("Song 2")
                        .displayBoardCardPinColor(.blue)
                    Text("Song 3")
                        .displayBoardCardRotation(.degrees(3))
                }
                
                Section("Person 2’s\nFavorites") {
                    ForEach(Songs.fromPerson2) { song in
                        Text(song.title)
                            .displayBoardCardRejected(song.person2CalledDibs)
                            .displayBoardCardPinColor(.green)
                    }
                }
            }
            
            DisplayBoardV5 {
                Section("Person 3’s\nFavorites") {
                    ForEach(Songs.fromPerson3) { song in
                        Text(song.title)
                    }
                }
                // Đánh dấu Rejected toàn bộ Section 3
                .displayBoardCardRejected(true)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - 3. Mã nguồn DisplayBoardV5 (Giữ nguyên logic của bạn)
struct DisplayBoardV5<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 22) {
            Group(sections: content) { sections in
                ForEach(sections) { section in
                    VStack(spacing: 20) {
                        if !section.header.isEmpty {
                            HeaderCardView { section.header }
                        }

                        DisplayBoardSectionCardLayout {
                            ForEach(section.content) { subview in
                                let values = subview.containerValues
                                CardView(
                                    scale: cardScale(forSections: sections),
                                    isRejected: values.isDisplayBoardCardRejected,
                                    rotation: values.displayBoardCardRotation,
                                    pinColor: values.displayBoardCardPinColor
                                ) {
                                    subview
                                }
                            }
                        }
                        .padding()
                        .background {
                            if sections.count > 1 {
                                DisplayBoardSectionBackgroundView()
                            }
                        }

                        if !section.footer.isEmpty {
                            FooterCardView { section.footer }
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .padding(66)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { DisplayBoardBackgroundView() }
    }

    private func cardScale(forSections sections: SectionCollection) -> DisplayBoardCardScale {
        if sections.count > 1 {
            return .small
        } else {
            if let section = sections.first, section.content.count > 15 {
                return .small
            } else {
                return .normal
            }
        }
    }
}

// MARK: - 4. Các Component phụ trợ (Mình viết thêm để code chạy được)

enum DisplayBoardCardScale {
    case normal
    case small
}

struct HeaderCardView<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .font(.headline)
            .multilineTextAlignment(.center)
            .padding(12)
            .background(Color.yellow.opacity(0.8))
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}

struct FooterCardView<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .font(.footnote)
            .padding(8)
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
    }
}

// Layout xếp các Card từ trên xuống dưới
struct DisplayBoardSectionCardLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(proposal) }
        let height = sizes.reduce(0) { $0 + $1.height + 15 }
        let width = sizes.map { $0.width }.max() ?? 100
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var y = bounds.minY
        for subview in subviews {
            let size = subview.sizeThatFits(proposal)
            subview.place(at: CGPoint(x: bounds.midX, y: y + size.height / 2), anchor: .center, proposal: proposal)
            y += size.height + 15
        }
    }
}

// Giao diện của 1 tấm thẻ (Card)
struct CardView<Content: View>: View {
    var scale: DisplayBoardCardScale
    var isRejected: Bool
    var rotation: Angle?
    var pinColor: Color?
    @ViewBuilder var content: Content

    var body: some View {
        content
            .font(scale == .small ? .subheadline : .body)
            .padding(scale == .small ? 12 : 20)
            .frame(minWidth: 120)
            .background(Color.white)
            .overlay(
                // Vẽ đường gạch chéo đỏ nếu bị Rejected
                Group {
                    if isRejected {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 1000, y: 1000))
                        }
                        .stroke(Color.red, lineWidth: 3)
                        .clipped()
                    }
                }
            )
            .border(Color.gray.opacity(0.2), width: 1)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 2, y: 2)
            // Vẽ cái đinh ghim (Pin) ở trên cùng
            .overlay(
                Circle()
                    .fill(pinColor ?? .red)
                    .frame(width: 12, height: 12)
                    .shadow(radius: 1)
                    .offset(y: -6)
                , alignment: .top
            )
            .rotationEffect(rotation ?? .degrees(Double.random(in: -2...2))) // Xoay nhẹ ngẫu nhiên nếu không truyền góc
    }
}

struct DisplayBoardSectionBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.orange.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
    }
}

struct DisplayBoardBackgroundView: View {
    var body: some View {
        // Nền giả lập bảng gỗ (hoặc bảng bần)
        Color.brown.opacity(0.3)
    }
}

// MARK: - 5. Container Values (Giữ nguyên của bạn)

extension ContainerValues {
    @Entry var isDisplayBoardCardRejected: Bool = false
    @Entry var displayBoardCardPinColor: Color?
    @Entry var displayBoardCardPosition: UnitPoint?
    @Entry var displayBoardCardRotation: Angle?
}

extension View {
    func displayBoardCardRejected(_ isRejected: Bool) -> some View {
        containerValue(\.isDisplayBoardCardRejected, isRejected)
    }
    func displayBoardCardPinColor(_ pinColor: Color?) -> some View {
        containerValue(\.displayBoardCardPinColor, pinColor)
    }
    func displayBoardCardPosition(_ position: UnitPoint?) -> some View {
        containerValue(\.displayBoardCardPosition, position)
    }
    func displayBoardCardRotation(_ rotation: Angle?) -> some View {
        containerValue(\.displayBoardCardRotation, rotation)
    }
}

#Preview {
    DisplayBoardContainerView()
}
