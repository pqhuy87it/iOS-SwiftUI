import SwiftUI

// MARK: - 1. Định nghĩa Data Model
// Bắt buộc phải tuân thủ Identifiable để Table có thể phân biệt từng dòng
struct Employee: Identifiable {
    let id = UUID()
    var name: String
    var department: String
    var role: String
}

// MARK: - 2. Màn hình hiển thị Table
struct EmployeeTableView: View {
    // Biến môi trường để kiểm tra xem màn hình đang hẹp (iPhone) hay rộng (iPad)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Dữ liệu mẫu
    @State private var employees = [
        Employee(name: "Nguyễn Văn A", department: "Kỹ thuật", role: "iOS Developer"),
        Employee(name: "Trần Thị B", department: "Thiết kế", role: "UI/UX Designer"),
        Employee(name: "Lê Văn C", department: "Nhân sự", role: "HR Manager"),
        Employee(name: "Phạm Thị D", department: "Kinh doanh", role: "Sales Lead")
    ]
    
    // Biến lưu trữ thứ tự sắp xếp (SortOrder) - Tính năng cực hay của Table
    @State private var sortOrder = [KeyPathComparator(\Employee.name)]
    
    var body: some View {
        // Khởi tạo Table với dữ liệu và hỗ trợ tính năng sắp xếp
        Table(employees, sortOrder: $sortOrder) {
            
            // CỘT 1: Cột quan trọng nhất (luôn hiển thị trên cả iPhone và iPad)
            TableColumn("Tên nhân viên", value: \.name) { employee in
                // Nếu là màn hình iPhone (compact)
                if horizontalSizeClass == .compact {
                    // Gộp tất cả thông tin vào cột đầu tiên để hiển thị dạng List
                    VStack(alignment: .leading, spacing: 4) {
                        Text(employee.name)
                            .font(.headline)
                        
                        HStack {
                            Text(employee.role)
                            Text("•")
                            Text(employee.department)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                // Nếu là màn hình iPad / Mac (regular)
                else {
                    // Chỉ hiển thị mỗi tên vì các thông tin kia đã có cột riêng
                    Text(employee.name)
                        .fontWeight(.medium)
                }
            }
            
            // CỘT 2: Sẽ tự động bị ẩn đi trên iPhone, chỉ hiện trên iPad
            TableColumn("Phòng ban", value: \.department)
            
            // CỘT 3: Sẽ tự động bị ẩn đi trên iPhone, chỉ hiện trên iPad
            TableColumn("Chức vụ", value: \.role)
            
        }
        // Logic xử lý khi người dùng bấm vào tiêu đề cột để sắp xếp
        .onChange(of: sortOrder) { _, newOrder in
            employees.sort(using: newOrder)
        }
        .navigationTitle("Danh sách nhân sự")
    }
}

#Preview {
    EmployeeTableView()
}
