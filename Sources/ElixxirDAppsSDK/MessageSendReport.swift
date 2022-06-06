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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    messageId = try container.decodeIfPresent(Data.self, forKey: .messageId)
    timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp)
    roundList = try container.decodeIfPresent([Int].self, forKey: .roundList)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(messageId, forKey: .messageId)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encode(roundList, forKey: .roundList)
  }
}
