import Foundation

public struct GroupMember: Equatable {
  public init(id: Data, dhKey: DHKey) {
    self.id = id
    self.dhKey = dhKey
  }

  public var id: Data
  public var dhKey: DHKey
}

extension GroupMember: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case dhKey = "DhKey"
  }

  public static func decode(_ data: Data) throws -> Self {
    let data = convertJsonNumberToString(in: data, at: "Value")
    return try JSONDecoder().decode(Self.self, from: data)
  }
}

extension Array where Element == GroupMember {
  public static func decode(_ data: Data) throws -> Self {
    let data = convertJsonNumberToString(in: data, at: "Value")
    return try JSONDecoder().decode(Self.self, from: data)
  }
}
