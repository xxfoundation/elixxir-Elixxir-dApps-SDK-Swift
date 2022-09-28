import Foundation

public struct BackupParams: Equatable {
  public init(
    username: String,
    email: String?,
    phone: String?
  ) {
    self.username = username
    self.email = email
    self.phone = phone
  }

  public var username: String
  public var email: String?
  public var phone: String?
}

extension BackupParams: Codable {
  public static func decode(_ data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }

  public func encode() throws -> Data {
    try JSONEncoder().encode(self)
  }
}
