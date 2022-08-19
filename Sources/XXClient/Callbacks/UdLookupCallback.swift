import Bindings
import XCTestDynamicOverlay

public struct UdLookupCallback {
  public init(handle: @escaping (Result<Data, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<Data, NSError>) -> Void
}

extension UdLookupCallback {
  public static let unimplemented = UdLookupCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension UdLookupCallback {
  func makeBindingsUdLookupCallback() -> BindingsUdLookupCallbackProtocol {
    class CallbackObject: NSObject, BindingsUdLookupCallbackProtocol {
      init(_ callback: UdLookupCallback) {
        self.callback = callback
      }

      let callback: UdLookupCallback

      func callback(_ contactBytes: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let data = contactBytes {
          callback.handle(.success(data))
        } else {
          fatalError("BindingsUdLookupCallback received `nil` data and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
