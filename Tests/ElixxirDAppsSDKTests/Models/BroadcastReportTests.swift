import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

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
    let report = try BroadcastReport.decode(jsonData)

    XCTAssertNoDifference(report, BroadcastReport(
      roundId: roundId,
      ephId: ephId
    ))

    let encodedReport = try report.encode()
    let decodedReport = try BroadcastReport.decode(encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }
}
