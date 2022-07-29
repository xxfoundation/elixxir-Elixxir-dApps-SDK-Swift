import Bindings
import XCTestDynamicOverlay

public struct BroadcastListener {
  public init(handle: @escaping (Result<BroadcastMessage, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<BroadcastMessage, NSError>) -> Void
}

extension BroadcastListener {
  public static let unimplemented = BroadcastListener(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension BroadcastListener {
  func makeBindingsBroadcastListener() -> BindingsBroadcastListenerProtocol {
    class CallbackObject: NSObject, BindingsBroadcastListenerProtocol {
      init(_ callback: BroadcastListener) {
        self.callback = callback
      }

      let callback: BroadcastListener

      func callback(_ p0: Data?, p1: Error?) {
        if let error = p1 {
          callback.handle(.failure(error as NSError))
        } else if let data = p0 {
          do {
            callback.handle(.success(try BroadcastMessage.decode(data)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsBroadcastListener received `nil` data and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
