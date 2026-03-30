# SwiftUI: `Table` — Giải thích chi tiết

## 1. Bản chất — Multi-column data view

`Table` (iOS 16+ / macOS 12+) hiển thị dữ liệu dạng **nhiều cột** — giống spreadsheet/Excel. Mỗi hàng là một data item, mỗi cột hiển thị một property của item đó.

```
┌──────────────┬────────────┬──────────┬──────────┐
│ Name         │ Email      │ Role     │ Status   │  ← Column headers
├──────────────┼────────────┼──────────┼──────────┤
│ Huy Nguyen   │ huy@ex.com │ iOS Dev  │ Active   │  ← Row = 1 data item
│ Alice Smith  │ ali@ex.com │ Designer │ Active   │
│ Bob Johnson  │ bob@ex.com │ PM       │ Inactive │
└──────────────┴────────────┴──────────┴──────────┘
```

**Platform behavior:**

```
macOS / iPadOS:  Hiển thị đầy đủ multi-column với headers
                 Sortable, resizable columns, selection

iPhone:          Tự động collapse thành dạng LIST (1 cột)
                 Chỉ hiển thị cột ĐẦU TIÊN
```

---

## 2. Cú pháp cơ bản

### Table đơn giản nhất

```swift
struct Person: Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var role: String
}

struct PeopleTable: View {
    let people: [Person]
    
    var body: some View {
        Table(people) {
            TableColumn("Name", value: \.name)
            TableColumn("Email", value: \.email)
            TableColumn("Role", value: \.role)
        }
    }
}
```

`TableColumn` khai báo mỗi cột: **header text** + **keypath** đến property hiển thị.

### TableColumn — Hai cách khai báo

```swift
// Cách 1: KeyPath — chỉ hiển thị String
TableColumn("Name", value: \.name)
// ↑ value phải là KeyPath đến String
// Header = "Name", cell = person.name

// Cách 2: Custom content — hiển thị bất kỳ View nào
TableColumn("Status") { person in
    // ↑ Closure nhận data item → trả về View tuỳ ý
    HStack {
        Circle()
            .fill(person.isActive ? .green : .red)
            .frame(width: 8, height: 8)
        Text(person.isActive ? "Active" : "Inactive")
    }
}
```

### Ví dụ kết hợp cả hai cách

```swift
Table(people) {
    // KeyPath — gọn, chỉ String
    TableColumn("Name", value: \.name)
    TableColumn("Email", value: \.email)
    
    // Custom content — linh hoạt, bất kỳ View
    TableColumn("Role") { person in
        Label(person.role, systemImage: person.roleIcon)
    }
    
    TableColumn("Status") { person in
        Text(person.isActive ? "Active" : "Inactive")
            .foregroundStyle(person.isActive ? .green : .red)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(person.isActive ? .green.opacity(0.15) : .red.opacity(0.15))
            )
    }
}
```

---

## 3. Sorting — Sắp xếp theo cột

### Cơ bản — Comparable properties

```swift
struct Employee: Identifiable {
    let id = UUID()
    var name: String
    var department: String
    var salary: Int
    var joinDate: Date
}

struct EmployeeTable: View {
    @State private var employees: [Employee] = sampleData
    @State private var sortOrder = [KeyPathComparator(\Employee.name)]
    //                              ↑ Mảng sort descriptors
    //                                Mặc định: sort theo name
    
    var body: some View {
        Table(employees, sortOrder: $sortOrder) {
            //                       ↑ Binding — Table tự update khi user tap header
            
            TableColumn("Name", value: \.name)
            //                         ↑ value: KeyPath → CỘT NÀY SORTABLE
            //                           (property phải conform Comparable)
            
            TableColumn("Department", value: \.department)
            
            TableColumn("Salary", value: \.salary) { employee in
                Text(employee.salary, format: .currency(code: "USD"))
            }
            //  value: \.salary → sortable theo Int
            //  Closure → custom display format
            
            TableColumn("Joined", value: \.joinDate) { employee in
                Text(employee.joinDate, style: .date)
            }
        }
        .onChange(of: sortOrder) { _, newOrder in
            employees.sort(using: newOrder)
            //        ↑ Array.sort(using:) nhận [SortComparator]
        }
    }
}
```

