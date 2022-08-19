import Bindings
import XCTestDynamicOverlay

public struct CMixRegisterClientErrorCallback {
  public var run: (ClientErrorCallback) -> Void

  public func callAsFunction(
    _ callback: ClientErrorCallback
  ) {
    run(callback)
  }
}

extension CMixRegisterClientErrorCallback {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixRegisterClientErrorCallback {
    CMixRegisterClientErrorCallback { callback in
      bindingsCMix.registerClientErrorCallback(
        callback.makeBindingsClientError()
      )
    }
  }
}

extension CMixRegisterClientErrorCallback {
  public static let unimplemented = CMixRegisterClientErrorCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
