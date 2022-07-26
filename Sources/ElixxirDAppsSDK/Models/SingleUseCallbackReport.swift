import Foundation

public struct SingleUseCallbackReport: Equatable {
  public init(
    rounds: [Int],
    payload: Data,
    partner: Data,
    ephId: EphId
  ) {
    self.rounds = rounds
    self.payload = payload
    self.partner = partner
    self.ephId = ephId
  }

  public var rounds: [Int]
  public var payload: Data
  public var partner: Data
  public var ephId: EphId
}

extension SingleUseCallbackReport {
  public struct EphId: Equatable {
    public init(
      ephId: [Int],
      source: Data
    ) {
      self.ephId = ephId
      self.source = source
    }

    public var ephId: [Int]
    public var source: Data
  }
}

extension SingleUseCallbackReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case payload = "Payload"
    case partner = "Partner"
    case ephId = "EphID"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension SingleUseCallbackReport.EphId: Codable {
  enum CodingKeys: String, CodingKey {
    case ephId = "EphId"
    case source = "Source"
  }
}
