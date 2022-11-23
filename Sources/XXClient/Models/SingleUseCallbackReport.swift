import Foundation

public struct SingleUseCallbackReport: Equatable {
  public init(
    rounds: [Int],
    roundURL: String,
    payload: Data,
    partner: Data,
    ephId: Int64,
    receptionId: Data
  ) {
    self.rounds = rounds
    self.roundURL = roundURL
    self.payload = payload
    self.partner = partner
    self.ephId = ephId
    self.receptionId = receptionId
  }

  public var rounds: [Int]
  public var roundURL: String
  public var payload: Data
  public var partner: Data
  public var ephId: Int64
  public var receptionId: Data
}

extension SingleUseCallbackReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case roundURL = "RoundURL"
    case payload = "Payload"
    case partner = "Partner"
    case ephId = "EphID"
    case receptionId = "ReceptionID"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
