//
//  VStackExample9View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/22.
//

import SwiftUI

struct ArticleCard: View {
    let title: String
    let excerpt: String
    let author: String
    let readTime: String
    let category: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(.gray.opacity(0.15))
                .frame(height: 180)
                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(.gray))
            
            // Content area (spacing chặt hơn)
            VStack(alignment: .leading, spacing: 10) {
                // Category tag
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.blue)
                    .tracking(1)
                
                // Title
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                
                // Excerpt
                Text(excerpt)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                
                // Meta info
                HStack(spacing: 8) {
                    Text(author)
                        .font(.caption.weight(.medium))
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(readTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .background(.background, in: .rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
    }
}

struct ProfileHeader: View {
    let name: String
    let title: String
    let stats: [(String, String)]
    
    var body: some View {
        // Outer: spacing lớn giữa avatar block và stats
        VStack(spacing: 20) {
            // Avatar + Name block: spacing nhỏ
            VStack(spacing: 10) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    )
                
                // Name + title: spacing rất nhỏ
                VStack(spacing: 4) {
                    Text(name)
                        .font(.title2.bold())
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stats bar
            HStack(spacing: 0) {
                ForEach(Array(stats.enumerated()), id: \.offset) { idx, stat in
                    if idx > 0 { Divider().frame(height: 28) }
                    VStack(spacing: 4) {
                        Text(stat.1)
                            .font(.headline)
                        Text(stat.0)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button { } label: {
                    Text("Follow")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.blue, in: .rect(cornerRadius: 10))
                        .foregroundStyle(.white)
                }
                Button { } label: {
                    Text("Message")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.gray.opacity(0.12), in: .rect(cornerRadius: 10))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.bold())
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
            
            Spacer()
            Spacer() // Lệch trên 1/3 thay vì giữa hoàn toàn
        }
    }
}

struct VStackExample9View: View {
    var body: some View {
        // === 9a. Full Screen Layout — Header / Body / Footer ===
        
        VStack(spacing: 0) {
            // HEADER: cố định trên cùng
            HStack {
                Text("Ứng dụng").font(.title3.bold())
                Spacer()
                Image(systemName: "bell.badge")
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // BODY: chiếm toàn bộ còn lại, scrollable
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(0..<30) { i in
                        Text("Content \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.gray.opacity(0.05), in: .rect(cornerRadius: 8))
                    }
                }
                .padding()
            }
            
            Divider()
            
            // FOOTER: cố định dưới cùng
            HStack(spacing: 0) {
                ForEach(["house", "magnifyingglass", "person"], id: \.self) { icon in
                    Button { } label: {
                        Image(systemName: icon)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        
        // === 9b. Onboarding / CTA Screen ===
        
        VStack(spacing: 0) {
            Spacer() // Đẩy content xuống giữa-trên
            
            // Illustration
            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(.blue.gradient)
                .padding(.bottom, 24)
            
            // Title + Description (spacing chặt)
            VStack(spacing: 12) {
                Text("Chào mừng đến với App")
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text("Khám phá những tính năng tuyệt vời giúp bạn làm việc hiệu quả hơn mỗi ngày.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer() // 2 Spacers dưới > 1 Spacer trên → content lệch TRÊN
            
            // CTA Buttons (spacing riêng)
            VStack(spacing: 12) {
                Button { } label: {
                    Text("Bắt đầu ngay")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: .rect(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                
                Button("Đã có tài khoản? Đăng nhập") { }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        
        // === 9c. Card Component ===
        
        ArticleCard(
            title: "SwiftUI Layout System: Hiểu sâu để code nhanh",
            excerpt: "Bài viết giải thích chi tiết cách SwiftUI phân bổ không gian cho views, từ intrinsic size đến layout priority.",
            author: "Huy Nguyen",
            readTime: "5 phút đọc",
            category: "iOS Development"
        )
        .padding()
        
        // === 9d. Profile Header ===
        
        ProfileHeader(
            name: "Huy Nguyen",
            title: "Senior iOS Developer",
            stats: [("Bài viết", "128"), ("Followers", "1.2K"), ("Following", "345")]
        )
        
        // === 9e. Empty State / Error State ===
        
        EmptyStateView(
            icon: "tray",
            title: "Chưa có dữ liệu",
            message: "Bắt đầu bằng cách thêm mục mới vào danh sách của bạn.",
            actionTitle: "Thêm mới"
        ) { }
        
        // === 9f. Bottom Sheet Content ===
        
        VStack(spacing: 0) {
            // Drag indicator
            Capsule()
                .fill(.gray.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            // Title section
            VStack(alignment: .leading, spacing: 4) {
                Text("Chia sẻ").font(.title3.bold())
                Text("Chọn cách chia sẻ nội dung")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            Divider()
            
            // Options
            VStack(spacing: 0) {
                ShareOption(icon: "doc.on.doc", title: "Sao chép liên kết", color: .gray)
                ShareOption(icon: "square.and.arrow.up", title: "Chia sẻ qua...", color: .blue)
                ShareOption(icon: "bookmark", title: "Lưu bài viết", color: .orange)
                ShareOption(icon: "flag", title: "Báo cáo", color: .red)
            }
        }
    }
}

#Preview {
    VStackExample9View()
}
