import Bindings
import XCTestDynamicOverlay

public struct UdSearchCallback {
  public init(handle: @escaping (Result<[UDSearchResult], NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<[UDSearchResult], NSError>) -> Void
}

extension UdSearchCallback {
  public static let unimplemented = UdSearchCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension UdSearchCallback {
  func makeBindingsUdSearchCallback() -> BindingsUdSearchCallbackProtocol {
    class CallbackObject: NSObject, BindingsUdSearchCallbackProtocol {
      init(_ callback: UdSearchCallback) {
        self.callback = callback
      }

      let callback: UdSearchCallback

      func callback(_ contactListJSON: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let data = contactListJSON {
          do {
            callback.handle(.success(try [UDSearchResult].decode(data)))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsUdSearchCallback received `nil` data and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
