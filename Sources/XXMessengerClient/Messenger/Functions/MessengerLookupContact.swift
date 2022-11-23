import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerLookupContact {
  public enum Error: Swift.Error, Equatable {
    case notConnected
    case notLoggedIn
  }

  public var run: (Data) throws -> Contact

  public func callAsFunction(id: Data) throws -> Contact {
    try run(id)
  }
}

extension MessengerLookupContact {
  public static func live(_ env: MessengerEnvironment) -> MessengerLookupContact {
    MessengerLookupContact { id in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      var result: Result<Contact, NSError>!
      let semaphore = DispatchSemaphore(value: 0)
      _ = try env.lookupUD(
        params: LookupUD.Params(
          e2eId: e2e.getId(),
          udContact: try ud.getContact(),
          lookupId: id,
          singleRequestParamsJSON: env.getSingleUseParams()
        ),
        callback: UdLookupCallback { lookupResult in
          result = lookupResult
          semaphore.signal()
        }
      )
      semaphore.wait()
      return try result.get()
    }
  }
}

extension MessengerLookupContact {
  public static let unimplemented = MessengerLookupContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
