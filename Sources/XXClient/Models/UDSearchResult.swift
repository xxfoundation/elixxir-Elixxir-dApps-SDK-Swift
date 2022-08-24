import Foundation

public struct UDSearchResult: Equatable {
  public init(
    id: Data,
    facts: [Fact]
  ) {
    self.id = id
    self.facts = facts
  }

  public var id: Data
  public var facts: [Fact]
}

extension UDSearchResult: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case facts = "Facts"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Array where Element == UDSearchResult {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
