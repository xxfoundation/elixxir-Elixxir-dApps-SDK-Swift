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
    let data = convertBigIntsToStrings(jsonData: data)
    return try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Array where Element == UDSearchResult {
  public static func decode(_ data: Data) throws -> Self {
    let data = convertBigIntsToStrings(jsonData: data)
    return try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

private func convertBigIntsToStrings(jsonData input: Data) -> Data {
  guard var string = String(data: input, encoding: .utf8) else {
    return input
  }
  string = string.replacingOccurrences(
    of: #":\s*([0-9]{19,})\s*,"#,
    with: #": "$1","#,
    options: [.regularExpression]
  )
  guard let output = string.data(using: .utf8) else {
    return input
  }
  return output
}
