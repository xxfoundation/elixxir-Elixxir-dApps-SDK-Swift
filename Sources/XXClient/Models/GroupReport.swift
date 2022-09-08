import Foundation

public struct GroupReport: Equatable {
  public init(
    id: Data,
    rounds: [Int],
    roundURL: String,
    status: Int
  ) {
    self.id = id
    self.rounds = rounds
    self.roundURL = roundURL
    self.status = status
  }

  public var id: Data
  public var rounds: [Int]
  public var roundURL: String
  public var status: Int
}

extension GroupReport: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "Id"
    case rounds = "Rounds"
    case roundURL = "RoundURL"
    case status = "Status"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
