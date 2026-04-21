```SwiftUI
// ============================================================
// XCUITEST TRONG SWIFT & SWIFTUI — GIẢI THÍCH CHI TIẾT
// ============================================================
// XCUITest là framework UI AUTOMATION testing của Apple:
// - Chạy app THẬT trên Simulator/Device
// - Tương tác như USER THẬT: tap, swipe, type, scroll
// - Assert UI elements: exists, label, value, enabled
// - Black-box: test KHÔNG biết internal code
//
// Khác biệt với Unit Test:
// - Unit Test: test functions/logic, KHÔNG render UI
// - XCUITest: test TOÀN BỘ app flow, render UI thật
//
// Architecture:
// ┌─────────────┐     IPC      ┌──────────────────┐
// │  Test Runner │ ◄──────────► │  App Under Test  │
// │  (Process 1) │              │  (Process 2)     │
// └─────────────┘              └──────────────────┘
// Test và App chạy KHÁC PROCESS → test không access app code
// ============================================================

import XCTest


// ╔══════════════════════════════════════════════════════════╗
// ║  1. SETUP & CẤU TRÚC CƠ BẢN                             ║
// ╚══════════════════════════════════════════════════════════╝

// Xcode tạo UI Test target: File > New > Target > UI Testing Bundle
// Hoặc khi tạo project: check "Include Tests"

// === Test class structure ===

final class LoginUITests: XCTestCase {
    
    // App reference — launch point
    private var app: XCUIApplication!
    
    // CHẠY TRƯỚC MỖI test method
    override func setUpWithError() throws {
        // Dừng ngay khi test fail (không chạy tiếp)
        continueAfterFailure = false
        
        // Khởi tạo app
        app = XCUIApplication()
        
        // === Launch arguments: truyền flags vào app ===
        app.launchArguments = [
            "--uitesting",          // App biết đang UI test
            "--reset-state",        // Reset app state
            "--disable-animations", // Tắt animation cho test nhanh
        ]
        
        // === Launch environment: truyền env variables ===
        app.launchEnvironment = [
            "API_BASE_URL": "http://localhost:8080",  // Mock server
            "DISABLE_ANALYTICS": "true",
            "UI_TEST_MODE": "true",
        ]
        
        // Launch app
        app.launch()
    }
    
    // CHẠY SAU MỖI test method
    override func tearDownWithError() throws {
        app = nil
    }
    
    // === Test methods: BẮT ĐẦU bằng "test" ===
    
    func testLoginSuccess() throws {
        // 1. Tìm elements
        let emailField = app.textFields["email_field"]
        let passwordField = app.secureTextFields["password_field"]
        let loginButton = app.buttons["login_button"]
        
        // 2. Tương tác
        emailField.tap()
        emailField.typeText("huy@example.com")
        
        passwordField.tap()
        passwordField.typeText("password123")
        
        loginButton.tap()
        
        // 3. Assert kết quả
        let welcomeLabel = app.staticTexts["welcome_label"]
        XCTAssertTrue(welcomeLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(welcomeLabel.label, "Xin chào, Huy!")
    }
    
    func testLoginFailure() throws {
        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("wrong@email.com")
        
        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("wrong")
        
        app.buttons["login_button"].tap()
        
        // Assert error alert
        let alert = app.alerts["login_error"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Sai email hoặc mật khẩu"].exists)
        
        // Dismiss alert
        alert.buttons["OK"].tap()
        XCTAssertFalse(alert.exists)
    }
}

// App code: đọc launch arguments để config cho testing
// @main
// struct MyApp: App {
//     init() {
//         if ProcessInfo.processInfo.arguments.contains("--uitesting") {
//             // Disable animations
//             UIView.setAnimationsEnabled(false)
//             // Use mock services
//             // Reset UserDefaults
//         }
//     }
// }


// ╔══════════════════════════════════════════════════════════╗
// ║  2. ACCESSIBILITY IDENTIFIERS — CHÌA KHOÁ CỦA XCUITEST  ║
// ╚══════════════════════════════════════════════════════════╝

// XCUITest tìm elements qua ACCESSIBILITY IDENTIFIERS.
// Đây là cầu nối DUY NHẤT giữa test code và app code.

// === SwiftUI: .accessibilityIdentifier() ===

/*
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .accessibilityIdentifier("email_field")
                // ← Test tìm: app.textFields["email_field"]
            
            SecureField("Mật khẩu", text: $password)
                .accessibilityIdentifier("password_field")
            
            Button("Đăng nhập") { login() }
                .accessibilityIdentifier("login_button")
            
            Text("Xin chào, \(username)")
                .accessibilityIdentifier("welcome_label")
            
            // List items: dùng dynamic identifiers
            ForEach(items) { item in
                Text(item.title)
                    .accessibilityIdentifier("item_\(item.id)")
            }
            
            // Toggle
            Toggle("Nhớ mật khẩu", isOn: $rememberMe)
                .accessibilityIdentifier("remember_toggle")
            
            // Navigation
            NavigationLink("Profile") { ProfileView() }
                .accessibilityIdentifier("profile_link")
        }
    }
}
*/

// NAMING CONVENTION cho identifiers:
// screen_element_purpose
// login_email_field
// login_password_field
// login_submit_button
// home_item_\(id)
// profile_avatar_image
// settings_dark_mode_toggle

// ⚠️ QUAN TRỌNG:
// .accessibilityIdentifier KHÁC .accessibilityLabel:
// - identifier: CHỈ cho testing (user KHÔNG thấy)
// - label: cho VoiceOver (user NGHE thấy)
// Dùng identifier cho test, label cho accessibility.


// ╔══════════════════════════════════════════════════════════╗
// ║  3. ELEMENT QUERIES — TÌM UI ELEMENTS                    ║
// ╚══════════════════════════════════════════════════════════╝

final class ElementQueryTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testElementQueries() {
        // ============ QUERY BY TYPE ============
        
        // --- Text / Labels ---
        let label = app.staticTexts["welcome_label"]
        // SwiftUI Text() → staticTexts
        
        // --- Buttons ---
        let button = app.buttons["login_button"]
        // SwiftUI Button() → buttons
        // NavigationLink → buttons (khi rendered)
        
        // --- TextFields ---
        let textField = app.textFields["email_field"]
        // SwiftUI TextField() → textFields
        
        // --- SecureFields ---
        let secureField = app.secureTextFields["password_field"]
        // SwiftUI SecureField() → secureTextFields
        
        // --- Toggles (Switches) ---
        let toggle = app.switches["remember_toggle"]
        // SwiftUI Toggle() → switches
        
        // --- Sliders ---
        let slider = app.sliders["volume_slider"]
        
        // --- Pickers ---
        let picker = app.pickers["category_picker"]
        
        // --- Images ---
        let image = app.images["avatar_image"]
        
        // --- Navigation Bars ---
        let navBar = app.navigationBars["Settings"]
        // Tìm theo title
        
        // --- Tab Bars ---
        let tabBar = app.tabBars
        let homeTab = tabBar.buttons["Home"]
        
        // --- Alerts ---
        let alert = app.alerts.firstMatch
        let alertButton = alert.buttons["OK"]
        
        // --- Sheets ---
        let sheet = app.sheets.firstMatch
        
        // --- Scroll Views ---
        let scrollView = app.scrollViews.firstMatch
        
        // --- Tables (List) ---
        let table = app.tables.firstMatch
        let cell = table.cells["item_cell_1"]
        
        // --- Collection Views ---
        let collection = app.collectionViews.firstMatch
        
        
        // ============ QUERY METHODS ============
        
        // --- By identifier (KHUYẾN KHÍCH) ---
        let _ = app.buttons["login_button"]
        
        // --- By label text ---
        let _ = app.buttons["Đăng nhập"]  // Tìm theo accessibilityLabel
        
        // --- By predicate (flexible) ---
        let predicate = NSPredicate(format: "label CONTAINS[c] 'xin chào'")
        let _ = app.staticTexts.matching(predicate).firstMatch
        
        // --- By index ---
        let _ = app.buttons.element(boundBy: 0)  // Button đầu tiên
        
        // --- firstMatch (nhanh hơn .element) ---
        let _ = app.buttons.firstMatch
        // firstMatch dừng ngay khi tìm thấy 1 element
        // .element yêu cầu CHÍNH XÁC 1 match, fail nếu > 1
        
        // --- Descendants / Children ---
        let cell2 = app.tables.firstMatch.cells.firstMatch
        let textInCell = cell2.staticTexts["item_title"]
        // Tìm element BÊN TRONG element khác (scoped query)
        
        // --- Count ---
        let buttonCount = app.buttons.count
        let _ = buttonCount  // Số buttons hiện tại
        
        
        // ============ QUERY CHAINING ============
        
        // Tìm button "Delete" TRONG cell cụ thể
        let specificCell = app.tables.firstMatch.cells["item_cell_3"]
        let deleteButton = specificCell.buttons["delete_button"]
        let _ = deleteButton
        
        // Tìm text TRONG navigation bar
        let navTitle = app.navigationBars.firstMatch.staticTexts.firstMatch
        let _ = navTitle
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  4. INTERACTIONS — TƯƠNG TÁC VỚI ELEMENTS                ║
// ╚══════════════════════════════════════════════════════════╝

final class InteractionTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testTapInteractions() {
        // === TAP ===
        app.buttons["login_button"].tap()
        
        // Double tap
        app.images["photo"].doubleTap()
        
        // Long press
        app.cells["item_cell"].press(forDuration: 1.5)
        // → Trigger context menu, drag, etc.
        
        // Two-finger tap
        app.maps.firstMatch.twoFingerTap()
    }
    
    func testTextInput() {
        let field = app.textFields["email_field"]
        
        // Tap để focus
        field.tap()
        
        // Type text
        field.typeText("huy@example.com")
        
        // Clear field trước khi type
        // Cách 1: Select all + Delete
        field.tap()
        field.press(forDuration: 1.0) // Long press → select
        app.menuItems["Select All"].tap()
        field.typeText("") // Hoặc dùng XCUIKeyboardKey
        
        // Cách 2: Clear button (nếu có)
        if field.buttons["Clear text"].exists {
            field.buttons["Clear text"].tap()
        }
        
        // Type special keys
        field.typeText("\n")  // Return/Enter
        field.typeText("\t")  // Tab
        
        // Keyboard dismiss (khi không có Done button)
        // Tap outside
        app.tap()
        // Hoặc:
        // app.keyboards.buttons["return"].tap()
    }
    
    func testScrolling() {
        let table = app.tables.firstMatch
        
        // Swipe
        table.swipeUp()     // Scroll xuống
        table.swipeDown()   // Scroll lên
        table.swipeLeft()   // Scroll phải
        table.swipeRight()  // Scroll trái
        
        // Scroll đến element cụ thể
        let targetCell = table.cells["item_99"]
        // Swipe cho đến khi element xuất hiện
        while !targetCell.isHittable {
            table.swipeUp()
        }
        
        // Scroll nhẹ hơn (slower, more controlled)
        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let end = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
    
    func testSwipeActions() {
        let cell = app.tables.firstMatch.cells.firstMatch
        
        // Swipe to delete (trailing swipe)
        cell.swipeLeft()
        
        // Tap delete button xuất hiện
        let deleteButton = cell.buttons["Xoá"]
        if deleteButton.waitForExistence(timeout: 2) {
            deleteButton.tap()
        }
        
        // Leading swipe
        cell.swipeRight()
    }
    
    func testToggleAndPicker() {
        // Toggle
        let toggle = app.switches["dark_mode_toggle"]
        toggle.tap() // Toggle on/off
        
        // Check value
        XCTAssertEqual(toggle.value as? String, "1") // "1" = on, "0" = off
        
        // Picker (wheel style)
        let picker = app.pickerWheels.firstMatch
        picker.adjust(toPickerWheelValue: "Option B")
        
        // Slider
        let slider = app.sliders["volume_slider"]
        slider.adjust(toNormalizedSliderPosition: 0.75) // 75%
    }
    
    func testAlertInteraction() {
        // Trigger alert
        app.buttons["delete_account_button"].tap()
        
        // Wait for alert
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        
        // Check alert content
        XCTAssertTrue(alert.staticTexts["Xác nhận xoá?"].exists)
        
        // Tap alert button
        alert.buttons["Xoá"].tap()
        
        // Verify alert dismissed
        XCTAssertFalse(alert.exists)
    }
    
    func testSheetInteraction() {
        // Open sheet
        app.buttons["show_options"].tap()
        
        // Wait for sheet
        let sheet = app.otherElements["options_sheet"]
        XCTAssertTrue(sheet.waitForExistence(timeout: 3))
        
        // Interact within sheet
        sheet.buttons["option_1"].tap()
        
        // Dismiss sheet (swipe down)
        sheet.swipeDown()
    }
    
    func testPullToRefresh() {
        let table = app.tables.firstMatch
        
        // Pull to refresh: drag from top downward
        let start = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = table.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: end)
        
        // Wait for refresh to complete
        let refreshedContent = app.staticTexts["refreshed_indicator"]
        XCTAssertTrue(refreshedContent.waitForExistence(timeout: 5))
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  5. ASSERTIONS — KIỂM TRA KẾT QUẢ                        ║
// ╚══════════════════════════════════════════════════════════╝

final class AssertionTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testAssertions() {
        // === EXISTS ===
        XCTAssertTrue(app.buttons["login_button"].exists)
        XCTAssertFalse(app.buttons["nonexistent"].exists)
        
        // === WAIT FOR EXISTENCE (quan trọng nhất cho async UI) ===
        let element = app.staticTexts["loaded_content"]
        XCTAssertTrue(element.waitForExistence(timeout: 10))
        // Chờ TỐI ĐA 10 giây cho element xuất hiện
        // Trả về true ngay khi tìm thấy (không chờ hết timeout)
        
        // === LABEL (accessibility label / text content) ===
        let label = app.staticTexts["welcome_label"]
        XCTAssertEqual(label.label, "Xin chào, Huy!")
        
        // === VALUE (cho TextField, Toggle, Slider) ===
        let textField = app.textFields["email_field"]
        XCTAssertEqual(textField.value as? String, "huy@example.com")
        
        let toggle = app.switches["dark_mode"]
        XCTAssertEqual(toggle.value as? String, "1") // on
        
        // === ENABLED / DISABLED ===
        XCTAssertTrue(app.buttons["submit_button"].isEnabled)
        XCTAssertFalse(app.buttons["disabled_button"].isEnabled)
        
        // === HITTABLE (visible + tappable) ===
        XCTAssertTrue(app.buttons["visible_button"].isHittable)
        // isHittable = exists + visible on screen + not obscured
        // exists nhưng không hittable: element bị scroll khỏi viewport
        
        // === SELECTED ===
        XCTAssertTrue(app.buttons["selected_tab"].isSelected)
        
        // === COUNT ===
        XCTAssertEqual(app.tables.firstMatch.cells.count, 5)
        XCTAssertGreaterThan(app.buttons.count, 0)
        
        // === PREDICATE-BASED EXPECTATION (advanced) ===
        let existsPredicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(
            predicate: existsPredicate,
            object: app.staticTexts["async_content"]
        )
        wait(for: [expectation], timeout: 10)
        
        // === CUSTOM WAIT: element attribute change ===
        let button = app.buttons["loading_button"]
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = XCTNSPredicateExpectation(
            predicate: enabledPredicate,
            object: button
        )
        wait(for: [enabledExpectation], timeout: 10)
        // Chờ button CHUYỂN từ disabled → enabled
    }
    
    func testWaitForDisappearance() {
        // Chờ element BIẾN MẤT (loading spinner, overlay)
        let spinner = app.activityIndicators.firstMatch
        
        // Cách 1: waitFor + !exists
        let gone = NSPredicate(format: "exists == false")
        let exp = XCTNSPredicateExpectation(predicate: gone, object: spinner)
        wait(for: [exp], timeout: 15)
        
        // Cách 2: simple polling
        let deadline = Date().addingTimeInterval(15)
        while spinner.exists && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.5)
        }
        XCTAssertFalse(spinner.exists)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  6. WAIT HELPERS — XỬ LÝ ASYNC UI                        ║
// ╚══════════════════════════════════════════════════════════╝

// UI test PHẢI chờ async operations: API calls, animations, transitions.
// Không chờ đủ → test flaky. Chờ quá lâu → test chậm.

extension XCUIElement {
    
    /// Chờ element xuất hiện rồi tap
    @discardableResult
    func waitAndTap(timeout: TimeInterval = 5) -> Bool {
        guard waitForExistence(timeout: timeout) else { return false }
        tap()
        return true
    }
    
    /// Chờ element xuất hiện, clear, rồi type text
    func clearAndType(_ text: String, timeout: TimeInterval = 5) {
        guard waitForExistence(timeout: timeout) else {
            XCTFail("Element not found: \(self)")
            return
        }
        
        tap()
        
        // Select all existing text
        if let currentValue = value as? String, !currentValue.isEmpty {
            tap() // Ensure focus
            press(forDuration: 1.2)
            if XCUIApplication().menuItems["Select All"].waitForExistence(timeout: 2) {
                XCUIApplication().menuItems["Select All"].tap()
            }
        }
        
        typeText(text)
    }
    
    /// Chờ element BIẾN MẤT
    func waitForDisappearance(timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Chờ element có value cụ thể
    func waitForValue(_ value: String, timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "value == %@", value)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Chờ element enabled
    func waitUntilEnabled(timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Scroll đến element trong scrollable container
    func scrollToElement(in scrollView: XCUIElement, maxSwipes: Int = 10) {
        var swipeCount = 0
        while !isHittable && swipeCount < maxSwipes {
            scrollView.swipeUp()
            swipeCount += 1
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  7. PAGE OBJECT PATTERN — CẤU TRÚC TEST SCALABLE         ║
// ╚══════════════════════════════════════════════════════════╝

// Page Object: mỗi SCREEN = 1 class chứa elements + actions.
// Tests gọi page methods thay vì query elements trực tiếp.
// → DRY: element query 1 chỗ, nhiều tests dùng lại.
// → Maintainable: UI thay đổi → sửa 1 Page Object, không sửa tests.

// === Login Page ===

struct LoginPage {
    let app: XCUIApplication
    
    // ─── Elements ───
    var emailField: XCUIElement {
        app.textFields["login_email_field"]
    }
    
    var passwordField: XCUIElement {
        app.secureTextFields["login_password_field"]
    }
    
    var loginButton: XCUIElement {
        app.buttons["login_submit_button"]
    }
    
    var errorMessage: XCUIElement {
        app.staticTexts["login_error_message"]
    }
    
    var forgotPasswordLink: XCUIElement {
        app.buttons["forgot_password_link"]
    }
    
    var signUpLink: XCUIElement {
        app.buttons["sign_up_link"]
    }
    
    // ─── Assertions ───
    var isDisplayed: Bool {
        emailField.waitForExistence(timeout: 5)
    }
    
    // ─── Actions ───
    @discardableResult
    func login(email: String, password: String) -> HomePage {
        emailField.clearAndType(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
        return HomePage(app: app)
    }
    
    @discardableResult
    func loginExpectingError(email: String, password: String) -> LoginPage {
        emailField.clearAndType(email)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
        return self
    }
    
    func tapForgotPassword() -> ForgotPasswordPage {
        forgotPasswordLink.tap()
        return ForgotPasswordPage(app: app)
    }
    
    func tapSignUp() -> SignUpPage {
        signUpLink.tap()
        return SignUpPage(app: app)
    }
}

// === Home Page ===

struct HomePage {
    let app: XCUIApplication
    
    var welcomeLabel: XCUIElement {
        app.staticTexts["home_welcome_label"]
    }
    
    var profileButton: XCUIElement {
        app.buttons["home_profile_button"]
    }
    
    var itemsList: XCUIElement {
        app.tables["home_items_list"]
    }
    
    var isDisplayed: Bool {
        welcomeLabel.waitForExistence(timeout: 10)
    }
    
    func itemCell(at index: Int) -> XCUIElement {
        itemsList.cells.element(boundBy: index)
    }
    
    func itemCell(id: String) -> XCUIElement {
        itemsList.cells["item_\(id)"]
    }
    
    var itemCount: Int {
        itemsList.cells.count
    }
    
    func tapItem(at index: Int) -> ItemDetailPage {
        itemCell(at: index).tap()
        return ItemDetailPage(app: app)
    }
    
    func deleteItem(at index: Int) {
        let cell = itemCell(at: index)
        cell.swipeLeft()
        cell.buttons["Xoá"].tap()
    }
    
    func pullToRefresh() {
        let start = itemsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = itemsList.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.1, thenDragTo: end)
    }
    
    func tapProfile() -> ProfilePage {
        profileButton.tap()
        return ProfilePage(app: app)
    }
}

// Placeholder pages
struct ForgotPasswordPage { let app: XCUIApplication }
struct SignUpPage { let app: XCUIApplication }
struct ItemDetailPage {
    let app: XCUIApplication
    var isDisplayed: Bool { app.navigationBars.firstMatch.waitForExistence(timeout: 5) }
}
struct ProfilePage {
    let app: XCUIApplication
    var logoutButton: XCUIElement { app.buttons["logout_button"] }
    
    @discardableResult
    func logout() -> LoginPage {
        logoutButton.tap()
        // Confirm alert
        app.alerts.firstMatch.buttons["Đăng xuất"].tap()
        return LoginPage(app: app)
    }
}


// === Tests SỬ DỤNG Page Objects ===

final class LoginFlowTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--logged-out"]
        app.launch()
    }
    
    func testSuccessfulLogin() throws {
        let loginPage = LoginPage(app: app)
        XCTAssertTrue(loginPage.isDisplayed)
        
        // Fluent API: login trả về HomePage
        let homePage = loginPage.login(
            email: "huy@example.com",
            password: "password123"
        )
        
        // Assert home page hiện
        XCTAssertTrue(homePage.isDisplayed)
        XCTAssertEqual(homePage.welcomeLabel.label, "Xin chào, Huy!")
    }
    
    func testLoginWithInvalidCredentials() throws {
        let loginPage = LoginPage(app: app)
        
        let _ = loginPage.loginExpectingError(
            email: "wrong@email.com",
            password: "wrongpassword"
        )
        
        // Assert error
        XCTAssertTrue(loginPage.errorMessage.waitForExistence(timeout: 5))
    }
    
    func testLoginThenLogout() throws {
        let loginPage = LoginPage(app: app)
        
        let homePage = loginPage.login(
            email: "huy@example.com",
            password: "password123"
        )
        XCTAssertTrue(homePage.isDisplayed)
        
        let profilePage = homePage.tapProfile()
        let backToLogin = profilePage.logout()
        
        XCTAssertTrue(backToLogin.isDisplayed)
    }
    
    func testDeleteItem() throws {
        let loginPage = LoginPage(app: app)
        let homePage = loginPage.login(email: "huy@example.com", password: "pass")
        XCTAssertTrue(homePage.isDisplayed)
        
        let initialCount = homePage.itemCount
        homePage.deleteItem(at: 0)
        
        // Wait for deletion animation
        Thread.sleep(forTimeInterval: 1)
        
        XCTAssertEqual(homePage.itemCount, initialCount - 1)
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  8. SCREENSHOTS & ATTACHMENTS                             ║
// ╚══════════════════════════════════════════════════════════╝

final class ScreenshotTests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testCaptureScreenshots() throws {
        // === Manual screenshot ===
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Home Screen"
        attachment.lifetime = .keepAlways // Giữ lại sau khi test pass
        // .deleteOnSuccess: xoá nếu test pass (default)
        add(attachment)
        
        // Navigate và chụp tiếp
        app.buttons["profile_link"].tap()
        
        let profileScreenshot = app.screenshot()
        let profileAttachment = XCTAttachment(screenshot: profileScreenshot)
        profileAttachment.name = "Profile Screen"
        profileAttachment.lifetime = .keepAlways
        add(profileAttachment)
        
        // Screenshots lưu trong Test Report (Xcode > Report Navigator)
    }
    
    // === Auto screenshots mỗi step ===
    func testWithAutoScreenshots() {
        // Bật trong Scheme: Edit Scheme > Test > Options > Screenshots
        // "Gather coverage" + "Screenshots" checkbox
        
        // Mỗi UI interaction Xcode TỰ ĐỘNG chụp screenshot
        // Xem trong: Report Navigator > Test > từng step có ảnh
        
        app.buttons["login_button"].tap()
        // ↑ Xcode tự chụp trước và sau tap
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  9. LAUNCH PERFORMANCE TEST                               ║
// ╚══════════════════════════════════════════════════════════╝

final class PerformanceUITests: XCTestCase {
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
        // Xcode chạy NHIỀU LẦN, tính trung bình thời gian launch
        // Kết quả trong Performance Result → baseline comparison
        // CI/CD: fail nếu launch time tăng quá threshold
    }
    
    func testScrollPerformance() throws {
        let app = XCUIApplication()
        app.launch()
        
        let table = app.tables.firstMatch
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            table.swipeUp(velocity: .fast)
        }
    }
}


// ╔══════════════════════════════════════════════════════════╗
// ║  10. MOCK SERVER & TEST DATA                              ║
// ╚══════════════════════════════════════════════════════════╝

// XCUITest chạy KHÁC PROCESS với app → không inject mock trực tiếp.
// Cách truyền test configuration:

// === 10a. Launch Arguments ===
// Test:
//   app.launchArguments = ["--uitesting", "--mock-api"]
//
// App code:
//   if ProcessInfo.processInfo.arguments.contains("--mock-api") {
//       APIClient.shared = MockAPIClient()
//   }

// === 10b. Launch Environment ===
// Test:
//   app.launchEnvironment["TEST_SCENARIO"] = "empty_state"
//
// App code:
//   switch ProcessInfo.processInfo.environment["TEST_SCENARIO"] {
//   case "empty_state": loadEmptyState()
//   case "error_state": loadErrorState()
//   default: loadNormally()
//   }

// === 10c. Local Mock Server ===
// Chạy mock server trước khi test:
// - Trong setUpWithError: start local server
// - App trỏ API_BASE_URL về localhost
// - tearDown: stop server

// === 10d. Test data setup qua deeplink ===
// Test:
//   app.launchArguments = ["--reset-database"]
//   app.launchEnvironment["SEED_DATA"] = "5_items"
//
// App code:
//   if arguments.contains("--reset-database") {
//       DatabaseManager.shared.reset()
//       if let seed = environment["SEED_DATA"] {
//           DatabaseManager.shared.seed(scenario: seed)
//       }
//   }


// ╔══════════════════════════════════════════════════════════╗
// ║  11. CI/CD INTEGRATION                                    ║
// ╚══════════════════════════════════════════════════════════╝

// === 11a. Chạy tests bằng xcodebuild ===

// # Chạy tất cả UI tests
// xcodebuild test \
//   -scheme "MyApp" \
//   -destination "platform=iOS Simulator,name=iPhone 16,OS=18.0" \
//   -testPlan "UITests" \
//   -resultBundlePath "./test-results" \
//   -parallel-testing-enabled YES

// # Chạy test cụ thể
// xcodebuild test \
//   -scheme "MyApp" \
//   -destination "..." \
//   -only-testing "MyAppUITests/LoginFlowTests/testSuccessfulLogin"

// === 11b. GitHub Actions example ===
//
// name: UI Tests
// on: [push, pull_request]
// jobs:
//   ui-tests:
//     runs-on: macos-15
//     steps:
//       - uses: actions/checkout@v4
//       - name: Run UI Tests
//         run: |
//           xcodebuild test \
//             -scheme "MyApp" \
//             -destination "platform=iOS Simulator,name=iPhone 16" \
//             -resultBundlePath "./results" \
//             | xcpretty
//       - name: Upload Results
//         if: failure()
//         uses: actions/upload-artifact@v4
//         with:
//           name: test-results
//           path: ./results


// ╔══════════════════════════════════════════════════════════╗
// ║  12. COMMON PITFALLS & BEST PRACTICES                    ║
// ╚══════════════════════════════════════════════════════════╝

// ❌ PITFALL 1: Test FLAKY vì timing
//    app.buttons["submit"].tap()
//    XCTAssertTrue(app.staticTexts["success"].exists) // FAIL: chưa kịp hiện!
//    ✅ FIX: LUÔN dùng waitForExistence(timeout:)
//            XCTAssertTrue(app.staticTexts["success"].waitForExistence(timeout: 10))

// ❌ PITFALL 2: Hardcode text thay vì identifier
//    app.buttons["Đăng nhập"]  // Sai khi đổi ngôn ngữ!
//    ✅ FIX: app.buttons["login_button"] (accessibility identifier)
//            Identifier KHÔNG thay đổi theo localization

// ❌ PITFALL 3: Test phụ thuộc vào thứ tự chạy
//    testA tạo data → testB dựa vào data đó
//    → testB fail nếu chạy riêng
//    ✅ FIX: Mỗi test SELF-CONTAINED — setUp reset state hoàn toàn

// ❌ PITFALL 4: Animation làm test chậm
//    Wait 0.3s animation mỗi transition × 100 tests = 30s wasted
//    ✅ FIX: UIView.setAnimationsEnabled(false) qua launch argument
//            app.launchArguments.append("--disable-animations")

// ❌ PITFALL 5: Keyboard che element
//    Field ở dưới → keyboard mở → che nút Submit
//    ✅ FIX: app.keyboards.buttons["return"].tap() dismiss keyboard trước
//            Hoặc scroll đến element trước khi tap

// ❌ PITFALL 6: System alerts (permissions)
//    "Allow Notifications?" alert → test stuck
//    ✅ FIX:
//    addUIInterruptionMonitor(withDescription: "Permission") { alert in
//        alert.buttons["Allow"].tap()
//        return true
//    }
//    app.tap() // Trigger monitor

// ❌ PITFALL 7: .exists vs .isHittable
//    element.exists = true nhưng bị scroll ngoài viewport
//    → .tap() fail vì element không visible
//    ✅ FIX: Check .isHittable trước khi tap
//            Hoặc scroll đến element trước

// ❌ PITFALL 8: Test quá nhiều trong 1 test method
//    testEverything() { login; create; edit; delete; logout }
//    → 1 step fail → không biết step nào
//    ✅ FIX: Mỗi test method test 1 FLOW cụ thể
//            Reuse common steps qua Page Object methods

// ✅ BEST PRACTICES:
// 1. .accessibilityIdentifier cho MỌI testable element
// 2. Page Object Pattern: 1 screen = 1 struct
// 3. waitForExistence THAY VÌ sleep/exists
// 4. Launch arguments/environment cho test configuration
// 5. Mỗi test SELF-CONTAINED: setUp reset, tearDown cleanup
// 6. Disable animations cho speed
// 7. Screenshot attachments cho debug failed tests
// 8. addUIInterruptionMonitor cho system alerts
// 9. Helper extensions: clearAndType, waitAndTap, scrollToElement
// 10. CI/CD: parallel testing, result bundles, artifact upload
// 11. Test CRITICAL FLOWS: login, purchase, onboarding, core feature
// 12. Naming: test[Feature]_[Scenario]_[ExpectedResult]
//     testLogin_WithValidCredentials_ShowsHomePage
//     testLogin_WithWrongPassword_ShowsError
```

