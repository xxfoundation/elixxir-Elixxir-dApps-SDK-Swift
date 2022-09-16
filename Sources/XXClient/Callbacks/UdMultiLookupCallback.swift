import Bindings
import XCTestDynamicOverlay

public struct UdMultiLookupCallback {
  public struct Result: Equatable {
    public init(
      contacts: [Contact],
      failedIds: [Data],
      errors: [NSError]
    ) {
      self.contacts = contacts
      self.failedIds = failedIds
      self.errors = errors
    }

    public var contacts: [Contact]
    public var failedIds: [Data]
    public var errors: [NSError]
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
        var result = UdMultiLookupCallback.Result(
          contacts: [],
          failedIds: [],
          errors: []
        )
        if let err = err {
          result.errors.append(err as NSError)
        }
        if let contactListJSON = contactListJSON {
          do {
            result.contacts = try JSONDecoder()
              .decode([Data].self, from: contactListJSON)
              .map { Contact.live($0) }
          } catch {
            result.errors.append(error as NSError)
          }
        }
        if let failedIDs = failedIDs {
          do {
            result.failedIds = try JSONDecoder().decode([Data].self, from: failedIDs)
          } catch {
            result.errors.append(error as NSError)
          }
        }
        callback.handle(result)
      }
    }

    return CallbackObject(self)
  }
}