### User interaction — Tap header để sort

```
Tap "Name":
┌──────────────▲┬────────────┬──────────┐
│ Name         ↑│ Department │ Salary   │  ← ▲ ascending
├───────────────┼────────────┼──────────┤
│ Alice Smith   │ Design     │ $85,000  │
│ Bob Johnson   │ Engineering│ $95,000  │
│ Huy Nguyen    │ Engineering│ $90,000  │
└───────────────┴────────────┴──────────┘

Tap "Name" lần nữa:
┌──────────────▼┬────────────┬──────────┐
│ Name         ↓│ Department │ Salary   │  ← ▼ descending
├───────────────┼────────────┼──────────┤
│ Huy Nguyen    │ Engineering│ $90,000  │
│ Bob Johnson   │ Engineering│ $95,000  │
│ Alice Smith   │ Design     │ $85,000  │
└───────────────┴────────────┴──────────┘

Tap "Salary":
┌──────────────┬────────────┬──────────▲┐
│ Name         │ Department │ Salary   ↑│  ← sort theo salary
├──────────────┼────────────┼──────────┤
│ Alice Smith   │ Design     │ $85,000  │
│ Huy Nguyen    │ Engineering│ $90,000  │
│ Bob Johnson   │ Engineering│ $95,000  │
└──────────────┴────────────┴──────────┘
```

### Custom SortComparator — Sort non-Comparable types

```swift
TableColumn("Priority") { task in
    Text(task.priority.label)
}
.customizationID("priority")    // iOS 17+: stable column identity
// ← Cột này KHÔNG sortable vì không có value: keypath
// Để sort: dùng custom comparator hoặc map priority → comparable value
```

---

## 4. Selection — Chọn hàng

### Single selection

```swift
struct PeopleTable: View {
    let people: [Person]
    @State private var selectedPerson: Person.ID?
    //                                 ↑ Optional — nil = không chọn gì
    
    var body: some View {
        Table(people, selection: $selectedPerson) {
            TableColumn("Name", value: \.name)
            TableColumn("Email", value: \.email)
        }
        
        // Hiển thị detail cho selection
        if let id = selectedPerson,
           let person = people.first(where: { $0.id == id }) {
            Text("Selected: \(person.name)")
        }
    }
}
```

### Multiple selection

```swift
struct PeopleTable: View {
    @State private var people: [Person] = sampleData
    @State private var selectedIDs: Set<Person.ID> = []
    //                              ↑ Set → multi-select
    
    var body: some View {
        Table(people, selection: $selectedIDs) {
            TableColumn("Name", value: \.name)
            TableColumn("Email", value: \.email)
            TableColumn("Role", value: \.role)
        }
        .toolbar {
            ToolbarItem {
                Text("\(selectedIDs.count) selected")
            }
            ToolbarItem {
                Button("Delete Selected") {
                    people.removeAll { selectedIDs.contains($0.id) }
                    selectedIDs.removeAll()
                }
                .disabled(selectedIDs.isEmpty)
            }
        }
    }
}
```

```
┌─────┬──────────────┬────────────┬──────────┐
│  ☑  │ Name         │ Email      │ Role     │
├─────┼──────────────┼────────────┼──────────┤
│ [✓] │ Huy Nguyen   │ huy@ex.com │ iOS Dev  │  ← selected
│ [ ] │ Alice Smith  │ ali@ex.com │ Designer │
│ [✓] │ Bob Johnson  │ bob@ex.com │ PM       │  ← selected
└─────┴──────────────┴────────────┴──────────┘
  2 selected                    [Delete Selected]
```

---

## 5. Column Width — Kiểm soát chiều rộng

```swift
Table(data) {
    // Chiều rộng cố định
    TableColumn("ID", value: \.id.uuidString)
        .width(80)
    
    // Chiều rộng linh hoạt với min/max
    TableColumn("Name", value: \.name)
        .width(min: 100, ideal: 200, max: 300)
    
    // Chiều rộng linh hoạt (mặc định)
    TableColumn("Description") { item in
        Text(item.description)
    }
    // ← Không set width → chia đều phần còn lại
    
    // Chiều rộng cố định nhỏ
    TableColumn("Status") { item in
        StatusBadge(status: item.status)
    }
    .width(100)
}
```

