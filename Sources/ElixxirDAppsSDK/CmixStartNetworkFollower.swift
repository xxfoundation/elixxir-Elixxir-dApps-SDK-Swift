import Bindings
import XCTestDynamicOverlay

public struct CmixStartNetworkFollower {
  public var start: (Int) throws -> Void

  public func callAsFunction(timeoutMS: Int) throws {
    try start(timeoutMS)
  }
}

extension CmixStartNetworkFollower {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixStartNetworkFollower {
    CmixStartNetworkFollower { timeoutMS in
      try bindingsCmix.startNetworkFollower(timeoutMS)
    }
  }
}

extension CmixStartNetworkFollower {
  public static let unimplemented = CmixStartNetworkFollower(
    start: XCTUnimplemented("\(Self.self)")
  )
}
