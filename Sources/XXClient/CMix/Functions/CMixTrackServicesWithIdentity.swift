import Bindings
import XCTestDynamicOverlay

public struct CMixTrackServicesWithIdentity {
  public var run: (Int, TrackServicesCallback) throws -> Void

  public func callAsFunction(
    e2eId: Int,
    callback: TrackServicesCallback
  ) throws -> Void {
    try run(e2eId, callback)
  }
}

extension CMixTrackServicesWithIdentity {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixTrackServicesWithIdentity {
    CMixTrackServicesWithIdentity { e2eId, callback in
      try bindingsCMix.trackServices(
        withIdentity: e2eId,
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
