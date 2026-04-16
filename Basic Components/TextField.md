```Swift
// ============================================================
// TEXTFIELD TRONG SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// TextField là input control cho phép user NHẬP VĂN BẢN.
// Tương đương UITextField (single-line) trong UIKit.
// (Multi-line → dùng TextEditor)
//
// Hệ thống API phong phú:
// - Format: number, currency, date (tự parse/validate)
// - Focus management (@FocusState)
// - Keyboard types, text content types (autofill)
// - Secure input (SecureField)
// - Prompt, label, axis (expandable)
// - Submit actions, validation
// - TextFieldStyle (custom appearance)
// ============================================================

import SwiftUI


// ╔══════════════════════════════════════════════════════════╗
// ║  1. CÁC CÁCH KHỞI TẠO                                   ║
// ╚══════════════════════════════════════════════════════════╝

struct TextFieldInitDemo: View {
    @State private var name = ""
    @State private var bio = ""
    @State private var age = 0
    @State private var price = 0.0
    @State private var birthday = Date.now
    @State private var website = ""
    
    var body: some View {
        Form {
            // === 1a. String label + Binding<String> ===
            TextField("Họ và tên", text: $name)
            
            // === 1b. Prompt (placeholder chi tiết hơn label) ===
            TextField("Họ và tên", text: $name, prompt: Text("Nhập họ tên đầy đủ"))
            // Label: cho accessibility / form context
            // Prompt: text mờ hiện trong field khi rỗng
            
            // === 1c. Custom label view (iOS 16+) ===
            TextField(text: $name) {
                Label("Tên hiển thị", systemImage: "person")
            }
            
            // === 1d. Format — Tự động parse number ===
            TextField("Tuổi", value: $age, format: .number)
            // User nhập "25" → age = 25 (Int)
            // User nhập "abc" → KHÔNG cập nhật (invalid)
            
            // === 1e. Format — Currency ===
            TextField("Giá", value: $price,
                      format: .currency(code: "VND"))
            // Hiển thị: "₫1,500,000"
            // Parse ngược: "1500000" → 1_500_000.0
            
            // === 1f. Format — Date ===
            TextField("Ngày sinh", value: $birthday,
                      format: .dateTime.day().month().year())
            
            // === 1g. Axis — Expandable text field (iOS 16+) ===
            TextField("Tiểu sử", text: $bio, axis: .vertical)
                .lineLimit(3...6)
            // Bắt đầu 3 dòng, mở rộng tối đa 6 dòng
            // Thay thế TextEditor cho nhiều trường hợp
            
            // === 1h. URL format ===
            TextField("Website", value: $website,
                      format: .url)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  2. TEXFIELDSTYLE — CÁC KIỂU GIAO DIỆN                 ║
// ╚══════════════════════════════════════════════════════════╝

struct TextFieldStyleDemo: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // === 2a. .automatic (Default) ===
            // Trong Form → rounded border
            // Ngoài Form → plain
            TextField("Automatic", text: $text1)
                .textFieldStyle(.automatic)
            
            // === 2b. .plain — Không border, không background ===
            TextField("Plain", text: $text2)
                .textFieldStyle(.plain)
            
            // === 2c. .roundedBorder — Border rounded ===
            TextField("Rounded Border", text: $text3)
                .textFieldStyle(.roundedBorder)
            
            // ⚠️ CHỈ CÓ 3 built-in styles trên iOS
            // macOS có thêm: .squareBorder
            // Custom style → tự build (Phần 9)
        }
        .padding()
    }
}

// ┌──────────────────────┬────────────────────────────────────┐
// │ Style                │ Mô tả                              │
// ├──────────────────────┼────────────────────────────────────┤
// │ .automatic           │ Platform/context tự chọn           │
// │ .plain               │ Không decoration, text thuần       │
// │ .roundedBorder       │ Gray border, rounded corners       │
// └──────────────────────┴────────────────────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  3. KEYBOARD CONFIGURATION                                ║
// ╚══════════════════════════════════════════════════════════╝

struct KeyboardConfigDemo: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var amount = ""
    @State private var search = ""
    @State private var website = ""
    @State private var code = ""
    
    var body: some View {
        Form {
            // === 3a. keyboardType — Loại bàn phím ===
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            // .default           → Bàn phím thường
            // .emailAddress      → Có @ và .
            // .numberPad         → Chỉ số (không return)
            // .decimalPad        → Số + dấu thập phân
            // .phonePad          → Số + * #
            // .URL               → Có / . .com
            // .asciiCapable      → Chỉ ASCII
            // .numbersAndPunctuation → Số + dấu câu
            // .twitter           → Có @ #
            // .webSearch         → Có Go button
            
            TextField("Số điện thoại", text: $phone)
                .keyboardType(.phonePad)
            
            TextField("Số tiền", text: $amount)
                .keyboardType(.decimalPad)
            
            // === 3b. textInputAutocapitalization ===
            TextField("Search", text: $search)
                .textInputAutocapitalization(.never)
            // .never             → không viết hoa
            // .words             → Viết hoa chữ cái đầu mỗi từ
            // .sentences         → Viết hoa đầu câu (default)
            // .characters        → VIẾT HOA TẤT CẢ
            
            // === 3c. autocorrectionDisabled ===
            TextField("Mã code", text: $code)
                .autocorrectionDisabled()
            // Tắt autocorrect — dùng cho: code, username, ID
            
            // === 3d. textContentType — Autofill hints ===
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
            // iOS Autofill biết đây là email → suggest từ Keychain
            
            // .name              → Tên
            // .namePrefix        → Mr/Mrs
            // .givenName         → Tên
            // .familyName        → Họ
            // .emailAddress      → Email
            // .telephoneNumber   → SĐT
            // .streetAddressLine1 → Địa chỉ
            // .postalCode        → Mã bưu điện
            // .creditCardNumber  → Số thẻ
            // .oneTimeCode       → OTP (auto-fill từ SMS!)
            // .password          → Password (Keychain)
            // .newPassword       → Strong Password suggestion
            // .username          → Username (Keychain)
            
            TextField("OTP", text: $code)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
            // iOS tự đọc SMS OTP → suggest autofill!
            
            // === 3e. Kết hợp nhiều modifiers ===
            TextField("Email đăng nhập", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            // Config hoàn chỉnh cho email input
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. @FocusState — QUẢN LÝ FOCUS                         ║
// ╚══════════════════════════════════════════════════════════╝

// @FocusState điều khiển field nào đang active (có cursor).
// Dùng cho: auto-focus, dismiss keyboard, navigate fields.

// === 4a. Boolean — Single field ===
struct SingleFocusDemo: View {
    @State private var text = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Nhập text", text: $text)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
            
            HStack {
                // Auto-focus
                Button("Focus") { isFocused = true }
                
                // Dismiss keyboard
                Button("Dismiss") { isFocused = false }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .onAppear {
            // Auto-focus khi view appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}

// === 4b. Enum — Multiple fields navigation ===
struct MultiFocusDemo: View {
    enum Field: Hashable {
        case username, email, password
    }
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Form {
            TextField("Username", text: $username)
                .focused($focusedField, equals: .username)
                .textContentType(.username)
                .submitLabel(.next) // Nút Return → "Next"
            
            TextField("Email", text: $email)
                .focused($focusedField, equals: .email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .submitLabel(.next)
            
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .textContentType(.newPassword)
                .submitLabel(.done) // Nút Return → "Done"
            
            Button("Đăng ký") {
                register()
            }
            .disabled(username.isEmpty || email.isEmpty || password.isEmpty)
        }
        // Navigate fields khi nhấn Return/Next
        .onSubmit {
            switch focusedField {
            case .username:
                focusedField = .email       // Username → Email
            case .email:
                focusedField = .password    // Email → Password
            case .password:
                focusedField = nil          // Password → Dismiss
                register()
            case nil:
                break
            }
        }
        // Toolbar dismiss button
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Xong") {
                    focusedField = nil
                }
            }
        }
    }
    
    func register() {
        focusedField = nil // Dismiss keyboard
        // Perform registration...
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. .onSubmit & .submitLabel — XỬ LÝ NÚT RETURN         ║
// ╚══════════════════════════════════════════════════════════╝

struct SubmitDemo: View {
    @State private var searchQuery = ""
    @State private var results: [String] = []
    
    var body: some View {
        VStack(spacing: 16) {
            // === 5a. .onSubmit — Action khi nhấn Return ===
            TextField("Tìm kiếm...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    performSearch()
                }
            // User nhấn Return → gọi performSearch()
            
            // === 5b. .submitLabel — Đổi text nút Return ===
            // .done       → "Done"
            // .go         → "Go"
            // .send       → "Send"
            // .search     → "Search" (kính lúp)
            // .next       → "Next"
            // .continue   → "Continue"
            // .join       → "Join"
            // .return     → "Return" (default)
            // .route      → "Route"
            
            TextField("Tìm kiếm", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit { performSearch() }
            
            // Results
            ForEach(results, id: \.self) { item in
                Text(item)
            }
        }
        .padding()
    }
    
    func performSearch() {
        results = (1...5).map { "\(searchQuery) — kết quả \($0)" }
    }
}

// === .onSubmit scope — apply cho nhiều fields cùng lúc ===
struct OnSubmitScopeDemo: View {
    @State private var field1 = ""
    @State private var field2 = ""
    
    var body: some View {
        VStack {
            TextField("Field 1", text: $field1)
            TextField("Field 2", text: $field2)
        }
        .onSubmit {
            // Trigger cho CẢ HAI fields khi nhấn Return
            print("Submitted from either field")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. SECUREFIELD — MẬT KHẨU                              ║
// ╚══════════════════════════════════════════════════════════╝

struct SecureFieldDemo: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    
    var body: some View {
        Form {
            // === 6a. SecureField cơ bản ===
            SecureField("Mật khẩu", text: $password)
                .textContentType(.password)
            // Hiển thị dots (•••), ẩn ký tự
            // iOS đề xuất strong password nếu .newPassword
            
            // === 6b. Toggle hiện/ẩn password ===
            HStack {
                Group {
                    if showPassword {
                        TextField("Mật khẩu", text: $password)
                    } else {
                        SecureField("Mật khẩu", text: $password)
                    }
                }
                .textContentType(.password)
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // === 6c. Confirm password ===
            SecureField("Xác nhận mật khẩu", text: $confirmPassword)
                .textContentType(.newPassword)
            
            if !confirmPassword.isEmpty && password != confirmPassword {
                Text("Mật khẩu không khớp")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. VALIDATION — KIỂM TRA ĐẦU VÀO                       ║
// ╚══════════════════════════════════════════════════════════╝

struct ValidationDemo: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var age = ""
    
    @FocusState private var focusedField: FormField?
    
    enum FormField: Hashable {
        case email, phone, age
    }
    
    // Validation states
    private var emailError: String? {
        guard !email.isEmpty else { return nil }
        let regex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
        return email.wholeMatch(of: regex) == nil ? "Email không hợp lệ" : nil
    }
    
    private var phoneError: String? {
        guard !phone.isEmpty else { return nil }
        let digits = phone.filter(\.isNumber)
        return digits.count < 10 ? "SĐT phải có ít nhất 10 số" : nil
    }
    
    private var ageError: String? {
        guard !age.isEmpty else { return nil }
        guard let num = Int(age) else { return "Phải là số" }
        return (num < 1 || num > 150) ? "Tuổi không hợp lệ" : nil
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !phone.isEmpty && !age.isEmpty
        && emailError == nil && phoneError == nil && ageError == nil
    }
    
    var body: some View {
        Form {
            Section {
                ValidatedField(
                    title: "Email",
                    text: $email,
                    error: emailError,
                    icon: "envelope",
                    keyboard: .emailAddress,
                    contentType: .emailAddress,
                    isFocused: focusedField == .email
                )
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                
                ValidatedField(
                    title: "Số điện thoại",
                    text: $phone,
                    error: phoneError,
                    icon: "phone",
                    keyboard: .phonePad,
                    contentType: .telephoneNumber,
                    isFocused: focusedField == .phone
                )
                .focused($focusedField, equals: .phone)
                .submitLabel(.next)
                
                ValidatedField(
                    title: "Tuổi",
                    text: $age,
                    error: ageError,
                    icon: "number",
                    keyboard: .numberPad,
                    contentType: nil,
                    isFocused: focusedField == .age
                )
                .focused($focusedField, equals: .age)
                .submitLabel(.done)
            }
            
            Section {
                Button("Gửi") { }
                    .frame(maxWidth: .infinity)
                    .disabled(!isFormValid)
            }
        }
        .onSubmit {
            switch focusedField {
            case .email: focusedField = .phone
            case .phone: focusedField = .age
            case .age: focusedField = nil
            case nil: break
            }
        }
    }
}

// Reusable validated field component
struct ValidatedField: View {
    let title: String
    @Binding var text: String
    let error: String?
    var icon: String? = nil
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(error != nil ? .red : (isFocused ? .blue : .secondary))
                        .frame(width: 20)
                }
                
                TextField(title, text: $text)
                    .keyboardType(keyboard)
                    .textContentType(contentType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                // Status icon
                if !text.isEmpty {
                    Image(systemName: error == nil ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(error == nil ? .green : .red)
                        .font(.subheadline)
                }
            }
            
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: error)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. .onChange — REALTIME TEXT PROCESSING                  ║
// ╚══════════════════════════════════════════════════════════╝

struct TextProcessingDemo: View {
    @State private var phone = ""
    @State private var cardNumber = ""
    @State private var username = ""
    @State private var charCount = 0
    
    var body: some View {
        Form {
            // === 8a. Auto-format phone number ===
            TextField("Số điện thoại", text: $phone)
                .keyboardType(.numberPad)
                .onChange(of: phone) { _, newValue in
                    // Chỉ giữ digits
                    let digits = newValue.filter(\.isNumber)
                    // Limit 10 digits
                    let limited = String(digits.prefix(10))
                    // Format: 0912 345 678
                    phone = formatPhone(limited)
                }
            
            // === 8b. Credit card formatting ===
            TextField("Số thẻ", text: $cardNumber)
                .keyboardType(.numberPad)
                .onChange(of: cardNumber) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    let limited = String(digits.prefix(16))
                    // Format: 4242 4242 4242 4242
                    cardNumber = formatCardNumber(limited)
                }
            
            // === 8c. Character limit + counter ===
            VStack(alignment: .trailing, spacing: 4) {
                TextField("Username", text: $username)
                    .onChange(of: username) { _, newValue in
                        // Limit 20 characters, lowercase, no spaces
                        let processed = String(
                            newValue
                                .lowercased()
                                .filter { $0.isLetter || $0.isNumber || $0 == "_" }
                                .prefix(20)
                        )
                        if processed != newValue {
                            username = processed
                        }
                        charCount = username.count
                    }
                
                Text("\(charCount)/20")
                    .font(.caption)
                    .foregroundStyle(charCount >= 18 ? .orange : .secondary)
            }
        }
    }
    
    func formatPhone(_ digits: String) -> String {
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i == 4 || i == 7 { result += " " }
            result.append(ch)
        }
        return result
    }
    
    func formatCardNumber(_ digits: String) -> String {
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i > 0 && i % 4 == 0 { result += " " }
            result.append(ch)
        }
        return result
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. CUSTOM TEXTFIELD STYLE — TẠO STYLE RIÊNG            ║
// ╚══════════════════════════════════════════════════════════╝

// TextFieldStyle protocol:
// func _body(configuration: TextField<Self._Label>) -> some View

// === 9a. Underline Style ===

struct UnderlineTextFieldStyle: TextFieldStyle {
    var icon: String? = nil
    var isValid: Bool = true
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(isFocused ? .blue : .secondary)
                    .frame(width: 20)
            }
            
            configuration
                .focused($isFocused)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(isFocused ? .blue : (isValid ? .gray.opacity(0.3) : .red))
                .frame(height: isFocused ? 2 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// === 9b. Filled/Material Style ===

struct FilledTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .focused($isFocused)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(isFocused ? 0.12 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isFocused ? .blue : .clear,
                        lineWidth: 1.5
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// === 9c. Floating Label Style ===

struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    private var isFloating: Bool {
        isFocused || !text.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Floating label
            Text(title)
                .font(isFloating ? .caption : .body)
                .foregroundStyle(isFocused ? .blue : .secondary)
                .offset(y: isFloating ? -24 : 0)
                .animation(.easeInOut(duration: 0.2), value: isFloating)
            
            // TextField
            TextField("", text: $text)
                .focused($isFocused)
        }
        .padding(.top, 16) // Space cho floating label
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(isFocused ? .blue : .gray.opacity(0.3))
                .frame(height: isFocused ? 2 : 1)
        }
    }
}

#Preview("Custom Styles") {
    VStack(spacing: 24) {
        // Underline
        TextField("Email", text: .constant(""))
            .textFieldStyle(UnderlineTextFieldStyle(icon: "envelope"))
        
        // Filled
        TextField("Password", text: .constant(""))
            .textFieldStyle(FilledTextFieldStyle())
        
        // Floating label
        FloatingLabelTextField(title: "Username", text: .constant(""))
        
        FloatingLabelTextField(title: "Đã nhập", text: .constant("huy_dev"))
    }
    .padding(24)
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. TEXTEDITOR — MULTI-LINE INPUT                       ║
// ╚══════════════════════════════════════════════════════════╝

struct TextEditorDemo: View {
    @State private var notes = ""
    @State private var bio = ""
    
    var body: some View {
        Form {
            // === 10a. TextEditor cơ bản ===
            Section("Ghi chú") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100, maxHeight: 200)
            }
            
            // === 10b. TextEditor styled ===
            Section("Tiểu sử") {
                ZStack(alignment: .topLeading) {
                    // Placeholder (TextEditor không có built-in)
                    if bio.isEmpty {
                        Text("Viết vài dòng về bản thân...")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                    }
                    
                    TextEditor(text: $bio)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        // .hidden để custom background
                }
            }
            
            // === 10c. iOS 16+ Alternative: TextField with axis ===
            Section("Mô tả (TextField expandable)") {
                TextField("Nhập mô tả...", text: $notes, axis: .vertical)
                    .lineLimit(3...8) // Min 3, max 8 dòng
                // Ưu điểm hơn TextEditor:
                // ✅ Có placeholder built-in
                // ✅ Auto-expand theo content
                // ✅ onSubmit hoạt động
                // ✅ Giao diện nhất quán với TextField
            }
        }
    }
}

// ┌────────────────────┬──────────────────┬──────────────────────┐
// │                    │ TextField axis:  │ TextEditor           │
// │                    │ .vertical        │                      │
// ├────────────────────┼──────────────────┼──────────────────────┤
// │ Multi-line         │ ✅              │ ✅                    │
// │ Placeholder        │ ✅ Built-in     │ ❌ Phải tự build     │
// │ Auto-expand        │ ✅ lineLimit    │ ❌ Fixed frame       │
// │ onSubmit           │ ✅              │ ❌                    │
// │ Min iOS            │ 16              │ 14                    │
// │ Format support     │ ✅              │ ❌                    │
// │ Full text editing  │ Limited         │ ✅ Rich editing      │
// └────────────────────┴──────────────────┴──────────────────────┘


// ╔══════════════════════════════════════════════════════════╗
// ║  11. PRODUCTION PATTERNS                                  ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. Login Form ===

struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @FocusState private var focus: Field?
    
    enum Field: Hashable { case email, password }
    
    var body: some View {
        VStack(spacing: 20) {
            // Email
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
            }
            .padding()
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(focus == .email ? .blue : .clear, lineWidth: 1.5)
            )
            
            // Password
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                Group {
                    if showPassword {
                        TextField("Mật khẩu", text: $password)
                    } else {
                        SecureField("Mật khẩu", text: $password)
                    }
                }
                .textContentType(.password)
                .focused($focus, equals: .password)
                .submitLabel(.go)
                
                Button { showPassword.toggle() } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.gray.opacity(0.08), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(focus == .password ? .blue : .clear, lineWidth: 1.5)
            )
            
            // Login button
            Button {
                focus = nil
                isLoading = true
            } label: {
                HStack {
                    if isLoading { ProgressView().controlSize(.small) }
                    Text("Đăng nhập")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.blue, in: .rect(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .disabled(email.isEmpty || password.isEmpty || isLoading)
        }
        .padding(24)
        .onSubmit {
            switch focus {
            case .email: focus = .password
            case .password: focus = nil; isLoading = true
            case nil: break
            }
        }
    }
}


// === 11b. Search Bar Component ===

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Tìm kiếm..."
    var onSubmit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(10)
        .background(.gray.opacity(0.1), in: .capsule)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}


// === 11c. OTP / Code Input ===

struct OTPInputView: View {
    @State private var code = ""
    @FocusState private var isFocused: Bool
    let length: Int = 6
    var onComplete: ((String) -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Hidden TextField để nhận keyboard input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01) // Gần như ẩn nhưng vẫn nhận input
                .onChange(of: code) { _, newValue in
                    code = String(newValue.filter(\.isNumber).prefix(length))
                    if code.count == length {
                        isFocused = false
                        onComplete?(code)
                    }
                }
            
            // Visual boxes
            HStack(spacing: 10) {
                ForEach(0..<length, id: \.self) { i in
                    let char = i < code.count
                        ? String(code[code.index(code.startIndex, offsetBy: i)])
                        : ""
                    
                    Text(char)
                        .font(.title.monospaced().bold())
                        .frame(width: 48, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.gray.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(
                                    i == code.count && isFocused
                                        ? .blue
                                        : .gray.opacity(0.2),
                                    lineWidth: i == code.count && isFocused ? 2 : 1
                                )
                        )
                }
            }
        }
        .onTapGesture { isFocused = true }
        .onAppear { isFocused = true }
    }
}

#Preview("OTP") {
    VStack(spacing: 24) {
        Text("Nhập mã OTP").font(.title2.bold())
        Text("Chúng tôi đã gửi mã 6 số qua SMS")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        
        OTPInputView { code in
            print("OTP: \(code)")
        }
    }
    .padding()
}


// ╔══════════════════════════════════════════════════════════╗
// ║  12. ACCESSIBILITY                                       ║
// ╚══════════════════════════════════════════════════════════╝

struct AccessibleTextFieldDemo: View {
    @State private var name = ""
    @State private var amount = ""
    
    var body: some View {
        Form {
            // TextField tự động accessible (label = title string)
            TextField("Họ và tên", text: $name)
            // VoiceOver: "Họ và tên, text field, double tap to edit"
            
            // Custom accessibility
            TextField("Số tiền", text: $amount)
                .keyboardType(.decimalPad)
                .accessibilityLabel("Nhập số tiền thanh toán")
                .accessibilityHint("Nhập số tiền bằng VND, chỉ số")
                .accessibilityValue(amount.isEmpty ? "Trống" : "\(amount) đồng")
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  13. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Keyboard không dismiss khi tap ngoài
//    SwiftUI KHÔNG auto-dismiss keyboard khi tap outside
//    ✅ FIX:
//    .onTapGesture { focusedField = nil }        // Đơn giản
//    .scrollDismissesKeyboard(.interactively)     // ScrollView
//    .toolbar { ToolbarItem(placement: .keyboard) {
//        Button("Done") { focusedField = nil }
//    }}

// ❌ PITFALL 2: Format value không cập nhật khi đang nhập
//    TextField("Age", value: $age, format: .number)
//    → Giá trị chỉ commit khi user nhấn Return hoặc blur
//    → KHÔNG update realtime mỗi keystroke
//    ✅ FIX: Dùng text: $string + .onChange parse thủ công
//            nếu cần realtime update

// ❌ PITFALL 3: .onSubmit không fire với .numberPad
//    numberPad KHÔNG CÓ nút Return → onSubmit không bao giờ fire
//    ✅ FIX: .toolbar keyboard button "Done"
//            hoặc dùng .default keyboard + filter digits

// ❌ PITFALL 4: TextField trong List row — full row tappable
//    List { TextField("Name", text: $name) }
//    → Tap bất kỳ đâu trên row → focus TextField (đúng behavior)
//    Nhưng nếu có NHIỀU tappable elements → conflict
//    ✅ FIX: .buttonStyle(.borderless) cho buttons cùng row

// ❌ PITFALL 5: SecureField ↔ TextField toggle reset text
//    if show { TextField } else { SecureField }
//    → Chuyển đổi tạo view MỚI → có thể mất focus
//    ✅ FIX: Giữ cùng Binding, dùng .id(showPassword)
//            để control identity nếu cần

// ❌ PITFALL 6: TextEditor không có placeholder
//    TextEditor(text: $bio)  // Không có prompt parameter
//    ✅ FIX: ZStack + conditional Text overlay (Phần 10)
//            Hoặc dùng TextField(axis: .vertical) từ iOS 16+

// ❌ PITFALL 7: Auto-focus onAppear không hoạt động
//    .onAppear { isFocused = true }
//    → Đôi khi không work vì view chưa render xong
//    ✅ FIX: DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
//            hoặc .task { try? await Task.sleep(for: .milliseconds(300))
//                         isFocused = true }

// ✅ BEST PRACTICES:
// 1. @FocusState + enum cho multi-field navigation
// 2. .submitLabel phù hợp: .next cho fields giữa, .done/.go cho cuối
// 3. .textContentType cho mọi field → iOS Autofill smart suggestions
// 4. .keyboardType phù hợp → UX tốt hơn nhiều
// 5. .autocorrectionDisabled() cho: email, username, code, OTP
// 6. .textInputAutocapitalization(.never) cho: email, username
// 7. .toolbar keyboard "Done" button cho numberPad/phonePad
// 8. .onChange cho realtime formatting (phone, card, limit chars)
// 9. .scrollDismissesKeyboard(.interactively) cho ScrollView forms
// 10. TextField(axis: .vertical) thay TextEditor khi có thể (iOS 16+)
// 11. Validate onChange (realtime) + onSubmit (final check)
// 12. Custom TextFieldStyle cho design system consistency
```

