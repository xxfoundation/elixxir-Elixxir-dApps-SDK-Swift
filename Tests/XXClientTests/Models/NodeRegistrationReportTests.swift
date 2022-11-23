import CustomDump
import XCTest
@testable import XXClient

final class NodeRegistrationReportTests: XCTestCase {
  func testCoding() throws {
    let registered: Int = 128
    let total: Int = 2048
    let jsonString = """
    {
      "NumberOfNodesRegistered": \(registered),
      "NumberOfNodes": \(total)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try NodeRegistrationReport.decode(jsonData)

    XCTAssertNoDifference(model, NodeRegistrationReport(
      registered: registered,
      total: total
    ))

    let encodedModel = try model.encode()
    let decodedModel = try NodeRegistrationReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testRatio() {
    let model = NodeRegistrationReport(
      registered: 128,
      total: 2048
    )

    XCTAssertEqual(model.ratio, 0.0625)
  }

  func testRatioWhenNoNodes() {
    let model = NodeRegistrationReport(
      registered: 128,
      total: 0
    )

    XCTAssertEqual(model.ratio, 0)
  }
}
