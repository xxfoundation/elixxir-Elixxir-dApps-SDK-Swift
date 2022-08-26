import Bindings
import XCTestDynamicOverlay

public struct UdSearchCallback {
  public init(handle: @escaping (Result<[Contact], NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<[Contact], NSError>) -> Void
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
            let contactsData = try JSONDecoder().decode([Data].self, from: data)
            let contacts: [Contact] = contactsData.map { Contact.live($0) }
            callback.handle(.success(contacts))
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
