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
                
                NavigationLink(destination: ReducingElementsView()) {
                    MenuRow(detailViewName: "Reducing elements")
                }
                
                NavigationLink(destination: MathematicElementsView()) {
                    MenuRow(detailViewName: "Mathematic operations on elements")
                }
            }
        }
        .navigationBarTitle("Operators")
    }
}

#Preview {
    CombineOperatorsView()
}
