import CustomDump
import XCTest
@testable import XXClient

final class GroupChatMessageTests: XCTestCase {
  func testCoding() throws {
    let groupIdB64 = "AAAAAAAJlasAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE"
    let senderIdB64 = "AAAAAAAAB8gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD"
    let messageIdB64 = "Zm9ydHkgZml2ZQAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    let payloadB64 = "Zm9ydHkgZml2ZQ=="
    let timestamp: Int64 = 1_663_009_269_474_079_000
    let jsonString = """
    {
      "GroupId": "\(groupIdB64)",
      "SenderId": "\(senderIdB64)",
      "MessageId": "\(messageIdB64)",
      "Payload": "\(payloadB64)",
      "Timestamp": \(timestamp)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try GroupChatMessage.decode(jsonData)

    XCTAssertNoDifference(model, GroupChatMessage(
      groupId: Data(base64Encoded: groupIdB64)!,
      senderId: Data(base64Encoded: senderIdB64)!,
      messageId: Data(base64Encoded: messageIdB64)!,
      payload: Data(base64Encoded: payloadB64)!,
      timestamp: timestamp
    ))

    let encodedModel = try model.encode()
    let decodedModel = try GroupChatMessage.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }
}