```
┌────────┬──────────────────────┬──────────────────────────────┬──────────┐
│ ID     │ Name                 │ Description                  │ Status   │
│ 80pt   │ 100-300pt (flexible) │ remaining (flexible)         │ 100pt    │
└────────┴──────────────────────┴──────────────────────────────┴──────────┘
```

---

## 6. Table Styles

```swift
Table(data) { ... }
    .tableStyle(.automatic)        // platform default
    .tableStyle(.inset)            // inset từ edges (macOS/iPadOS)
    .tableStyle(.inset(alternatesRowBackgrounds: true))
    //                              ↑ zebra stripes (macOS)
```

```
alternatesRowBackgrounds: true (macOS):
┌──────────────┬────────────┐
│ Row 1        │ Data       │  ← white
├──────────────┼────────────┤
│ Row 2        │ Data       │  ← gray (alternate)
├──────────────┼────────────┤
│ Row 3        │ Data       │  ← white
└──────────────┴────────────┘
```

---

## 7. Table trên iPhone — Hạn chế và giải pháp

### iPhone tự động collapse thành List

```swift
// Trên iPad/macOS: hiện đầy đủ 4 cột
// Trên iPhone: CHỈ hiện CỘT ĐẦU TIÊN
Table(people) {
    TableColumn("Name", value: \.name)        // ← CHỈ CỘT NÀY trên iPhone
    TableColumn("Email", value: \.email)      // ← ẩn
    TableColumn("Role", value: \.role)         // ← ẩn
    TableColumn("Status") { ... }              // ← ẩn
}
```

### Giải pháp: Custom first column cho iPhone

```swift
Table(people) {
    // Cột 1: rich content cho iPhone, label cho macOS
    TableColumn("Person") { person in
        VStack(alignment: .leading, spacing: 4) {
            Text(person.name)
                .font(.headline)
            Text(person.email)
                .font(.caption)
                .foregroundStyle(.secondary)
            #if os(iOS)
            // Hiện thêm info trên iPhone vì các cột khác bị ẩn
            HStack {
                Text(person.role)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                StatusBadge(isActive: person.isActive)
            }
            #endif
        }
    }
    
    // Các cột này chỉ hiện trên macOS/iPad
    TableColumn("Email", value: \.email)
    TableColumn("Role", value: \.role)
    TableColumn("Status") { person in
        StatusBadge(isActive: person.isActive)
    }
}
```

### Alternative: Dùng List trên iPhone, Table trên iPad

```swift
struct AdaptiveDataView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let people: [Person]
    
    var body: some View {
        if sizeClass == .regular {
            // iPad / macOS: Table đầy đủ
            Table(people) {
                TableColumn("Name", value: \.name)
                TableColumn("Email", value: \.email)
                TableColumn("Role", value: \.role)
            }
        } else {
            // iPhone: Custom List
            List(people) { person in
                PersonRow(person: person)
            }
        }
    }
}
```

---

## 8. iOS 17+ — Table Enhancements

### 8.1 Column customization

```swift
// iOS 17+: user có thể ẩn/hiện và sắp xếp lại cột
@State private var columnCustomization = TableColumnCustomization<Person>()

Table(people, columnCustomization: $columnCustomization) {
    TableColumn("Name", value: \.name)
        .customizationID("name")
        // ↑ Stable ID cho column — cần cho customization persistence
    
    TableColumn("Email", value: \.email)
        .customizationID("email")
    
    TableColumn("Role", value: \.role)
        .customizationID("role")
        .defaultVisibility(.hidden)
        // ↑ Mặc định ẩn — user có thể bật trong context menu
}
```

### 8.2 Row actions

```swift
Table(people) {
    TableColumn("Name", value: \.name)
    TableColumn("Email", value: \.email)
}
.contextMenu(forSelectionType: Person.ID.self) { selectedIDs in
    // Right-click / long-press context menu
    Button("Copy Email") { copyEmails(for: selectedIDs) }
    Button("Send Message") { sendMessage(to: selectedIDs) }
    Divider()
    Button("Delete", role: .destructive) { delete(selectedIDs) }
} primaryAction: { selectedIDs in
    // Double-click / tap action
    openDetail(for: selectedIDs)
}
```

