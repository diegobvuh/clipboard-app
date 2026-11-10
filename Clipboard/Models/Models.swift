import Foundation
import SwiftData

@Model final class Garment {
    var id: UUID = UUID()
    var name: String = ""
    var brand: String = ""
    var size: String = ""
    var category: String = ""
    var conditionNotes: String = ""
    var descriptionText: String = ""
    var purchaseCost: Decimal?
    var askingPrice: Decimal?
    var salePrice: Decimal?
    var saleFees: Decimal?
    var saleShipping: Decimal?
    var status: String = "Draft"
    var createdAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \GarmentPhoto.garment) var photos: [GarmentPhoto] = []
    init(name: String = "") { self.name = name }
}

@Model final class GarmentPhoto {
    var id: UUID = UUID()
    @Attribute(.externalStorage) var data: Data = Data()
    var isPublic: Bool = true
    var role: String = "Listing"
    var order: Int = 0
    var garment: Garment?
    init(data: Data, order: Int) { self.data = data; self.order = order }
}

@Model final class ThriftSession {
    var id: UUID = UUID()
    var name: String = ""
    var date: Date = Date()
    var receiptTotal: Decimal?
    @Attribute(.externalStorage) var receiptImage: Data?
    var notes: String = ""
    var isComplete: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \Candidate.session) var candidates: [Candidate] = []
    init(name: String) { self.name = name }
}

@Model final class Candidate {
    var id: UUID = UUID()
    var name: String = ""
    var price: Decimal?
    var decision: String = "Considering"
    @Attribute(.externalStorage) var image: Data?
    @Attribute(.externalStorage) var tagImage: Data?
    var session: ThriftSession?
    init(name: String) { self.name = name }
}

@Model final class Expense {
    var id: UUID = UUID()
    var title: String = ""
    var amount: Decimal = 0
    var date: Date = Date()
    init(title: String, amount: Decimal) { self.title = title; self.amount = amount }
}

enum Money {
    static func parse(_ value: String) -> Decimal? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.range(of: #"^[0-9]+([.][0-9]{1,2})?$"#, options: .regularExpression) != nil, let amount = Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX")), amount >= 0 else { return nil }
        return amount
    }
    static func format(_ value: Decimal?) -> String {
        guard let value else { return "Not recorded" }
        return value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}

enum FinanceCalculator {
    static func itemProfit(sale: Decimal?, cost: Decimal?, fees: Decimal?, shipping: Decimal?) -> Decimal? {
        guard let sale, let cost, let fees, let shipping else { return nil }
        return sale - cost - fees - shipping
    }
}
