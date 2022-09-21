import Foundation

public struct BackupParams: Codable {
  public init(
    email: String?,
    phone: String?,
    username: String
  ) {
    self.email = email
    self.phone = phone
    self.username = username
  }

  public var email: String?
  public var phone: String?
  public var username: String
}
