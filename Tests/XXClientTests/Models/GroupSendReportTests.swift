import CustomDump
import XCTest
@testable import XXClient

final class GroupSendReportTests: XCTestCase {
  func testCoding() throws {
    let rounds: [Int] = [25, 64]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let timestamp: Int64 = 1_662_577_352_813_112_000
    let messageIdB64 = "69ug6FA50UT2q6MWH3hne9PkHQ+H9DnEDsBhc0m0Aww="
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "Timestamp": \(timestamp),
      "MessageID": "\(messageIdB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try GroupSendReport.decode(jsonData)

    XCTAssertNoDifference(model, GroupSendReport(
      rounds: rounds,
      roundURL: roundURL,
      timestamp: timestamp,
      messageId: Data(base64Encoded: messageIdB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try GroupSendReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
