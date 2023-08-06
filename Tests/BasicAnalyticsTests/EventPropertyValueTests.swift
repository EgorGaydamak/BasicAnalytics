import XCTest
@testable import BasicAnalytics

class AnalyticsEventPropertyValueTests: XCTestCase {

    func testEncodingAndDecoding() {
        let values: [AnalyticsEventPropertyValue] = [
            .string("hello"),
            .int(42),
            .boolean(true)
        ]

        for value in values {
            do {
                let encodedData = try JSONEncoder().encode(value)
                let decodedValue = try JSONDecoder().decode(AnalyticsEventPropertyValue.self, from: encodedData)
                XCTAssertEqual(decodedValue, value)
            } catch {
                XCTFail("Encoding or decoding failed with error: \(error)")
            }
        }
    }

    func testEquality() {
        let values: [(AnalyticsEventPropertyValue, AnalyticsEventPropertyValue)] = [
            (.string("hello"), .string("hello")),
            (.int(42), .int(42)),
            (.boolean(true), .boolean(true)),
            (.boolean(false), .boolean(false))
        ]

        for (value1, value2) in values {
            XCTAssertEqual(value1, value2)
        }
    }
}
