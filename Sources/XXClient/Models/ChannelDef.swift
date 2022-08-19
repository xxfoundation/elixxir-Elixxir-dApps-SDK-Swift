import Foundation

public struct ChannelDef: Equatable {
  public init(
    name: String,
    description: String,
    salt: Data,
    pubKey: Data
  ) {
    self.name = name
    self.description = description
    self.salt = salt
    self.pubKey = pubKey
  }

  public var name: String
  public var description: String
  public var salt: Data
  public var pubKey: Data
}

extension ChannelDef: Codable {
  enum CodingKeys: String, CodingKey {
    case name = "Name"
    case description = "Description"
    case salt = "Salt"
    case pubKey = "PubKey"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
