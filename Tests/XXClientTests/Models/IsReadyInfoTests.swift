import CustomDump
import XCTest
@testable import XXClient

final class IsReadyInfoTests: XCTestCase {
  func testCoding() throws {
    let jsonString = """
    {
      "IsReady": true,
      "HowClose": 0.534
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try IsReadyInfo.decode(jsonData)

    XCTAssertNoDifference(model, IsReadyInfo(
      isReady: true,
      howClose: 0.534
    ))

    let encodedModel = try model.encode()
    let decodedModel = try IsReadyInfo.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
