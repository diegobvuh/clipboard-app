import SwiftUI
import SwiftData

struct FinanceView: View {
    @Environment(\.modelContext) private var context
    @Query private var garments: [Garment]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @State private var adding = false
    var sold: [Garment] { garments.filter { $0.status == "Sold" } }
    var completeSales: [Garment] { sold.filter { FinanceCalculator.itemProfit(sale: $0.salePrice, cost: $0.purchaseCost, fees: $0.saleFees, shipping: $0.saleShipping) != nil } }
    var profit: Decimal { completeSales.reduce(Decimal.zero) { $0 + (FinanceCalculator.itemProfit(sale: $1.salePrice, cost: $1.purchaseCost, fees: $1.saleFees, shipping: $1.saleShipping) ?? 0) } }
    var body: some View {
        NavigationStack {
            List {
                Section("Recorded sales") {
                    LabeledContent("Sold pieces", value: "\(sold.count)")
                    LabeledContent("Item profit", value: Money.format(profit))
                    Text("Based on \(completeSales.count) sold pieces with sale, purchase, fee and shipping amounts recorded. Shared expenses are not included.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Other expenses") {
                    LabeledContent("Recorded expenses", value: Money.format(expenses.reduce(Decimal.zero) { $0 + $1.amount }))
                    ForEach(expenses) { expense in LabeledContent(expense.title, value: Money.format(expense.amount)) }.onDelete { indices in for index in indices { context.delete(expenses[index]) } }
                    Button { adding = true } label: { Label("Add expense", systemImage: "plus") }
                }
                Section { Text("Amounts are entered manually on this device. This is a simple business view, not accounting or tax reporting.").font(.footnote).foregroundStyle(.secondary) }
            }.navigationTitle("Finance").sheet(isPresented: $adding) { AddExpenseView() }
        }
    }
}
struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    var body: some View {
        NavigationStack {
            Form { TextField("Expense name", text: $title); TextField("Amount", text: $amount).keyboardType(.decimalPad) }
                .navigationTitle("Add expense").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { if let value = Money.parse(amount) { context.insert(Expense(title: title.trimmingCharacters(in: .whitespacesAndNewlines), amount: value)); dismiss() } }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Money.parse(amount) == nil) }
                }
        }
    }
}
struct SettingsView: View {
    @AppStorage("measurementPolicy") private var measurementPolicy = "When asked"
    @AppStorage("shopVoice") private var shopVoice = ""
    var body: some View {
        NavigationStack {
            Form {
                Section("Shop preferences") {
                    Picker("Measurements", selection: $measurementPolicy) { Text("When asked").tag("When asked"); Text("Before listing").tag("Before listing") }
                    TextField("Notes about your shop's voice", text: $shopVoice, axis: .vertical)
                    Text("Preferences are stored on this device. They will not influence drafts until an AI service is connected.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Connections") {
                    LabeledContent("Depop", value: "Not connected")
                    LabeledContent("AI assistant", value: "Not connected")
                    LabeledContent("Social accounts", value: "Not connected")
                }
                Section { Text("Clipboard is an independent product and is not affiliated with Depop.").font(.footnote).foregroundStyle(.secondary) }
            }.navigationTitle("Settings")
        }
    }
}
