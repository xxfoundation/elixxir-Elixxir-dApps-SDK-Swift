import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageTests: XCTestCase {
  func testCoding() throws {
    let type: Int = 1
    let idString = "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w="
    let payloadString = "7TzZKgNphT5UooNM7mDSwtVcIs8AIu4vMKm4ld6GSR8YX5GrHirixUBAejmsgdroRJyo06TkIVef7UM9FN8YfQ=="
    let senderString = "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let recipientIdString = "amFrZXh4MzYwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let ephemeralId: Int = 17
    let timestamp: Int = 1_653_580_439_357_351_000
    let encrypted = false
    let roundId: Int = 19
    let jsonString = """
    {
      "MessageType": \(type),
      "ID": "\(idString)",
      "Payload": "\(payloadString)",
      "Sender": "\(senderString)",
      "RecipientID": "\(recipientIdString)",
      "EphemeralID": \(ephemeralId),
      "Timestamp": \(timestamp),
      "Encrypted": \(encrypted),
      "RoundId": \(roundId)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!

    let message = try Message.decode(jsonData)

    XCTAssertNoDifference(message, Message(
      messageType: 1,
      id: Data(base64Encoded: idString)!,
      payload: Data(base64Encoded: payloadString)!,
      sender: Data(base64Encoded: senderString)!,
      recipientId: Data(base64Encoded: recipientIdString)!,
      ephemeralId: ephemeralId,
      timestamp: timestamp,
      encrypted: encrypted,
      roundId: roundId
    ))

    let encodedMessage = try message.encode()
    let decodedMessage = try Message.decode(encodedMessage)

    XCTAssertNoDifference(decodedMessage, message)
  }
}
