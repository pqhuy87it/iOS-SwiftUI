//
//  ToastModifier.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let icon: String
    let style: ToastStyle
    
    enum ToastStyle {
        case success, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return .blue
            }
        }
    }
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if isPresented {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundStyle(style.color)
                    Text(message)
                        .font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: .capsule)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut) { isPresented = false }
                    }
                }
            }
        }
        .animation(.spring(duration: 0.4), value: isPresented)
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String,
               icon: String = "checkmark.circle.fill",
               style: ToastModifier.ToastStyle = .success) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message,
                               icon: icon, style: style))
    }
}
