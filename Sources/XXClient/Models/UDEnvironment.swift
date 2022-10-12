import Foundation

public struct UDEnvironment: Equatable, Codable {
  public init(
    address: String,
    cert: Data,
    contact: Data
  ) {
    self.address = address
    self.cert = cert
    self.contact = contact
  }

  public var address: String
  public var cert: Data
  public var contact: Data
}
