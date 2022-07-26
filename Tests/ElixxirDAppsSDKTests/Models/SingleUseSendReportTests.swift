import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class SingleUseSendReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [1, 5, 9]
    let ephId: [Int] = [0, 0, 0, 0, 0, 0, 3, 89]
    let ephIdSourceB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "EphID": {
        "EphId": [\(ephId.map { "\($0)" }.joined(separator: ", "))],
        "Source": "\(ephIdSourceB64)"
      }
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let report = try SingleUseSendReport.decode(jsonData)

    XCTAssertNoDifference(report, SingleUseSendReport(
      rounds: rounds,
      ephId: .init(
        ephId: ephId,
        source: Data(base64Encoded: ephIdSourceB64)!
      )
    ))

    let encodedReport = try report.encode()
    let decodedReport = try SingleUseSendReport.decode(encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }
}
