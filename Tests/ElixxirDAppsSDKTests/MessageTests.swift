import CustomDump
import XCTest
@testable import ElixxirDAppsSDK

final class MessageTests: XCTestCase {
  func testCoding() throws {
    let jsonString = """
    {
      "MessageType": 1,
      "ID": "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w=",
      "Payload": "7TzZKgNphT5UooNM7mDSwtVcIs8AIu4vMKm4ld6GSR8YX5GrHirixUBAejmsgdroRJyo06TkIVef7UM9FN8YfQ==",
      "Sender": "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD",
      "RecipientID": "amFrZXh4MzYwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD",
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
      id: Data(base64Encoded: "EB/70R5HYEw5htZ4Hg9ondrn3+cAc/lH2G0mjQMja3w=")!,
      payload: Data(base64Encoded: "7TzZKgNphT5UooNM7mDSwtVcIs8AIu4vMKm4ld6GSR8YX5GrHirixUBAejmsgdroRJyo06TkIVef7UM9FN8YfQ==")!,
      sender: Data(base64Encoded: "emV6aW1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD")!,
      recipientId: Data(base64Encoded: "amFrZXh4MzYwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD")!,
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
