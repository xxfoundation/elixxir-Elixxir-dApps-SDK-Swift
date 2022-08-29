import Foundation

public struct E2ESendReport: Equatable {
  public init(
    roundList: [Int]?,
    messageId: Data?,
    timestamp: Int?,
    keyResidue: Data?
  ) {
    self.roundList = roundList
    self.messageId = messageId
    self.timestamp = timestamp
    self.keyResidue = keyResidue
  }

  public var roundList: [Int]?
  public var messageId: Data?
  public var timestamp: Int?
  public var keyResidue: Data?
}

extension E2ESendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case roundList = "Rounds"
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
