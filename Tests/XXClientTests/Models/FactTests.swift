import CustomDump
import XCTest
@testable import XXClient

final class FactTests: XCTestCase {
  func testCoding() throws {
    let factValue = "Zezima"
    let factType: Int = 0
    let jsonString = """
    {
      "Fact": "\(factValue)",
      "T": \(factType)
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

  func testCodingArray() throws {
    let models = [
      Fact(fact: "abcd", type: 0),
      Fact(fact: "efgh", type: 1),
      Fact(fact: "ijkl", type: 2),
    ]

    let encodedModels = try models.encode()
    let decodedModels = try [Fact].decode(encodedModels)

    XCTAssertNoDifference(models, decodedModels)
  }

  func testCodingEmptyArray() throws {
    let jsonString = "null"
    let jsonData = jsonString.data(using: .utf8)!

    let decodedModels = try [Fact].decode(jsonData)

    XCTAssertNoDifference(decodedModels, [])

    let encodedModels = try decodedModels.encode()

    XCTAssertNoDifference(encodedModels, jsonData)
  }
}
