import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class FactTests: XCTestCase {
  func testCoding() throws {
    let factValue = "Zezima"
    let factType: Int = 0
    let jsonString = """
    {
      "Fact": "\(factValue)",
      "Type": \(factType)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let fact = try Fact.decode(jsonData)

    XCTAssertNoDifference(fact, Fact(
      fact: factValue,
      type: factType
    ))

    let encodedFact = try fact.encode()
    let decodedFact = try Fact.decode(encodedFact)

    XCTAssertNoDifference(decodedFact, fact)
  }
}
