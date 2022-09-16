import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerLookupContacts {
  public enum Error: Swift.Error, Equatable {
    case notConnected
    case notLoggedIn
  }

  public var run: ([Data]) throws -> UdMultiLookupCallback.Result

  public func callAsFunction(ids: [Data]) throws -> UdMultiLookupCallback.Result {
    try run(ids)
  }
}

extension MessengerLookupContacts {
  public static func live(_ env: MessengerEnvironment) -> MessengerLookupContacts {
    MessengerLookupContacts { ids in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      var callbackResult: UdMultiLookupCallback.Result!
      let semaphore = DispatchSemaphore(value: 0)
      _ = try env.multiLookupUD(
        params: MultiLookupUD.Params(
          e2eId: e2e.getId(),
          udContact: try ud.getContact(),
          lookupIds: ids,
          singleRequestParams: env.getSingleUseParams()
        ),
        callback: UdMultiLookupCallback { result in
          callbackResult = result
          semaphore.signal()
        }
      )
      semaphore.wait()
      return callbackResult
    }
  }
}

extension MessengerLookupContacts {
  public static let unimplemented = MessengerLookupContacts(
    run: XCTUnimplemented("\(Self.self)")
  )
}