---

XCUITest là framework UI testing native của Apple — test từ góc nhìn user thật sự, tương tác với app đang chạy. Mình sẽ giải thích toàn bộ từ setup, element queries, interactions đến Page Object pattern và CI/CD integration.Mình đã tổng hợp toàn bộ kiến thức XCUITest trong 12 phần. Đây là những điểm cốt lõi:

**XCUITest hoạt động như user thật** — test app đang chạy trên Simulator/Device, tương tác qua tap/swipe/type, kiểm tra UI elements hiển thị đúng. Điểm quan trọng: test và app chạy **khác process** (IPC) → test không access internal code → đây là **black-box testing**.

**Năm phần giá trị nhất cho production:**

**Phần 2 — Accessibility Identifiers**: Đây là **cầu nối duy nhất** giữa test code và app code. Mọi testable element **phải có** `.accessibilityIdentifier("unique_id")`. Rule: identifier cho testing (user không thấy), label cho VoiceOver (user nghe). Naming convention `screen_element_purpose` (ví dụ `login_email_field`) giúp maintain khi app scale.

**Phần 6 — Wait Helpers**: Nguồn **flaky tests** số 1 là timing — UI chưa kịp render mà test đã assert. `waitForExistence(timeout:)` là method quan trọng nhất, **luôn dùng thay `.exists`** cho async UI. Extensions `waitAndTap()`, `clearAndType()`, `waitForDisappearance()`, `scrollToElement()` là toolkit chuẩn mà mọi project cần.

