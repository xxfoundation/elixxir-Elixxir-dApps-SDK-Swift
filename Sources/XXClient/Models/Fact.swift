import Foundation

public struct Fact: Equatable {
  public init(
    type: FactType,
    value: String
  ) {
    self.type = type
    self.value = value
  }

  public var type: FactType
  public var value: String
}

extension Fact: Codable {
  enum CodingKeys: String, CodingKey {
    case type = "T"
    case value = "Fact"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Fact {
  @available(iOS, deprecated: 9999.0, message: "This API has been soft-deprecated in favor of `Fact.init(type:value:)`.")
  @available(macOS, deprecated: 9999.0, message: "This API has been soft-deprecated in favor of `Fact.init(type:value:)`.")
  public init(fact: String, type: Int) {
    self.init(type: .init(rawValue: type), value: fact)
  }

  @available(iOS, deprecated: 9999.0, message: "This API has been soft-deprecated in favor of `Fact.value`.")
  @available(macOS, deprecated: 9999.0, message: "This API has been soft-deprecated in favor of `Fact.value`.")
  public var fact: String {
    get { value }
    set { value = newValue }
  }
}

extension Array where Element == Fact {
  public static func decode(_ data: Data) throws -> Self {
    if let string = String(data: data, encoding: .utf8), string == "null" {
      return []
    }
    return try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    if isEmpty {
      return "null".data(using: .utf8)!
    }
    return try JSONEncoder().encode(self)
  }
}

extension Array where Element == Fact {
  public func get(_ type: FactType) -> Fact? {
    first(where: { $0.type == type })
  }

  public mutating func set(_ type: FactType, _ value: String?) {
    removeAll(where: { $0.type == type })
    if let value = value {
      append(Fact(type: type, value: value))
      sort(by: { $0.type < $1.type })
    }
  }
}
