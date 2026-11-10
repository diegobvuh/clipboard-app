import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ThriftSession.date, order: .reverse) private var sessions: [ThriftSession]
    @State private var selected: ThriftSession?
    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView { Label("Take Clipboard thrifting", systemImage: "bag") } description: { Text("Start a session to keep track of pieces and prices while you shop.") } actions: { Button("Start a session", action: add).buttonStyle(.borderedProminent) }
                } else {
                    List {
                        ForEach(sessions) { session in
                            NavigationLink { SessionDetailView(session: session) } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(session.name).font(.headline)
                                    Text("\(session.date.formatted(date: .abbreviated, time: .omitted)) · \(session.candidates.count) pieces · \(session.isComplete ? "Finished" : "In progress")").font(.subheadline).foregroundStyle(.secondary)
                                }.padding(.vertical, 4)
                            }
                        }.onDelete { indices in for index in indices { context.delete(sessions[index]) } }
                    }
                }
            }.navigationTitle("Thrifting")
                .toolbar { Button(action: add) { Image(systemName: "plus") }.accessibilityLabel("Start a session") }
                .navigationDestination(item: $selected) { SessionDetailView(session: $0) }
        }
    }
    private func add() { let session = ThriftSession(name: "Thrift trip"); context.insert(session); selected = session }
}

struct SessionDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var session: ThriftSession
    @State private var selected: Candidate?
    @State private var receipt = ""
    @State private var showingCheckout = false
    var active: [Candidate] { session.candidates.filter { $0.decision != "Discarded" } }
    var cartTotal: Decimal { active.compactMap(\.price).reduce(0, +) }
    var body: some View {
        Form {
            Section("Trip") {
                TextField("Session name", text: $session.name)
                LabeledContent("Estimated cart", value: Money.format(cartTotal))
                Text("\(active.filter { $0.price == nil }.count) pieces without a price. Tax and discounts are not included.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Pieces") {
                ForEach(session.candidates.sorted { $0.name < $1.name }) { candidate in
                    NavigationLink { CandidateDetailView(candidate: candidate) } label: {
                        HStack {
                            PhotoThumbnail(data: candidate.image)
                            VStack(alignment: .leading) { Text(candidate.name.isEmpty ? "Untitled piece" : candidate.name); Text(candidate.decision).font(.caption).foregroundStyle(.secondary) }
                            Spacer(); Text(Money.format(candidate.price)).font(.subheadline)
                        }
                    }
                }
                if !session.isComplete { Button { let item = Candidate(name: ""); item.session = session; context.insert(item); selected = item } label: { Label("Add a piece", systemImage: "plus") } }
            }
            Section("Receipt") {
                if let data = session.receiptImage { PhotoThumbnail(data: data) }
                PhotoInput { session.receiptImage = $0 }
                TextField("Receipt total", text: $receipt).keyboardType(.decimalPad).onChange(of: receipt) { _, value in if value.isEmpty { session.receiptTotal = nil } else if let amount = Money.parse(value) { session.receiptTotal = amount } }
                if !receipt.isEmpty && Money.parse(receipt) == nil { Text("Enter a nonnegative amount.").font(.caption).foregroundStyle(.red) }
                Text("Receipts are kept for the trip. Item prices are entered separately.").font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                TextField("Trip notes", text: $session.notes, axis: .vertical)
                if !session.isComplete { Button("Finish session") { showingCheckout = true } }
                else { Text("Finished").foregroundStyle(.secondary) }
            }
        }.navigationTitle(session.name).navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selected) { CandidateDetailView(candidate: $0) }
            .onAppear { receipt = session.receiptTotal.map { NSDecimalNumber(decimal: $0).stringValue } ?? "" }
            .confirmationDialog("Finish this session?", isPresented: $showingCheckout, titleVisibility: .visible) {
                Button("Add purchased pieces to inventory") { finish() }
            } message: { Text("Only pieces marked Purchased will be added. Discarded and undecided pieces remain in the session.") }
    }
    private func finish() {
        guard !session.isComplete else { return }
        for candidate in session.candidates where candidate.decision == "Purchased" {
            let garment = Garment(name: candidate.name); garment.purchaseCost = candidate.price; context.insert(garment)
            for data in [candidate.image, candidate.tagImage].compactMap({ $0 }) {
                let photo = GarmentPhoto(data: data, order: garment.photos.count); photo.isPublic = garment.photos.isEmpty; photo.role = garment.photos.isEmpty ? "Listing" : "Tag"; photo.garment = garment; context.insert(photo)
            }
        }
        session.isComplete = true
    }
}

struct CandidateDetailView: View {
    @Bindable var candidate: Candidate
    @State private var amount = ""
    var body: some View {
        Form {
            Section("Piece") {
                TextField("Name or notes", text: $candidate.name)
                TextField("Tag price", text: $amount).keyboardType(.decimalPad).onChange(of: amount) { _, value in if value.isEmpty { candidate.price = nil } else if let price = Money.parse(value) { candidate.price = price } }
                if !amount.isEmpty && Money.parse(amount) == nil { Text("Enter a nonnegative amount.").font(.caption).foregroundStyle(.red) }
                Picker("Decision", selection: $candidate.decision) { Text("Considering").tag("Considering"); Text("Purchased").tag("Purchased"); Text("Discarded").tag("Discarded") }
            }
            Section("Garment photo") { if let data = candidate.image { PhotoThumbnail(data: data) }; PhotoInput { candidate.image = $0 } }
            Section("Price tag") { if let data = candidate.tagImage { PhotoThumbnail(data: data) }; PhotoInput { candidate.tagImage = $0 } }
            Text("Enter the price from the tag. Automatic tag reading is not connected yet.").font(.footnote).foregroundStyle(.secondary)
        }.navigationTitle(candidate.name.isEmpty ? "New piece" : candidate.name).navigationBarTitleDisplayMode(.inline)
            .onAppear { amount = candidate.price.map { NSDecimalNumber(decimal: $0).stringValue } ?? "" }
    }
}
