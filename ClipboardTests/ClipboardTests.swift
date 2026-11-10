import XCTest
import UIKit
@testable import Clipboard

final class ClipboardTests: XCTestCase {
    func testUnknownCostsDoNotProduceProfit() {
        XCTAssertNil(FinanceCalculator.itemProfit(sale: 50, cost: nil, fees: 2, shipping: 4))
        XCTAssertNil(FinanceCalculator.itemProfit(sale: 50, cost: 10, fees: nil, shipping: 4))
    }
    func testProfitIncludesAllRecordedCosts() {
        XCTAssertEqual(FinanceCalculator.itemProfit(sale: 50, cost: 10, fees: 3, shipping: 7), 30)
        XCTAssertEqual(FinanceCalculator.itemProfit(sale: 5, cost: 10, fees: 0, shipping: 0), -5)
    }
    func testRecognizesPrintedTag() async throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 700, height: 200)).image { context in
            UIColor.white.setFill(); context.fill(CGRect(x: 0, y: 0, width: 700, height: 200))
            ("PRICE $19.99" as NSString).draw(at: CGPoint(x: 30, y: 45), withAttributes: [.font: UIFont.systemFont(ofSize: 70), .foregroundColor: UIColor.black])
        }
        let data = try XCTUnwrap(image.pngData())
        let result = try await TextRecognition.recognize(data)
        XCTAssertTrue(result.contains("19.99"), "Recognized: \(result)")
    }
    func testMoneyRejectsNegativeAndMissingValues() {
        XCTAssertNil(Money.parse("")); XCTAssertNil(Money.parse("-4")); XCTAssertNil(Money.parse("abc")); XCTAssertNil(Money.parse("12abc")); XCTAssertNil(Money.parse("1.999"))
        XCTAssertEqual(Money.parse("0"), 0); XCTAssertEqual(Money.parse("12.50"), Decimal(string: "12.50"))
    }
}
