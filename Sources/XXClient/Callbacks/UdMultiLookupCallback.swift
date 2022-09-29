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
        do {
          if let data = contactListJSON,
             let contactListJSON = try JSONDecoder().decode([Data]?.self, from: data) {
            result.contacts = contactListJSON.map { Contact.live($0) }
          }
        } catch {
          result.errors.append(error as NSError)
        }
        do {
          if let data = failedIDs,
             let failedIDs = try JSONDecoder().decode([Data]?.self, from: data) {
            result.failedIds = failedIDs
          }
        } catch {
            result.errors.append(error as NSError)
        }
        callback.handle(result)
      }
    }

    return CallbackObject(self)
  }
}
