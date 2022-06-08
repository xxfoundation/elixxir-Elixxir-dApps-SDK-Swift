import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageSendReportTests: XCTestCase {
  func testCoding() throws {
    let jsonString = """
    {
      "Rounds": [1,5,9],
      "MessageID": "51Yy47uZbP0o2Y9B/kkreDLTB6opUol3M3mYiY2dcdQ=",
      "Timestamp": 1653582683183384000
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let report = try decoder.decode(MessageSendReport.self, from: jsonData)

    XCTAssertNoDifference(report, MessageSendReport(
      roundList: [1, 5, 9],
      messageId: Data(base64Encoded: "51Yy47uZbP0o2Y9B/kkreDLTB6opUol3M3mYiY2dcdQ=")!,
      timestamp: 1_653_582_683_183_384_000
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedReport = try encoder.encode(report)
    let decodedReport = try decoder.decode(MessageSendReport.self, from: encodedReport)

    XCTAssertNoDifference(decodedReport, report)
  }

  func testDecodeEmpty() throws {
    let jsonString = "{}"
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let report = try decoder.decode(MessageSendReport.self, from: jsonData)

    XCTAssertNoDifference(report, MessageSendReport(
      roundList: nil,
      messageId: nil,
      timestamp: nil
    ))
  }
}
