import Foundation

public struct ReceptionIdentity: Equatable {
  public init(
    id: Data,
    rsaPrivatePem: Data,
    salt: Data,
    dhKeyPrivate: Data,
    e2eGrp: Data
  ) {
    self.id = id
    self.rsaPrivatePem = rsaPrivatePem
    self.salt = salt
    self.dhKeyPrivate = dhKeyPrivate
    self.e2eGrp = e2eGrp
  }

  public var id: Data
  public var rsaPrivatePem: Data
  public var salt: Data
  public var dhKeyPrivate: Data
  public var e2eGrp: Data
}

extension ReceptionIdentity: Codable {
  enum CodingKeys: String, CodingKey {
    case id = "ID"
    case rsaPrivatePem = "RSAPrivatePem"
    case salt = "Salt"
    case dhKeyPrivate = "DHKeyPrivate"
    case e2eGrp = "E2eGrp"
  }

  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
