import Foundation

public struct GroupSendReport: Equatable {
  public init(
    roundId: UInt64,
    timestamp: Int64,
    messageId: Data
  ) {
    self.roundId = roundId
    self.timestamp = timestamp
    self.messageId = messageId
  }

  public var roundId: UInt64
  public var timestamp: Int64
  public var messageId: Data
}

extension GroupSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case roundId = "RoundID"
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
