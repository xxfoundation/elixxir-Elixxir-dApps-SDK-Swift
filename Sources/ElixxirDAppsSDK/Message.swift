import Foundation

public struct Message: Equatable {
  public init(
    messageType: Int,
    id: Data,
    payload: Data,
    sender: Data,
    recipientId: Data,
    ephemeralId: Int,
    timestamp: Int,
    encrypted: Bool,
    roundId: Int
  ) {
    self.messageType = messageType
    self.id = id
    self.payload = payload
    self.sender = sender
    self.recipientId = recipientId
    self.ephemeralId = ephemeralId
    self.timestamp = timestamp
    self.encrypted = encrypted
    self.roundId = roundId
  }

  public var messageType: Int
  public var id: Data
  public var payload: Data
  public var sender: Data
  public var recipientId: Data
  public var ephemeralId: Int
  public var timestamp: Int
  public var encrypted: Bool
  public var roundId: Int
}

extension Message: Codable {
  enum CodingKeys: String, CodingKey {
    case messageType = "MessageType"
    case id = "ID"
    case payload = "Payload"
    case sender = "Sender"
    case recipientId = "RecipientID"
    case ephemeralId = "EphemeralID"
    case timestamp = "Timestamp"
    case encrypted = "Encrypted"
    case roundId = "RoundId"
  }

  static func decode(_ data: Data) throws -> Message {
    try JSONDecoder().decode(Self.self, from: data)
  }

  func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
