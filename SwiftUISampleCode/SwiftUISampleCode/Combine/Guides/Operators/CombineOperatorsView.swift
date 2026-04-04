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
                
                NavigationLink(destination: MatchingCriteriaElementsView()) {
                    MenuRow(detailViewName: "Applying matching criteria to elements")
                }
                
                NavigationLink(destination: SequenceOperationsElementsView()) {
                    MenuRow(detailViewName: "Applying sequence operations to elements")
                }
                
                NavigationLink(destination: CombiningElementsMultiplePublishersView()) {
                    MenuRow(detailViewName: "Combining elements from multiple publishers")
                }
            }
        }
        .navigationBarTitle("Operators")
    }
}

#Preview {
    CombineOperatorsView()
}
