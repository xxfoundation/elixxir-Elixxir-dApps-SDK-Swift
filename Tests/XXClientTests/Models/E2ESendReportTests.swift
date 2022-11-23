import CustomDump
import XCTest
@testable import XXClient

final class E2ESendReportTests: XCTestCase {
  func testCoding() throws {
    let rounds = [1, 5, 9]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let messageIdB64 = "iM34yCIr4Je8ZIzL9iAAG1UWAeDiHybxMTioMAaezvs="
    let timestamp: Int = 1_661_532_254_302_612_000
    let keyResidueB64 = "9q2/A69EAuFM1hFAT7Bzy5uGOQ4T6bPFF72h5PlgCWE="
    let jsonString = """
    {
      "Rounds": [\(rounds.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "MessageID": "\(messageIdB64)",
      "Timestamp": \(timestamp),
      "KeyResidue": "\(keyResidueB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try E2ESendReport.decode(jsonData)

    XCTAssertNoDifference(model, E2ESendReport(
      rounds: rounds,
      roundURL: roundURL,
      messageId: Data(base64Encoded: messageIdB64)!,
      timestamp: timestamp,
      keyResidue: Data(base64Encoded: keyResidueB64)
    ))

    let encodedModel = try model.encode()
    let decodedModel = try E2ESendReport.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testDecodeEmpty() throws {
    let jsonString = "{}"
    let jsonData = jsonString.data(using: .utf8)!
    let model = try E2ESendReport.decode(jsonData)

    XCTAssertNoDifference(model, E2ESendReport(
      rounds: nil,
      roundURL: nil,
      messageId: nil,
      timestamp: nil,
      keyResidue: nil
    ))
  }
}
