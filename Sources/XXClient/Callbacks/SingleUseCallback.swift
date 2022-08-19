import Bindings
import XCTestDynamicOverlay

public struct SingleUseCallback {
  public init(handle: @escaping (Result<SingleUseCallbackReport, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<SingleUseCallbackReport, NSError>) -> Void
}

extension SingleUseCallback {
  public static let unimplemented = SingleUseCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension SingleUseCallback {
  func makeBindingsSingleUseCallback() -> BindingsSingleUseCallbackProtocol {
    class CallbackObject: NSObject, BindingsSingleUseCallbackProtocol {
      init(_ callback: SingleUseCallback) {
        self.callback = callback
      }

      let callback: SingleUseCallback

      func callback(_ callbackReport: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let callbackReport = callbackReport {
          do {
            callback.handle(.success(try SingleUseCallbackReport.decode(callbackReport)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsSingleUseCallback received `nil` callbackReport and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
