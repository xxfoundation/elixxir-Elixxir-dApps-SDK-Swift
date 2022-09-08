import Foundation

public struct BroadcastReport: Equatable {
  public init(
    rounds: [Int],
    ephId: [Int],
    roundURL: String
  ) {
    self.rounds = rounds
    self.ephId = ephId
    self.roundURL = roundURL
  }

  public var rounds: [Int]
  public var ephId: [Int]
  public var roundURL: String
}

extension BroadcastReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case ephId = "EphID"
    case roundURL = "RoundURL"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
