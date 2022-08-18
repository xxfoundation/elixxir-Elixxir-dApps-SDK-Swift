import Foundation

public struct UserDiscoveryEnvironment: Equatable {
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
