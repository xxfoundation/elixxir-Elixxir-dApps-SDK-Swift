import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageTests: XCTestCase {
  func testCoding() throws {
    let type: Int = 1
    let idB64 = "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w="
    let payloadB64 = "7TzZKgNphT5UooNM7mDSwtVcIs8AIu4vMKm4ld6GSR8YX5GrHirixUBAejmsgdroRJyo06TkIVef7UM9FN8YfQ=="
    let senderB64 = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let recipientIdB64 = "amFrZXh4MzYwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let ephemeralId: Int = 17
    let timestamp: Int = 1_653_580_439_357_351_000
    let encrypted = false
    let roundId: Int = 19
    let jsonString = """
    {
      "MessageType": \(type),
      "ID": "\(idB64)",
      "Payload": "\(payloadB64)",
      "Sender": "\(senderB64)",
      "RecipientID": "\(recipientIdB64)",
      "EphemeralID": \(ephemeralId),
      "Timestamp": \(timestamp),
      "Encrypted": \(encrypted),
      "RoundId": \(roundId)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Message.decode(jsonData)

    XCTAssertNoDifference(model, Message(
      messageType: 1,
      id: Data(base64Encoded: idB64)!,
      payload: Data(base64Encoded: payloadB64)!,
      sender: Data(base64Encoded: senderB64)!,
      recipientId: Data(base64Encoded: recipientIdB64)!,
      ephemeralId: ephemeralId,
      timestamp: timestamp,
      encrypted: encrypted,
      roundId: roundId
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Message.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
