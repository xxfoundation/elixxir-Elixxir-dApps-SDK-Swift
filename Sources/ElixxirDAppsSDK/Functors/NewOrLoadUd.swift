import Bindings
import XCTestDynamicOverlay

public struct NewOrLoadUd {
  public struct Params {
    public init(
      e2eId: Int,
      follower: UdNetworkStatus,
      username: String?,
      registrationValidationSignature: Data?,
      cert: Data,
      contactFile: Data,
      address: String
    ) {
      self.e2eId = e2eId
      self.follower = follower
      self.username = username
      self.registrationValidationSignature = registrationValidationSignature
      self.cert = cert
      self.contactFile = contactFile
      self.address = address
    }

    public var e2eId: Int
    public var follower: UdNetworkStatus
    public var username: String?
    public var registrationValidationSignature: Data?
    public var cert: Data
    public var contactFile: Data
    public var address: String
  }

  public var run: (Params) throws -> UserDiscovery

  public func callAsFunction(_ params: Params) throws -> UserDiscovery {
    try run(params)
  }
}

extension NewOrLoadUd {
  public static let live = NewOrLoadUd { params in
    var error: NSError?
    let bindingsUD = BindingsNewOrLoadUd(
      params.e2eId,
      params.follower.makeBindingsUdNetworkStatus(),
      params.username,
      params.registrationValidationSignature,
      params.cert,
      params.contactFile,
      params.address,
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsUD = bindingsUD else {
      fatalError("BindingsNewOrLoadUd returned `nil` without providing error")
    }
    return .live(bindingsUD)
  }
}

extension NewOrLoadUd {
  public static let unimplemented = NewOrLoadUd(
    run: XCTUnimplemented("\(Self.self)")
  )
}