---

TextField là component nhập liệu phức tạp nhất trong SwiftUI — từ formatting, validation, focus management đến keyboard customization và secure input. Mình sẽ giải thích toàn bộ.Mình đã tổng hợp toàn bộ kiến thức TextField trong 13 phần. Đây là những điểm cốt lõi:

**TextField phức tạp hơn nhiều so với vẻ ngoài** — không chỉ là ô nhập text mà bao gồm cả format parsing (number, currency, date), focus management, keyboard configuration, autofill integration, validation patterns, và custom styles.

**Năm phần giá trị nhất cho production:**

**Phần 4 — @FocusState**: Đây là API then chốt cho mọi form. Pattern `enum Field` + `.focused($focus, equals:)` + `.onSubmit` navigation cho phép user nhấn Next/Done trên keyboard để nhảy qua từng field — y hệt native iOS apps. Kết hợp `.submitLabel(.next)` cho fields giữa, `.submitLabel(.done)` cho field cuối.

**Phần 3 — textContentType**: Modifier nhỏ nhưng impact cực lớn — `.oneTimeCode` khiến iOS **tự đọc SMS OTP và suggest autofill**, `.emailAddress` + `.password` trigger **Keychain autofill**, `.newPassword` trigger **strong password suggestion**. Chỉ 1 dòng code mà UX cải thiện đáng kể.

**Phần 7 — Validation**: Reusable `ValidatedField` component kết hợp realtime validation (check mỗi keystroke), visual feedback (checkmark/error icon), error message animated, và integration với `@FocusState`. Pattern này scalable cho mọi form trong app.

**Phần 8 — Real-time Formatting**: Pattern `.onChange(of:)` để auto-format phone number (`0912 345 678`), credit card (`4242 4242 4242 4242`), và character limit + filter. Trick: filter → limit → format trong onChange, set lại binding nếu khác — SwiftUI chỉ re-render khi giá trị thực sự thay đổi.

**Phần 11c — OTP Input**: Component OTP 6 ô hoàn chỉnh — dùng hidden TextField nhận keyboard input, visual boxes hiển thị từng digit, `.textContentType(.oneTimeCode)` cho auto-fill SMS. Pattern này rất phổ biến mà SwiftUI không có built-in.

**Pitfall #3 đáng chú ý nhất**: `.numberPad` không có nút Return → `.onSubmit` **không bao giờ fire**. Phải thêm `.toolbar` keyboard button "Done" — đây là lỗi rất nhiều developer gặp.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
