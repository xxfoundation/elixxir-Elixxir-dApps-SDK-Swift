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
    let model = try Fact.decode(jsonData)

    XCTAssertNoDifference(model, Fact(
      fact: factValue,
      type: factType
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Fact.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
