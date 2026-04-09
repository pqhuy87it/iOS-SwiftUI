import SwiftUI

struct TablesView: View {
    var body: some View {
        VStack {
            List {
                NavigationLink(destination: EmployeeTableView()) {
                    MenuRow(detailViewName: "Example 1")
                }
            }
        }
        .navigationBarTitle("Tables")
    }
}

#Preview {
    TablesView()
}
