import Bindings
import XCTestDynamicOverlay

public struct CMixAddHealthCallback {
  public var run: (HealthCallback) -> Cancellable

  public func callAsFunction(_ callback: HealthCallback) -> Cancellable {
    run(callback)
  }
}

extension CMixAddHealthCallback {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixAddHealthCallback {
    CMixAddHealthCallback { callback in
      let id = bindingsCMix.add(
        callback.makeBindingsHealthCallback()
      )
      return Cancellable {
        bindingsCMix.removeHealthCallback(id)
      }
    }
  }
}

extension CMixAddHealthCallback {
  public static let unimplemented = CMixAddHealthCallback(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
