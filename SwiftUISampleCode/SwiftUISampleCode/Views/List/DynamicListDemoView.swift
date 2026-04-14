//
//  DynamicListDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct Task1: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct DynamicListDemo: View {
    @State private var tasks = [
        Task1(title: "Mua sữa", isCompleted: false),
        Task1(title: "Code review", isCompleted: true),
        Task1(title: "Tập gym", isCompleted: false),
    ]
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                Text(task.title)
            }
        }
    }
}
