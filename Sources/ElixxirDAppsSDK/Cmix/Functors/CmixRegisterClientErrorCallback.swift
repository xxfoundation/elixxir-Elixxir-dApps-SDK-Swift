import Bindings
import XCTestDynamicOverlay

public struct CmixRegisterClientErrorCallback {
  public var run: (ClientErrorCallback) -> Void

  public func callAsFunction(
    _ callback: ClientErrorCallback
  ) {
    run(callback)
  }
}

extension CmixRegisterClientErrorCallback {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixRegisterClientErrorCallback {
    CmixRegisterClientErrorCallback { callback in
      bindingsCmix.registerClientErrorCallback(
        callback.makeBindingsClientError()
      )
    }
  }
}

extension CmixRegisterClientErrorCallback {
  public static let unimplemented = CmixRegisterClientErrorCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
