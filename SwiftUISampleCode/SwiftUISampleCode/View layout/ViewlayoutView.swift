
import SwiftUI

struct ViewlayoutView: View {
    var body: some View {
        NavigationLink(destination: LayoutFundamentalView()) {
            MenuRow(detailViewName: "Layout fundamentals")
        }
        
        NavigationLink(destination: LayoutAdjustmentsView()) {
            MenuRow(detailViewName: "Layout Adjustments")
        }
        
        NavigationLink(destination: ListView()) {
            MenuRow(detailViewName: "Lists")
        }
        
        NavigationLink(destination: CustomLayoutView()) {
            MenuRow(detailViewName: "Custom layout")
        }
        
        NavigationLink(destination: ViewGroupingView()) {
            MenuRow(detailViewName: "View groupings")
        }
        
        NavigationLink(destination: ScrollViews()) {
            MenuRow(detailViewName: "Scroll views")
        }
    }
}

#Preview {
    ViewlayoutView()
}
