import Bindings
import XCTestDynamicOverlay

public struct NewOrLoadUd {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      username: String?,
      registrationValidationSignature: Data?,
      cert: Data,
      contact: Data,
      address: String
    ) {
      self.e2eId = e2eId
      self.username = username
      self.registrationValidationSignature = registrationValidationSignature
      self.cert = cert
      self.contact = contact
      self.address = address
    }

    public var e2eId: Int
    public var username: String?
    public var registrationValidationSignature: Data?
    public var cert: Data
    public var contact: Data
    public var address: String
  }

  public var run: (Params, UdNetworkStatus) throws -> UserDiscovery

  public func callAsFunction(
    params: Params,
    follower: UdNetworkStatus
  ) throws -> UserDiscovery {
    try run(params, follower)
  }
}

extension NewOrLoadUd {
  public static let live = NewOrLoadUd { params, follower in
    var error: NSError?
    let bindingsUD = BindingsNewOrLoadUd(
      params.e2eId,
      follower.makeBindingsUdNetworkStatus(),
      params.username,
      params.registrationValidationSignature,
      params.cert,
      params.contact,
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
