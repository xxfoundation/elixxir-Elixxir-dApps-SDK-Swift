import Foundation

public struct MessageSendReport: Equatable {
  public init(
    roundList: [Int],
    messageId: Data,
    timestamp: Int
  ) {
    self.roundList = roundList
    self.messageId = messageId
    self.timestamp = timestamp
  }

  public var roundList: [Int]
  public var messageId: Data
  public var timestamp: Int
}

extension MessageSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case roundList = "RoundList"
    case messageId = "MessageID"
    case timestamp = "Timestamp"
  }

  enum RoundListCodingKeys: String, CodingKey {
    case rounds = "Rounds"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    messageId = try container.decode(Data.self, forKey: .messageId)
    timestamp = try container.decode(Int.self, forKey: .timestamp)
    let roundListContainer = try container.nestedContainer(
      keyedBy: RoundListCodingKeys.self,
      forKey: .roundList
    )
    roundList = try roundListContainer.decode([Int].self, forKey: .rounds)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(messageId, forKey: .messageId)
    try container.encode(timestamp, forKey: .timestamp)
    var roundListContainer = container.nestedContainer(
      keyedBy: RoundListCodingKeys.self,
      forKey: .roundList
    )
    try roundListContainer.encode(roundList, forKey: .rounds)
  }
}