**Phần 7 — Page Object Pattern**: Mỗi screen = 1 struct chứa elements + actions. Tests gọi `loginPage.login(email:password:)` thay vì query elements trực tiếp. UI thay đổi → sửa **1 Page Object**, không sửa 20 test methods. Fluent API: `loginPage.login(...) → homePage.tapProfile() → profilePage.logout()` — đọc test như đọc user story.

**Phần 10 — Mock Server & Test Data**: Vì test/app khác process, không inject mock trực tiếp. Dùng `launchArguments` (`--mock-api`, `--reset-database`) và `launchEnvironment` (`TEST_SCENARIO: "empty_state"`) — app đọc flags trong `ProcessInfo` để switch sang mock services. Pattern này cho phép test mọi scenario: empty state, error state, large dataset.

**Phần 12 — Pitfall #6: System Alerts**: Permission dialogs ("Allow Notifications?") block test hoàn toàn. Fix bằng `addUIInterruptionMonitor(withDescription:)` auto-handle alerts. Phải gọi `app.tap()` sau register monitor để trigger nó.

**Test naming convention** giúp đọc test results: `test[Feature]_[Scenario]_[ExpectedResult]` — ví dụ `testLogin_WithWrongPassword_ShowsError`. Khi CI fail, nhìn tên test biết ngay feature nào, scenario nào, expect gì.

Huy muốn mình đi tiếp sang chủ đề nào khác không?
