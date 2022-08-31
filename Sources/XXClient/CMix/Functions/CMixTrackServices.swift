import Bindings
import XCTestDynamicOverlay

public struct CMixTrackServices {
  public var run: (TrackServicesCallback) -> Void
  
  public func callAsFunction(
    callback: TrackServicesCallback
  ) -> Void {
    run(callback)
  }
}

extension CMixTrackServices {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixTrackServices {
    CMixTrackServices { callback in
      bindingsCMix.trackServices(callback.makeBindingsHealthCallback())
    }
  }
}

extension CMixTrackServices {
  public static let unimplemented = CMixTrackServices(
    run: XCTUnimplemented("\(Self.self)")
  )
}
