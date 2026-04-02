import SwiftUI
import Combine

struct CombineOperatorsView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: MappingElementsView()) {
                    MenuRow(detailViewName: "Mapping elements")
                }
                
                NavigationLink(destination: FilteringElementsView()) {
                    MenuRow(detailViewName: "Filtering elements")
                }
            }
        }
        .navigationBarTitle("Operators")
    }
}

#Preview {
    CombineOperatorsView()
}
