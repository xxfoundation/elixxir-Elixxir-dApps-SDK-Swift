import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class GroupSendReportTests: XCTestCase {
  func testCoding() throws {
    let roundId: UInt64 = 123
    let timestamp: Int64 = 321
    let messageIdB64 = "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w="
    let jsonString = """
    {
      "RoundID": \(roundId),
      "Timestamp": \(timestamp),
      "MessageID": "\(messageIdB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try GroupSendReport.decode(jsonData)

    XCTAssertNoDifference(model, GroupSendReport(
      roundId: roundId,
      timestamp: timestamp,
      messageId: Data(base64Encoded: messageIdB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try GroupSendReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