---

## 9. Dynamic Data — Table với @Observable / ObservableObject

### Với @Observable (iOS 17+)

```swift
@Observable
class EmployeeStore {
    var employees: [Employee] = []
    var sortOrder = [KeyPathComparator(\Employee.name)]
    var selection: Set<Employee.ID> = []
    
    var sortedEmployees: [Employee] {
        employees.sorted(using: sortOrder)
    }
    
    func deleteSelected() {
        employees.removeAll { selection.contains($0.id) }
        selection.removeAll()
    }
    
    func addEmployee(_ employee: Employee) {
        employees.append(employee)
    }
}

struct EmployeeTableView: View {
    @State private var store = EmployeeStore()
    @State private var showAddSheet = false
    
    var body: some View {
        Table(store.sortedEmployees, selection: $store.selection, sortOrder: $store.sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Department", value: \.department)
            TableColumn("Salary", value: \.salary) { emp in
                Text(emp.salary, format: .currency(code: "USD"))
            }
            TableColumn("Joined", value: \.joinDate) { emp in
                Text(emp.joinDate, style: .date)
            }
        }
        .onChange(of: store.sortOrder) { _, newOrder in
            // Không cần sort thủ công — computed property sortedEmployees tự update
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Add") { showAddSheet = true }
                
                Button("Delete") { store.deleteSelected() }
                    .disabled(store.selection.isEmpty)
                
                Text("\(store.employees.count) employees")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddEmployeeView { employee in
                store.addEmployee(employee)
            }
        }
    }
}
```

---

## 10. Table với Section (macOS 13+ / iOS 17+)

```swift
Table(of: Employee.self) {
    TableColumn("Name", value: \.name)
    TableColumn("Role", value: \.role)
    TableColumn("Salary", value: \.salary) { emp in
        Text(emp.salary, format: .currency(code: "USD"))
    }
} rows: {
    Section("Engineering") {
        ForEach(engineers) { emp in
            TableRow(emp)
        }
    }
    
    Section("Design") {
        ForEach(designers) { emp in
            TableRow(emp)
        }
    }
    
    Section("Product") {
        ForEach(productManagers) { emp in
            TableRow(emp)
        }
    }
}
```

```
┌──────────────┬──────────┬──────────┐
│ Name         │ Role     │ Salary   │
├══════════════╪══════════╪══════════╡
│ ENGINEERING                        │
├──────────────┼──────────┼──────────┤
│ Huy Nguyen   │ iOS Dev  │ $90,000  │
│ Bob Johnson  │ Backend  │ $95,000  │
├══════════════╪══════════╪══════════╡
│ DESIGN                             │
├──────────────┼──────────┼──────────┤
│ Alice Smith  │ UI/UX    │ $85,000  │
└──────────────┴──────────┴──────────┘
```

---

## 11. Ví dụ thực tế hoàn chỉnh — Admin Dashboard

