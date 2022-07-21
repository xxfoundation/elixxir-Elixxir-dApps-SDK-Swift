import Bindings
import XCTestDynamicOverlay

public struct CmixAddHealthCallback {
  public var run: (HealthCallback) -> Cancellable

  public func callAsFunction(_ callback: HealthCallback) -> Cancellable {
    run(callback)
  }
}

extension CmixAddHealthCallback {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixAddHealthCallback {
    CmixAddHealthCallback { callback in
      let id = bindingsCmix.add(
        callback.makeBindingsHealthCallback()
      )
      return Cancellable {
        bindingsCmix.removeHealthCallback(id)
      }
    }
  }
}

extension CmixAddHealthCallback {
  public static let unimplemented = CmixAddHealthCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
