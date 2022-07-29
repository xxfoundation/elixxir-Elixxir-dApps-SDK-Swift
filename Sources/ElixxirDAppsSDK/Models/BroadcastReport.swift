import Foundation

public struct BroadcastReport: Equatable {
  public init(
    roundId: Int,
    ephId: [Int]
  ) {
    self.roundId = roundId
    self.ephId = ephId
  }

  public var roundId: Int
  public var ephId: [Int]
}

extension BroadcastReport: Codable {
  enum CodingKeys: String, CodingKey {
    case roundId = "RoundID"
    case ephId = "EphID"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