```swift
struct Transaction: Identifiable {
    let id = UUID()
    var date: Date
    var description: String
    var category: String
    var amount: Double
    var status: Status
    
    enum Status: String {
        case completed, pending, failed
        
        var color: Color {
            switch self {
            case .completed: .green
            case .pending: .orange
            case .failed: .red
            }
        }
    }
}

struct TransactionTable: View {
    @State private var transactions: [Transaction] = sampleTransactions
    @State private var sortOrder = [KeyPathComparator(\Transaction.date, order: .reverse)]
    @State private var selection = Set<Transaction.ID>()
    @State private var searchText = ""
    
    private var filteredTransactions: [Transaction] {
        let sorted = transactions.sorted(using: sortOrder)
        if searchText.isEmpty { return sorted }
        return sorted.filter {
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var totalSelected: Double {
        filteredTransactions
            .filter { selection.contains($0.id) }
            .reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            Table(filteredTransactions, selection: $selection, sortOrder: $sortOrder) {
                // Date column
                TableColumn("Date", value: \.date) { transaction in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.date, style: .date)
                            .font(.subheadline)
                        Text(transaction.date, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .width(min: 100, ideal: 130)
                
                // Description column
                TableColumn("Description", value: \.description)
                    .width(min: 150, ideal: 250)
                
                // Category column
                TableColumn("Category", value: \.category) { transaction in
                    Text(transaction.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
                .width(ideal: 120)
                
                // Amount column
                TableColumn("Amount", value: \.amount) { transaction in
                    Text(transaction.amount, format: .currency(code: "USD"))
                        .foregroundStyle(transaction.amount >= 0 ? .primary : .red)
                        .monospacedDigit()
                }
                .width(min: 80, ideal: 110)
                
                // Status column
                TableColumn("Status") { transaction in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(transaction.status.color)
                            .frame(width: 8, height: 8)
                        Text(transaction.status.rawValue.capitalized)
                            .font(.caption)
                    }
                }
                .width(ideal: 100)
            }
            .navigationTitle("Transactions")
            .searchable(text: $searchText, prompt: "Search transactions...")
            .toolbar {
                ToolbarItemGroup {
                    if !selection.isEmpty {
                        Text("\(selection.count) selected · \(totalSelected, format: .currency(code: "USD"))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    Menu {
                        Button("Export Selected") { exportCSV(selection) }
                        Button("Mark as Completed") { markCompleted(selection) }
                        Divider()
                        Button("Delete", role: .destructive) { delete(selection) }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(selection.isEmpty)
                }
            }
            .contextMenu(forSelectionType: Transaction.ID.self) { ids in
                Button("Copy Amount") { copyAmounts(ids) }
                Button("Duplicate") { duplicate(ids) }
                Divider()
                Button("Delete", role: .destructive) { delete(ids) }
            } primaryAction: { ids in
                // Double-click → open detail
                if let id = ids.first {
                    openDetail(id)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func delete(_ ids: Set<Transaction.ID>) {
        transactions.removeAll { ids.contains($0.id) }
        selection.subtract(ids)
    }
    
    private func markCompleted(_ ids: Set<Transaction.ID>) {
        for i in transactions.indices {
            if ids.contains(transactions[i].id) {
                transactions[i].status = .completed
            }
        }
    }
    
    private func exportCSV(_ ids: Set<Transaction.ID>) { /* ... */ }
    private func duplicate(_ ids: Set<Transaction.ID>) { /* ... */ }
    private func copyAmounts(_ ids: Set<Transaction.ID>) { /* ... */ }
    private func openDetail(_ id: Transaction.ID) { /* ... */ }
}
```

---

## 12. Table vs List vs LazyVGrid — Khi nào dùng Table?

```
Table:
  ✅ Data có NHIỀU PROPERTIES cần hiển thị song song (multi-column)
  ✅ Cần SORTABLE columns (tap header để sort)
  ✅ Cần row SELECTION (single / multi)
  ✅ macOS / iPadOS app — desktop-style data view
  ⚠️ iPhone: collapse thành 1 cột — hạn chế

List:
  ✅ Data hiển thị dạng HÀNG (1 column)
  ✅ Cần swipe actions, sections, platform-native styling
  ✅ Hoạt động tốt trên TẤT CẢ platforms
  ❌ Không có column headers, sorting built-in

LazyVGrid:
  ✅ Visual grid (photo gallery, product cards)
  ✅ Custom layout linh hoạt
  ❌ Không có sorting, selection, headers built-in
```

---

## 13. Sai lầm thường gặp

### ❌ Quên sort data khi sortOrder thay đổi

```swift
// ❌ Table hiện sortOrder indicator nhưng data KHÔNG thay đổi
Table(people, sortOrder: $sortOrder) { ... }
// User tap header → indicator thay đổi nhưng rows giữ nguyên!

// ✅ Sort data khi sortOrder thay đổi
.onChange(of: sortOrder) { _, newOrder in
    people.sort(using: newOrder)
}
// Hoặc dùng computed property:
var sortedPeople: [Person] { people.sorted(using: sortOrder) }
Table(sortedPeople, sortOrder: $sortOrder) { ... }
```

