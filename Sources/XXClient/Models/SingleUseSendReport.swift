import Foundation

public struct SingleUseSendReport: Equatable {
  public init(
    rounds: [Int],
    roundURL: String,
    ephId: Int64,
    receptionId: Data
  ) {
    self.rounds = rounds
    self.roundURL = roundURL
    self.ephId = ephId
    self.receptionId = receptionId
  }

  public var rounds: [Int]
  public var roundURL: String
  public var ephId: Int64
  public var receptionId: Data
}

extension SingleUseSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case roundURL = "RoundURL"
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
