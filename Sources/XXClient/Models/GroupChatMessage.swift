import Foundation

public struct GroupChatMessage: Equatable {
  public init(
    groupId: Data,
    senderId: Data,
    messageId: Data,
    payload: Data,
    timestamp: Int64
  ) {
    self.groupId = groupId
    self.senderId = senderId
    self.messageId = messageId
    self.payload = payload
    self.timestamp = timestamp
  }

  public var groupId: Data
  public var senderId: Data
  public var messageId: Data
  public var payload: Data
  public var timestamp: Int64
}

extension GroupChatMessage: Codable {
  enum CodingKeys: String, CodingKey {
    case groupId = "GroupId"
    case senderId = "SenderId"
    case messageId = "MessageId"
    case payload = "Payload"
    case timestamp = "Timestamp"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
