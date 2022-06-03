import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class ContactFactTests: XCTestCase {
  func testCoding() throws {
    let jsonString = """
    {
      "Fact": "Zezima",
      "Type": 0
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let fact = try decoder.decode(ContactFact.self, from: jsonData)

    XCTAssertNoDifference(fact, ContactFact(
      fact: "Zezima",
      type: 0
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedFact = try encoder.encode(fact)
    let decodedFact = try decoder.decode(ContactFact.self, from: encodedFact)

    XCTAssertNoDifference(decodedFact, fact)
  }
}
