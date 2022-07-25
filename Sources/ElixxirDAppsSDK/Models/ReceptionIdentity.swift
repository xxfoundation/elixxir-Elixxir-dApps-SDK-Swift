import Foundation

public struct ReceptionIdentity: Equatable {
  public init(
    id: Data,
    rsaPrivatePem: Data,
    salt: Data,
    dhKeyPrivate: Data
  ) {
    self.id = id
    self.rsaPrivatePem = rsaPrivatePem
    self.salt = salt
    self.dhKeyPrivate = dhKeyPrivate
  }

  public var id: Data
  public var rsaPrivatePem: Data
  public var salt: Data
  public var dhKeyPrivate: Data
}

extension ReceptionIdentity: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case rsaPrivatePem = "RSAPrivatePem"
    case salt = "Salt"
    case dhKeyPrivate = "DHKeyPrivate"
  }

  public static func decode(_ data: Data) throws -> ReceptionIdentity {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
