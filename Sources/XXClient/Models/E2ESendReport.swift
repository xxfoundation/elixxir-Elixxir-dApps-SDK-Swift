import Foundation

public struct E2ESendReport: Equatable {
  public init(
    rounds: [Int]?,
    roundURL: String?,
    messageId: Data?,
    timestamp: Int?,
    keyResidue: Data?
  ) {
    self.rounds = rounds
    self.roundURL = roundURL
    self.messageId = messageId
    self.timestamp = timestamp
    self.keyResidue = keyResidue
  }

  public var rounds: [Int]?
  public var roundURL: String?
  public var messageId: Data?
  public var timestamp: Int?
  public var keyResidue: Data?
}

extension E2ESendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case roundURL = "RoundURL"
    case messageId = "MessageID"
    case timestamp = "Timestamp"
    case keyResidue = "KeyResidue"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
