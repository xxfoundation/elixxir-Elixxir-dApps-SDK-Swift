import Bindings
import XCTestDynamicOverlay

public struct RestlikeCallback {
  public init(handle: @escaping (Result<RestlikeMessage, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<RestlikeMessage, NSError>) -> Void
}

extension RestlikeCallback {
  public static let unimplemented = RestlikeCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension RestlikeCallback {
  func makeBindingsRestlikeCallback() -> BindingsRestlikeCallbackProtocol {
    class Callback: NSObject, BindingsRestlikeCallbackProtocol {
      init(_ callback: RestlikeCallback) {
        self.callback = callback
      }

      let callback: RestlikeCallback

      func callback(_ p0: Data?, p1: Error?) {
        if let error = p1 {
          callback.handle(.failure(error as NSError))
        } else if let messageData = p0 {
          do {
            callback.handle(.success(try RestlikeMessage.decode(messageData)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsRestlikeCallback received `nil` message and `nil` error")
        }
      }
    }

    return Callback(self)
  }
}
