import Bindings
import XCTestDynamicOverlay

public struct UdMultiLookupCallback {
  public enum Result: Equatable {
    case success([Contact])
    case failure(error: NSError, failedIDs: [Data])
  }

  public init(handle: @escaping (Result) -> Void) {
    self.handle = handle
  }

  public var handle: (Result) -> Void
}

extension UdMultiLookupCallback {
  public static let unimplemented = UdMultiLookupCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension UdMultiLookupCallback {
  func makeBindingsUdMultiLookupCallback() -> BindingsUdMultiLookupCallbackProtocol {
    class CallbackObject: NSObject, BindingsUdMultiLookupCallbackProtocol {
      init(_ callback: UdMultiLookupCallback) {
        self.callback = callback
      }

      let callback: UdMultiLookupCallback

      func callback(_ contactListJSON: Data?, failedIDs: Data?, err: Error?) {
        if let err = err {
          callback.handle(.failure(
            error: err as NSError,
            failedIDs: failedIDs
              .map { (try? JSONDecoder().decode([Data].self, from: $0)) ?? [] } ?? []
          ))
        } else if let contactListJSON = contactListJSON {
          do {
            let contactsData = try JSONDecoder().decode([Data].self, from: contactListJSON)
            let contacts: [Contact] = contactsData.map { Contact.live($0) }
            callback.handle(.success(contacts))
          } catch {
            callback.handle(.failure(error: error as NSError, failedIDs: []))
          }
        } else {
          fatalError("BindingsUdMultiLookupCallbackProtocol received `nil` contactListJSON and `nil` error")
        }
      }
    }

    return CallbackObject(self)
  }
}
