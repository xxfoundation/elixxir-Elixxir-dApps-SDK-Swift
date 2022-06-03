import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageSendReportTests: XCTestCase {
  func testCoding() throws {
    let messageId = secureRandomData(count: 32)
    let jsonString = """
    {
      "RoundList": {
        "Rounds": [1,5,9]
      },
      "MessageID": \(messageId.jsonEncodedBase64()),
      "Timestamp": 1653582683183384000
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let report = try decoder.decode(MessageSendReport.self, from: jsonData)

    XCTAssertNoDifference(report, MessageSendReport(
      roundList: [1, 5, 9],
      messageId: messageId,
      timestamp: 1_653_582_683_183_384_000
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedReport = try encoder.encode(report)
    let decodedReport = try decoder.decode(MessageSendReport.self, from: encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }
}
