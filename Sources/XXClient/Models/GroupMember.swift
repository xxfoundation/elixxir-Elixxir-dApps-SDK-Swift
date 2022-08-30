import Foundation

public struct GroupMember: Equatable {
  public init(id: Data) {
    self.id = id
  }

  public var id: Data
}

extension GroupMember: Decodable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
  }

  public static func decode(_ data: Data) throws -> Self {
    let data = convertJsonNumberToString(in: data, minNumberLength: 19)
    return try JSONDecoder().decode(Self.self, from: data)
  }
}

extension Array where Element == GroupMember {
  public static func decode(_ data: Data) throws -> Self {
    let data = convertJsonNumberToString(in: data, minNumberLength: 19)
    return try JSONDecoder().decode(Self.self, from: data)
  }
}
