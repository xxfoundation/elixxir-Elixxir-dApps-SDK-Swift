import Bindings
import XCTestDynamicOverlay

public struct NewUdManagerFromBackup {
  public struct Params {
    public init(
      e2eId: Int,
      follower: UdNetworkStatus,
      email: Fact?,
      phone: Fact?,
      cert: Data,
      contactFile: Data,
      address: String
    ) {
      self.e2eId = e2eId
      self.follower = follower
      self.email = email
      self.phone = phone
      self.cert = cert
      self.contactFile = contactFile
      self.address = address
    }

    public var e2eId: Int
    public var follower: UdNetworkStatus
    public var email: Fact?
    public var phone: Fact?
    public var cert: Data
    public var contactFile: Data
    public var address: String
  }

  public var run: (Params) throws -> UserDiscovery

  public func callAsFunction(_ params: Params) throws -> UserDiscovery {
    try run(params)
  }
}

extension NewUdManagerFromBackup {
  public static let live = NewUdManagerFromBackup { params in
    var error: NSError?
    let bindingsUD = BindingsNewUdManagerFromBackup(
      params.e2eId,
      params.follower.makeBindingsUdNetworkStatus(),
      try params.email?.encode(),
      try params.phone?.encode(),
      params.cert,
      params.contactFile,
      params.address,
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsUD = bindingsUD else {
      fatalError("BindingsNewUdManagerFromBackup returned `nil` without providing error")
    }
    return .live(bindingsUD)
  }
}

extension NewUdManagerFromBackup {
  public static let unimplemented = NewUdManagerFromBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
