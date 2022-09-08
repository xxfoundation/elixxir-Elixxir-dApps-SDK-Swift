import CustomDump
import XCTest
@testable import XXClient

final class BroadcastMessageTests: XCTestCase {
  func testCoding() throws {
    let roundId: Int = 42
    let ephId: [Int] = [0, 0, 0, 0, 0, 0, 24, 61]
    let roundURL = "https://dashboard.xx.network/rounds/25?xxmessenger=true"
    let payloadB64 = "SGVsbG8sIGJyb2FkY2FzdCBmcmllbmRzIQ=="
    let jsonString = """
    {
      "RoundID": \(roundId),
      "EphID": [\(ephId.map { "\($0)" }.joined(separator: ", "))],
      "RoundURL": "\(roundURL)",
      "Payload": "\(payloadB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try BroadcastMessage.decode(jsonData)

    XCTAssertNoDifference(model, BroadcastMessage(
      roundId: roundId,
      ephId: ephId,
      roundURL: roundURL,
      payload: Data(base64Encoded: payloadB64)!
    ))

    let encodedModel = try model.encode()
    let decodedModel = try BroadcastMessage.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
