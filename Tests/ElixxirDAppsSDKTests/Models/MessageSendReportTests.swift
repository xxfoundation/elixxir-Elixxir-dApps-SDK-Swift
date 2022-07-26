import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageSendReportTests: XCTestCase {
  func testCoding() throws {
    let rounds = [1, 5, 9]
    let messageIdB64 = "51Yy47uZbP0o2Y9B/kkreDLTB6opUol3M3mYiY2dcdQ="
    let timestamp: Int = 1_653_582_683_183_384_000
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "MessageID": "\(messageIdB64)",
      "Timestamp": \(timestamp)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let report = try MessageSendReport.decode(jsonData)

    XCTAssertNoDifference(report, MessageSendReport(
      roundList: rounds,
      messageId: Data(base64Encoded: messageIdB64)!,
      timestamp: timestamp
    ))

    let encodedReport = try report.encode()
    let decodedReport = try MessageSendReport.decode(encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }

  func testDecodeEmpty() throws {
    let jsonString = "{}"
    let jsonData = jsonString.data(using: .utf8)!

    let report = try MessageSendReport.decode(jsonData)

    XCTAssertNoDifference(report, MessageSendReport(
      roundList: nil,
      messageId: nil,
      timestamp: nil
    ))
  }
}
