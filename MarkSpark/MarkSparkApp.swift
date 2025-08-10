import SwiftUI
import AppKit

@main
struct MarkSparkApp: App {
    var body: some Scene {
        MenuBarExtra("MarkSpark", systemImage: "textformat") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

