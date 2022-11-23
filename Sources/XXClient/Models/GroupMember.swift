import Foundation

public struct GroupMember: Equatable {
  public init(id: Data, dhKey: DHKey) {
    self.id = id
    self.dhKey = dhKey
  }

  public var id: Data
  public var dhKey: DHKey
}

extension GroupMember: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case dhKey = "DhKey"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}

extension Array where Element == GroupMember {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
