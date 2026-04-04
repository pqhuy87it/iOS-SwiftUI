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
                    MenuRow(detailViewName: "Combining elements from multiple publishers").font(Font.system(size: 15))
                }
                
                NavigationLink(destination: CombiningElementsMultiplePublishersView()) {
                    MenuRow(detailViewName: "Handling errors")
                }
                
                NavigationLink(destination: AdaptingPublisherTypesView()) {
                    MenuRow(detailViewName: "Adapting publisher types")
                }
                
                NavigationLink(destination: EncodingAndDecodingView()) {
                    MenuRow(detailViewName: "Encoding and decoding")
                }
                
                NavigationLink(destination: EncodingAndDecodingView()) {
                    MenuRow(detailViewName: "Others")
                }
            }
        }
        .navigationBarTitle("Operators")
    }
}

#Preview {
    CombineOperatorsView()
}
