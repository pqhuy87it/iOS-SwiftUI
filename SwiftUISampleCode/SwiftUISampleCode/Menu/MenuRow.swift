
import SwiftUI

struct MenuRow: View {
    let detailViewName: String
    
    var body: some View {
        Text(detailViewName)
    }
}

#Preview {
    MenuRow(detailViewName: "Single Stream")
}
