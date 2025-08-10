import SwiftUI

@main
struct AUDNPRApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 12) {
                Text("AUD → NPR Widget")
                    .font(.title2).bold()
                Text("Add the widget from your Home Screen.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Link("Open XE Converter",
                     destination: URL(string: "https://www.xe.com/currencyconverter/convert/?Amount=1&From=AUD&To=NPR")!)
                    .padding(.top, 8)
            }
            .padding()
        }
    }
}
