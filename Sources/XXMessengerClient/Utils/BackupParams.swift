import Foundation

public struct BackupParams: Codable {
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
