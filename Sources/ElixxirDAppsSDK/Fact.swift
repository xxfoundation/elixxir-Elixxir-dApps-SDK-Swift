import Foundation

public struct Fact: Equatable {
  public init(
    fact: String,
    type: Int
  ) {
    self.fact = fact
    self.type = type
  }

  public var fact: String
  public var type: Int
}

extension Fact: Codable {
  enum CodingKeys: String, CodingKey {
    case fact = "Fact"
    case type = "Type"
  }

  static func decode(_ data: Data) throws -> Fact {
    try JSONDecoder().decode(Self.self, from: data)
  }

  func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Array where Element == Fact {
  static func decode(_ data: Data) throws -> [Fact] {
    try JSONDecoder().decode(Self.self, from: data)
  }

  func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