### ❌ KeyPath value KHÔNG Comparable → cột không sortable

```swift
// ❌ Custom type không Comparable → không sort được
TableColumn("Priority", value: \.priority)
// Error nếu Priority không conform Comparable

// ✅ Conform Comparable hoặc dùng comparable property
TableColumn("Priority", value: \.priority.rawValue) { task in
    Text(task.priority.label)
}
```

### ❌ Quên iPhone collapse behavior

```swift
// ❌ Cột đầu tiên chỉ hiện "ID" trên iPhone → vô dụng
Table(items) {
    TableColumn("ID", value: \.id.uuidString)    // ← cột ĐẦU TIÊN → hiện trên iPhone
    TableColumn("Name", value: \.name)            // ← ẩn trên iPhone!
}

// ✅ Đặt cột quan trọng nhất ĐẦU TIÊN
Table(items) {
    TableColumn("Name", value: \.name)            // ← hiện trên iPhone
    TableColumn("ID", value: \.id.uuidString)
}
```

### ❌ Table cho visual grid

```swift
// ❌ Table KHÔNG phải cho photo gallery / product grid
Table(photos) {
    TableColumn("Photo") { photo in Image(photo.name) }
    TableColumn("Title", value: \.title)
}

// ✅ Dùng LazyVGrid cho visual content
LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))]) {
    ForEach(photos) { photo in PhotoCard(photo: photo) }
}
```

---

## 14. Tóm tắt

| Khía cạnh | Chi tiết |
|---|---|
| **Là gì?** | Multi-column data view — hiển thị data dạng bảng |
| **Platforms** | macOS 12+, iPadOS 16+, iOS 16+ (collapse trên iPhone) |
| **TableColumn** | Khai báo cột: header + KeyPath hoặc custom View |
| **Sorting** | `sortOrder: Binding<[KeyPathComparator]>` + `.onChange` để sort data |
| **Selection** | `selection: Binding<ID?>` (single) hoặc `Binding<Set<ID>>` (multi) |
| **Column width** | `.width(CGFloat)`, `.width(min:ideal:max:)` |
| **Sections** | `rows:` parameter với `Section` + `TableRow` (iOS 17+) |
| **iPhone** | Collapse thành 1 cột — chỉ hiện cột ĐẦU TIÊN |
| **Context menu** | `.contextMenu(forSelectionType:)` + `primaryAction:` |
| **vs List** | Table: multi-column, sortable. List: single-column, swipe actions |
| **Dùng khi** | Admin dashboard, data management, spreadsheet-like views |

---

`Table` là view hiển thị data dạng multi-column — giống spreadsheet, Huy. Ba điểm cốt lõi:

**Hai cách khai báo TableColumn:** `TableColumn("Name", value: \.name)` dùng KeyPath — gọn nhưng chỉ hiển thị String VÀ property phải `Comparable` mới sortable. `TableColumn("Status") { item in CustomView() }` dùng closure — linh hoạt hiển thị bất kỳ View nào nhưng **không tự sortable**. Kết hợp cả hai: `TableColumn("Salary", value: \.salary) { emp in Text(emp.salary, format: .currency(code: "USD")) }` — vừa sortable (nhờ value keypath) vừa custom display (nhờ closure).

**Sorting cần xử lý thủ công:** Table chỉ quản lý `sortOrder` state (indicator mũi tên trên header). Data KHÔNG tự sort — phải tự gọi `array.sort(using: sortOrder)` trong `.onChange(of: sortOrder)` hoặc dùng computed property. Quên bước này là sai lầm phổ biến nhất: user tap header thấy indicator thay đổi nhưng rows giữ nguyên.

**iPhone collapse — hạn chế lớn nhất:** Trên iPhone, Table tự động thành List chỉ hiện **cột ĐẦU TIÊN**. Các cột còn lại bị ẩn hoàn toàn. Luôn đặt cột quan trọng nhất ở vị trí đầu, hoặc tạo cột đầu tiên với rich content (tên + email + badge) riêng cho iPhone. Hoặc dùng `horizontalSizeClass` để hiện Table trên iPad, List custom trên iPhone.
