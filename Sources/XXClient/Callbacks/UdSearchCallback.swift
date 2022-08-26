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
  func makeBindingsUdSearchCallback(
    makeContact: MakeContact = .live()
  ) -> BindingsUdSearchCallbackProtocol {
    class CallbackObject: NSObject, BindingsUdSearchCallbackProtocol {
      init(
        callback: UdSearchCallback,
        makeContact: MakeContact
      ) {
        self.callback = callback
        self.makeContact = makeContact
      }

      let callback: UdSearchCallback
      let makeContact: MakeContact

      func callback(_ contactListJSON: Data?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
        } else if let data = contactListJSON {
          do {
            let contactsData = try JSONDecoder().decode([Data].self, from: data)
            let contacts: [Contact] = contactsData.map { makeContact($0) }
            callback.handle(.success(contacts))
          } catch {
            callback.handle(.failure(error as NSError))
          }
        } else {
          fatalError("BindingsUdSearchCallback received `nil` data and `nil` error")
        }
      }
    }

    return CallbackObject(
      callback: self,
      makeContact: makeContact
    )
  }
}
