import CustomDump
import XCTest
@testable import XXClient

final class BroadcastReportTests: XCTestCase {
  func testCoding() throws {
    let roundId: Int = 42
    let ephId: [Int] = [0, 0, 0, 0, 0, 0, 24, 61]
    let jsonString = """
    {
      "RoundID": \(roundId),
      "EphID": [\(ephId.map { "\($0)" }.joined(separator: ", "))]
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BroadcastReport.decode(jsonData)

    XCTAssertNoDifference(model, BroadcastReport(
      roundId: roundId,
      ephId: ephId
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BroadcastReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
