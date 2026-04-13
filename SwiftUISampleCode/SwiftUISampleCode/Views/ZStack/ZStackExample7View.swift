//
//  ZStackExample7View.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/13.
//

import SwiftUI

struct ZStackExample7View: View {
    @State var loading = true
    @State var showToast = true
    
    var body: some View {
        List {
            // === 7a. Badge / Notification Indicator ===
            HStack(spacing: 30) {
                BadgeOverlay(count: 3)
                BadgeOverlay(count: 42)
                BadgeOverlay(count: 150)
                BadgeOverlay(count: 0)
            }
            .padding()
            
            // === 7b. Loading Overlay ===
            LoadingOverlay(isLoading: loading) {
                List(0..<10) { i in Text("Row \(i)") }
            }
            .onTapGesture { loading.toggle() }
            
            // === 7c. Image with Gradient Overlay (Hero Card) ===
            HeroCard(
                title: "SwiftUI Deep Dive",
                subtitle: "Khám phá layout system chi tiết",
                category: "iOS Development"
            )
            .padding()
            
            // === 7d. Floating Action Button (FAB) ===
            FABLayout()
            
            // === 7e. Toast / Snackbar ===
            VStack {
                Button("Show Toast") {
                    withAnimation { showToast = true }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toast(isPresented: $showToast, message: "Đã lưu thành công!")
            
            // === 7f. Skeleton / Shimmer Loading ===
            SkeletonCard()
            
            // === 7g. Onboarding / Walkthrough Spotlight ===
            SpotlightOverlay(targetFrame: CGRect(x: 10, y: 10, width: 100, height: 100),
                             message: "Test",
                             onDismiss: {
                print("Test test.")
            })
            
            
        }
    }
}

#Preview {
    ZStackExample7View()
}
