import CustomDump
import XCTest
@testable import XXClient

final class UDSearchResultTests: XCTestCase {
  func testCoding() throws {
    let idB64 = "pYIpRwPy+FnOkl5tndkG8RC93W/t5b1lszqPpMDynlUD"
    let facts: [Fact] = [
      Fact(fact: "carlos_arimateias", type: 0),
    ]
    let jsonString = """
    {
      "ID": "\(idB64)",
      "Facts": \(String(data: try! facts.encode(), encoding: .utf8)!)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try UDSearchResult.decode(jsonData)

    XCTAssertNoDifference(model, UDSearchResult(
      id: Data(base64Encoded: idB64)!,
      facts: facts
    ))

    let encodedModel = try model.encode()
    let decodedModel = try UDSearchResult.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testCodingArray() throws {
    let models: [UDSearchResult] = [
      UDSearchResult(
        id: Data(base64Encoded: "pYIpRwPy+FnOkl5tndkG8RC93W/t5b1lszqPpMDynlUD")!,
        facts: [
          Fact(fact: "carlos_arimateias", type: 0),
        ]
      ),
    ]
    let encodedModels = try models.encode()
    let decodedModels = try [UDSearchResult].decode(encodedModels)

    XCTAssertNoDifference(decodedModels, models)
  }
}
