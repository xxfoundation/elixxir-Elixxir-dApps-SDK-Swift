import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class BroadcastMessageTests: XCTestCase {
  func testCoding() throws {
    let roundId: Int = 42
    let ephId: [Int] = [0, 0, 0, 0, 0, 0, 24, 61]
    let payloadB64 = "SGVsbG8sIGJyb2FkY2FzdCBmcmllbmRzIQ=="
    let jsonString = """
    {
      "RoundID": \(roundId),
      "EphID": [\(ephId.map { "\($0)" }.joined(separator: ", "))],
      "Payload": "\(payloadB64)"
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let message = try BroadcastMessage.decode(jsonData)

    XCTAssertNoDifference(message, BroadcastMessage(
      roundId: roundId,
      ephId: ephId,
      payload: Data(base64Encoded: payloadB64)!
    ))

    let encodedMessage = try message.encode()
    let decodedMessage = try BroadcastMessage.decode(encodedMessage)

    XCTAssertNoDifference(decodedMessage, message)
  }
}
