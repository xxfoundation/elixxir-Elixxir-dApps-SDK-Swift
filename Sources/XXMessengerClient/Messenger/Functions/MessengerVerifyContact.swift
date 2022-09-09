import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerVerifyContact {
  public enum Error: Swift.Error, Equatable {
    case notConnected
    case notLoggedIn
  }

  public var run: (Contact) throws -> Bool

  public func callAsFunction(_ contact: Contact) throws -> Bool {
    try run(contact)
  }
}

extension MessengerVerifyContact {
  public static func live(_ env: MessengerEnvironment) -> MessengerVerifyContact {
    MessengerVerifyContact { contact in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      let facts = try contact.getFacts()
      let verifiedContact: Contact?
      if facts.isEmpty {
        var lookupResult: Result<Contact, NSError>!
        let semaphore = DispatchSemaphore(value: 0)
        _ = try env.lookupUD(
          e2eId: e2e.getId(),
          udContact: try ud.getContact(),
          lookupId: try contact.getId(),
          singleRequestParamsJSON: env.getSingleUseParams(),
          callback: .init { result in
            lookupResult = result
            semaphore.signal()
          }
        )
        semaphore.wait()
        verifiedContact = try lookupResult.get()
      } else {
        var searchResult: Result<[Contact], NSError>!
        let semaphore = DispatchSemaphore(value: 0)
        _ = try env.searchUD(
          e2eId: e2e.getId(),
          udContact: try ud.getContact(),
          facts: facts,
          singleRequestParamsJSON: env.getSingleUseParams(),
          callback: .init { result in
            searchResult = result
            semaphore.signal()
          }
        )
        semaphore.wait()
        verifiedContact = try searchResult.get().first
      }

      guard let verifiedContact = verifiedContact else {
        return false
      }

      return try e2e.verifyOwnership(
        received: contact,
        verified: verifiedContact,
        e2eId: e2e.getId()
      )
    }
  }
}

extension MessengerVerifyContact {
  public static let unimplemented = MessengerVerifyContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
