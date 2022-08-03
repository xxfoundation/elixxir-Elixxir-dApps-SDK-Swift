import Bindings
import XCTestDynamicOverlay

public struct ReceiveFileCallback {
  public init(handle: @escaping (Result<ReceivedFile, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<ReceivedFile, NSError>) -> Void
}

extension ReceiveFileCallback {
  public static let unimplemented = ReceiveFileCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension ReceiveFileCallback {
  func makeBindingsReceiveFileCallback() -> BindingsReceiveFileCallbackProtocol {
    class CallbackObject: NSObject, BindingsReceiveFileCallbackProtocol {
      init(_ callback: ReceiveFileCallback) {
        self.callback = callback
      }

      let callback: ReceiveFileCallback

      func callback(_ payload: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let data = payload {
          do {
            callback.handle(.success(try ReceivedFile.decode(data)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsReceiveFileCallback received `nil` payload and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
