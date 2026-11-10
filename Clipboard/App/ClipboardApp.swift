import SwiftUI
import SwiftData

@main struct ClipboardApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .modelContainer(for: [Garment.self, GarmentPhoto.self, ThriftSession.self, Candidate.self, Expense.self])
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            InventoryView().tabItem { Label("Inventory", systemImage: "square.grid.2x2") }
            SessionsView().tabItem { Label("Thrifting", systemImage: "bag") }
            FinanceView().tabItem { Label("Finance", systemImage: "chart.bar") }
            SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
        }.tint(.red)
    }
}
