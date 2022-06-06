import Foundation

public struct MessageSendReport: Equatable {
  public init(
    roundList: [Int]?,
    messageId: Data?,
    timestamp: Int?
  ) {
    self.roundList = roundList
    self.messageId = messageId
    self.timestamp = timestamp
  }

  public var roundList: [Int]?
  public var messageId: Data?
  public var timestamp: Int?
}

extension MessageSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case roundList = "Rounds"
    case messageId = "MessageID"
    case timestamp = "Timestamp"
  }
}
