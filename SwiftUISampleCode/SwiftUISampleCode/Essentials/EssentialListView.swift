
import SwiftUI

struct EssentialListView: View {
    var body: some View {
        NavigationLink(destination: LiquidGlassView()) {
            MenuRow(detailViewName: "Liquid Glass View")
        }
    }
}

#Preview {
    EssentialListView()
}
