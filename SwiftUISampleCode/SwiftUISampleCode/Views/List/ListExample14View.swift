//
//  ListExample14View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct ListExample14View: View {
    var body: some View {
        Group {
            SettingsScreen()
            
            ChatListDemo()
        }
    }
}

struct SettingsScreen: View {
    @AppStorage("notifications") private var notifications = true
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("fontSize") private var fontSize = 16.0
    
    var body: some View {
        List {
            // Profile section
            Section {
                NavigationLink {
                    Text("Profile Detail")
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(.blue.gradient)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text("H").font(.title2.bold()).foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Huy Nguyen").font(.headline)
                            Text("huy@example.com")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Toggles section
            Section("Cài đặt chung") {
                SettingToggleRow(icon: "bell.fill", color: .red,
                               title: "Thông báo", isOn: $notifications)
                SettingToggleRow(icon: "moon.fill", color: .indigo,
                               title: "Dark Mode", isOn: $darkMode)
            }
            
            // Slider section
            Section("Hiển thị") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        SettingIcon(icon: "textformat.size", color: .blue)
                        Text("Cỡ chữ")
                        Spacer()
                        Text("\(Int(fontSize))pt")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $fontSize, in: 12...28, step: 1)
                }
            }
            
            // Navigation rows
            Section("Khác") {
                SettingNavRow(icon: "questionmark.circle", color: .purple,
                            title: "Trợ giúp", detail: nil)
                SettingNavRow(icon: "info.circle", color: .gray,
                            title: "Phiên bản", detail: "2.1.0")
            }
            
            // Destructive section
            Section {
                Button("Đăng xuất", role: .destructive) { }
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Cài đặt")
    }
}

struct SettingToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 14) {
                SettingIcon(icon: icon, color: color)
                Text(title)
            }
        }
    }
}

struct SettingNavRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String?
    
    var body: some View {
        NavigationLink {
            Text(title)
        } label: {
            HStack(spacing: 14) {
                SettingIcon(icon: icon, color: color)
                Text(title)
                if let detail {
                    Spacer()
                    Text(detail)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color, in: .rect(cornerRadius: 6))
    }
}

// === 14b. Chat / Messages List ===

struct Message: Identifiable {
    let id = UUID()
    let sender: String
    let text: String
    let time: Date
    let isMe: Bool
}

struct ChatListDemo: View {
    let messages: [Message] = [
        Message(sender: "Huy", text: "Hello!", time: .now.addingTimeInterval(-300), isMe: false),
        Message(sender: "Me", text: "Hi Huy! Khỏe không?", time: .now.addingTimeInterval(-240), isMe: true),
        Message(sender: "Huy", text: "Khỏe, đang code SwiftUI", time: .now.addingTimeInterval(-180), isMe: false),
        Message(sender: "Me", text: "Nice! Mình cũng đang học", time: .now.addingTimeInterval(-60), isMe: true),
    ]
    
    var body: some View {
        List(messages) { msg in
            HStack {
                if msg.isMe { Spacer(minLength: 60) }
                
                VStack(alignment: msg.isMe ? .trailing : .leading, spacing: 4) {
                    Text(msg.text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            msg.isMe ? Color.blue : Color.gray.opacity(0.2),
                            in: .rect(cornerRadius: 16)
                        )
                        .foregroundStyle(msg.isMe ? .white : .primary)
                    
                    Text(msg.time, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                if !msg.isMe { Spacer(minLength: 60) }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }
}
