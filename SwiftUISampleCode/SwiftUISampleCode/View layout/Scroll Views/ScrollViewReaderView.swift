import SwiftUI

struct ScrollViewReaderView: View {
    let itemCount = 100
    
    // Biến lưu trữ ID mục mà người dùng muốn cuộn tới (dành cho ô nhập liệu)
    @State private var targetIndex: String = ""
    
    var body: some View {
        // Bọc toàn bộ giao diện (bao gồm cả ScrollView và các nút bấm) bằng ScrollViewReader
        ScrollViewReader { proxy in
            VStack(spacing: 15) {
                
                // --- THANH ĐIỀU KHIỂN ---
                VStack(spacing: 10) {
                    HStack {
                        Button("Lên đầu (0)") {
                            // Sử dụng withAnimation để cuộn mượt mà thay vì giật cục
                            withAnimation {
                                proxy.scrollTo(0, anchor: .top)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                        
                        Button("Giữa (50)") {
                            withAnimation {
                                proxy.scrollTo(50, anchor: .center)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        
                        Spacer()
                        
                        Button("Cuối (99)") {
                            withAnimation {
                                proxy.scrollTo(itemCount - 1, anchor: .bottom)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    
                    // Ô nhập liệu để nhảy đến mục bất kỳ
                    HStack {
                        TextField("Nhập số (0-99)", text: $targetIndex)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                        
                        Button("Đi tới") {
                            if let index = Int(targetIndex), index >= 0, index < itemCount {
                                withAnimation {
                                    proxy.scrollTo(index, anchor: .top)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // --- NỘI DUNG CUỘN ---
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(0..<itemCount, id: \.self) { index in
                            HStack {
                                Text("Mục số \(index)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            // ĐIỂM QUAN TRỌNG NHẤT: Bắt buộc phải gắn .id() để proxy nhận diện được
                            .id(index)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("ScrollViewReader")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollViewReaderView()
}
