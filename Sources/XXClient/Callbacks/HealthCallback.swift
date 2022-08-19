import Bindings
import XCTestDynamicOverlay

public struct HealthCallback {
  public init(handle: @escaping (Bool) -> Void) {
    self.handle = handle
  }

  public var handle: (Bool) -> Void
}

extension HealthCallback {
  public static let unimplemented = HealthCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension HealthCallback {
  func makeBindingsHealthCallback() -> BindingsNetworkHealthCallbackProtocol {
    class CallbackObject: NSObject, BindingsNetworkHealthCallbackProtocol {
      init(_ callback: HealthCallback) {
        self.callback = callback
      }

      let callback: HealthCallback

      func callback(_ p0: Bool) {
        callback.handle(p0)
      }
    }

    return CallbackObject(self)
  }
}
