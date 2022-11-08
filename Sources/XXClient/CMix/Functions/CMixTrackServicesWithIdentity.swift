import Bindings
import XCTestDynamicOverlay

public struct CMixTrackServicesWithIdentity {
  public var run: (Int, TrackServicesCallback) throws -> Void

  public func callAsFunction(
    _ identity: Int,
    callback: TrackServicesCallback
  ) throws -> Void {
    try run(identity, callback)
  }
}

extension CMixTrackServicesWithIdentity {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixTrackServicesWithIdentity {
    CMixTrackServicesWithIdentity { identity, callback in
      try bindingsCMix.trackServices(
        withIdentity: identity,
        cb: callback.makeBindingsHealthCallback()
      )
    }
  }
}

extension CMixTrackServicesWithIdentity {
  public static let unimplemented = CMixTrackServicesWithIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
