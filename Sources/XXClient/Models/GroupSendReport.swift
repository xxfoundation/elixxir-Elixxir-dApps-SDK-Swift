import Foundation

public struct GroupSendReport: Equatable {
  public init(
    rounds: [Int],
    roundURL: String,
    timestamp: Int64,
    messageId: Data
  ) {
    self.rounds = rounds
    self.roundURL = roundURL
    self.timestamp = timestamp
    self.messageId = messageId
  }

  public var rounds: [Int]
  public var roundURL: String
  public var timestamp: Int64
  public var messageId: Data
}

extension GroupSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case roundURL = "RoundURL"
    case timestamp = "Timestamp"
    case messageId = "MessageID"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
