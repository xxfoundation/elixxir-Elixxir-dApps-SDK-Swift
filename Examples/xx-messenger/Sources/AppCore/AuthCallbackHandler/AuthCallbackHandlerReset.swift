import Foundation
import XCTestDynamicOverlay
import XXClient
import XXModels

public struct AuthCallbackHandlerReset {
  public var run: (XXClient.Contact) throws -> Void

  public func callAsFunction(_ contact: XXClient.Contact) throws {
    try run(contact)
  }
}

extension AuthCallbackHandlerReset {
  public static func live(db: DBManagerGetDB) -> AuthCallbackHandlerReset {
    AuthCallbackHandlerReset { xxContact in
      let id = try xxContact.getId()
      guard var dbContact = try db().fetchContacts(.init(id: [id])).first else {
        return
      }
      dbContact.authStatus = .friend
      dbContact = try db().saveContact(dbContact)
    }
  }
}

extension AuthCallbackHandlerReset {
  public static let unimplemented = AuthCallbackHandlerReset(
    run: XCTUnimplemented("\(Self.self)")
  )
}
