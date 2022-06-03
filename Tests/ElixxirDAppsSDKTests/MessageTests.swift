import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageTests: XCTestCase {
  func testCoding() throws {
    let id = secureRandomData(count: 32)
    let payload = secureRandomData(count: 32)
    let sender = secureRandomData(count: 32)
    let recipientId = secureRandomData(count: 32)
    let jsonString = """
    {
      "MessageType": 1,
      "ID": \(id.jsonEncodedBase64()),
      "Payload": \(payload.jsonEncodedBase64()),
      "Sender": \(sender.jsonEncodedBase64()),
      "RecipientID": \(recipientId.jsonEncodedBase64()),
      "EphemeralID": 17,
      "Timestamp": 1653580439357351000,
      "Encrypted": false,
      "RoundId": 19
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dataDecodingStrategy = .base64
    let message = try decoder.decode(Message.self, from: jsonData)

    XCTAssertNoDifference(message, Message(
      messageType: 1,
      id: id,
      payload: payload,
      sender: sender,
      recipientId: recipientId,
      ephemeralId: 17,
      timestamp: 1_653_580_439_357_351_000,
      encrypted: false,
      roundId: 19
    ))

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64
    let encodedMessage = try encoder.encode(message)
    let decodedMessage = try decoder.decode(Message.self, from: encodedMessage)

    XCTAssertNoDifference(decodedMessage, message)
  }
}
