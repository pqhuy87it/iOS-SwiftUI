//
//  FormattingDemoView.swift
//  SwiftUISampleCode
//
//  Created by huy on 2026/04/12.
//

import SwiftUI

struct FormattingDemo: View {
    let now = Date.now
    let price = 1_599_000.0
    let ratio = 0.156
    let bigNumber = 1_234_567
    let weight = Measurement(value: 68.5, unit: UnitMass.kilograms)
    let temp = Measurement(value: 32, unit: UnitTemperature.celsius)
    let bytes = Measurement(value: 2.5, unit: UnitInformationStorage.gigabytes)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // === 8a. Date styles ===
            Section("Date") {
                Text(now, format: .dateTime)
                // "Apr 11, 2026 at 2:30 PM"
                
                Text(now, format: .dateTime.day().month(.wide).year())
                // "April 11, 2026"
                
                Text(now, format: .dateTime.weekday(.wide))
                // "Saturday"
                
                Text(now, format: .dateTime.hour().minute())
                // "2:30 PM"
            }
            
            Divider()
            
            // === 8b. Number formats ===
            Section("Numbers") {
                Text(price, format: .currency(code: "VND"))
                // "₫1,599,000"
                
                Text(price, format: .currency(code: "USD"))
                // "$1,599,000.00"
                
                Text(ratio, format: .percent.precision(.fractionLength(1)))
                // "15.6%"
                
                Text(bigNumber, format: .number.grouping(.automatic))
                // "1,234,567"
                
                Text(bigNumber, format: .number.notation(.compactName))
                // "1.2M"
            }
            
            Divider()
            
            // === 8c. Measurement formats ===
            Section("Measurements") {
                Text(weight, format: .measurement(width: .abbreviated))
                // "68.5 kg"
                
                Text(temp, format: .measurement(width: .narrow))
                // "32°C"
                
                Text(bytes, format: .byteCount(style: .file))
                // "2.5 GB"
            }
            
            Divider()
            
            // === 8d. Relative date (live updating) ===
            Section("Live") {
                Text(now.addingTimeInterval(-120), style: .relative)
                // "2 minutes ago" (tự cập nhật!)
                
                Text(now.addingTimeInterval(3600), style: .timer)
                // Countdown live
            }
        }
        .padding()
    }
    
    func Section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(.blue)
            content()
        }
    }
}

#Preview {
    FormattingDemo()
}
