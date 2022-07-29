import Foundation

public struct SingleUseSendReport: Equatable {
  public init(
    rounds: [Int],
    ephId: EphId
  ) {
    self.rounds = rounds
    self.ephId = ephId
  }

  public var rounds: [Int]
  public var ephId: EphId
}

extension SingleUseSendReport {
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

extension SingleUseSendReport: Codable {
  enum CodingKeys: String, CodingKey {
    case rounds = "Rounds"
    case ephId = "EphID"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension SingleUseSendReport.EphId: Codable {
  enum CodingKeys: String, CodingKey {
    case ephId = "EphId"
    case source = "Source"
  }
}
