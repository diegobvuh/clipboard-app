import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Garment.createdAt, order: .reverse) private var garments: [Garment]
    @State private var search = ""
    @State private var selected: Garment?
    var filtered: [Garment] { search.isEmpty ? garments : garments.filter { "\($0.name) \($0.brand) \($0.size)".localizedCaseInsensitiveContains(search) } }
    var body: some View {
        NavigationStack {
            Group {
                if garments.isEmpty {
                    ContentUnavailableView { Label("Your inventory starts here", systemImage: "tshirt") } description: { Text("Add your first piece, then keep its photos, details and costs together.") } actions: { Button("Add a piece") { add() }.buttonStyle(.borderedProminent) }
                } else {
                    List {
                        Section { Text("\(garments.count) \(garments.count == 1 ? "piece" : "pieces") · \(garments.filter { $0.status == "Draft" }.count) drafts").font(.subheadline).foregroundStyle(.secondary) }
                        Section("Your pieces") {
                            ForEach(filtered) { garment in
                                NavigationLink { GarmentDetailView(garment: garment) } label: {
                                    HStack(spacing: 14) {
                                        PhotoThumbnail(data: garment.photos.sorted { $0.order < $1.order }.first?.data)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(garment.name.isEmpty ? "Untitled piece" : garment.name).font(.headline)
                                            Text([garment.brand, garment.size].filter { !$0.isEmpty }.joined(separator: " · ")).font(.subheadline).foregroundStyle(.secondary)
                                            Text(garment.status).font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if let price = garment.askingPrice { Text(Money.format(price)).font(.subheadline.weight(.semibold)) }
                                    }.padding(.vertical, 3)
                                }
                            }.onDelete { offsets in for index in offsets { context.delete(filtered[index]) } }
                        }
                    }.searchable(text: $search, prompt: "Search pieces")
                }
            }
            .navigationTitle("Inventory")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(action: add) { Image(systemName: "plus") }.accessibilityLabel("Add a piece") } }
            .navigationDestination(item: $selected) { GarmentDetailView(garment: $0) }
        }
    }
    private func add() { let garment = Garment(); context.insert(garment); selected = garment }
}

struct GarmentDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var garment: Garment
    @State private var cost = ""
    @State private var price = ""
    @State private var sale = ""
    @State private var fees = ""
    @State private var shipping = ""
    @State private var showingInfo = false
    var body: some View {
        Form {
            Section {
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        ForEach(garment.photos.sorted { $0.order < $1.order }) { photo in
                            VStack(alignment: .leading) {
                                PhotoThumbnail(data: photo.data)
                                Toggle("Public", isOn: Binding(get: { photo.isPublic }, set: { photo.isPublic = $0 })).labelsHidden().accessibilityLabel("Include photo in listing")
                                Text(photo.isPublic ? "Public" : "Reference").font(.caption2)
                                Picker("Photo type", selection: Binding(get: { photo.role }, set: { photo.role = $0 })) { Text("Listing").tag("Listing"); Text("Tag").tag("Tag"); Text("Flaw").tag("Flaw") }.labelsHidden()
                                Button("Remove", role: .destructive) { context.delete(photo) }.font(.caption)
                            }.frame(width: 95)
                        }
                    }
                }
                ForEach(garment.photos.filter { $0.role == "Tag" }.sorted { $0.order < $1.order }) { photo in RecognizeTextView(data: photo.data).id(photo.data) }
                PhotoInput { data in let photo = GarmentPhoto(data: data, order: (garment.photos.map(\.order).max() ?? -1) + 1); photo.garment = garment; context.insert(photo) }
                Text("Choose public photos for the listing. Keep tags and details as reference when needed.").font(.footnote).foregroundStyle(.secondary)
            } header: { Text("Photos") }
            Section("Details") {
                TextField("Item name", text: $garment.name)
                TextField("Brand", text: $garment.brand)
                TextField("Size", text: $garment.size)
                TextField("Category", text: $garment.category)
                TextField("Condition and flaws", text: $garment.conditionNotes, axis: .vertical).lineLimit(2...5)
            }
            Section("Listing") {
                TextField("Write a description", text: $garment.descriptionText, axis: .vertical).lineLimit(4...10)
                moneyField("Asking price", text: $price, target: \Garment.askingPrice)
                Picker("Status", selection: $garment.status) { Text("Draft").tag("Draft"); Text("Ready for review").tag("Ready for review"); Text("Approved").tag("Approved"); Text("Listed manually").tag("Listed manually"); Text("Sold").tag("Sold") }
                Text("Status is entered by you. Clipboard is not connected to Depop.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Costs and sale") {
                moneyField("Purchase cost", text: $cost, target: \Garment.purchaseCost)
                moneyField("Sale proceeds", text: $sale, target: \Garment.salePrice)
                moneyField("Selling fees", text: $fees, target: \Garment.saleFees)
                moneyField("Shipping cost", text: $shipping, target: \Garment.saleShipping)
                Text("Leave unknown amounts blank. Profit is calculated only when all four amounts are recorded; enter 0 when a cost is zero.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("AI assistance") {
                Text("AI drafts and pricing research are not connected yet. Add your own details and price for now.").foregroundStyle(.secondary)
            }
        }.navigationTitle(garment.name.isEmpty ? "New piece" : garment.name).navigationBarTitleDisplayMode(.inline)
            .onAppear { cost = string(garment.purchaseCost); price = string(garment.askingPrice); sale = string(garment.salePrice); fees = string(garment.saleFees); shipping = string(garment.saleShipping) }
    }
    private func string(_ number: Decimal?) -> String { number.map { NSDecimalNumber(decimal: $0).stringValue } ?? "" }
    private func moneyField(_ title: String, text: Binding<String>, target: ReferenceWritableKeyPath<Garment, Decimal?>) -> some View {
        VStack(alignment: .leading) {
            TextField(title, text: text).keyboardType(.decimalPad)
                .onChange(of: text.wrappedValue) { _, value in if value.trimmingCharacters(in: .whitespaces).isEmpty { garment[keyPath: target] = nil } else if let amount = Money.parse(value) { garment[keyPath: target] = amount } }
            if !text.wrappedValue.isEmpty && Money.parse(text.wrappedValue) == nil { Text("Enter a nonnegative amount.").font(.caption).foregroundStyle(.red) }
        }
    }
}
