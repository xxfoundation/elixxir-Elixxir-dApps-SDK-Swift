import Foundation

public struct UserDiscoveryConfig: Equatable {
  public init(cert: Data, address: Data, contact: Data) {
    self.cert = cert
    self.address = address
    self.contact = contact
  }

  public var cert: Data
  public var address: Data
  public var contact: Data
}
