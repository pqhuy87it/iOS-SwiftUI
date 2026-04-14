//
//  EditableListDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/14.
//

import SwiftUI

struct EditableListDemo: View {
    @State private var tasks = [
        Task1(title: "Mua sữa", isCompleted: false),
        Task1(title: "Code review", isCompleted: true),
    ]
    
    var body: some View {
        List($tasks) { $task in
            // $tasks → ForEach cung cấp Binding<Task> cho mỗi row
            Toggle(task.title, isOn: $task.isCompleted)
        }
    }
}
