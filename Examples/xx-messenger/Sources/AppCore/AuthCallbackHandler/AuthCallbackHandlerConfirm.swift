import Foundation
import XCTestDynamicOverlay
import XXClient
import XXModels

public struct AuthCallbackHandlerConfirm {
  public var run: (XXClient.Contact) throws -> Void

  public func callAsFunction(_ contact: XXClient.Contact) throws {
    try run(contact)
  }
}

extension AuthCallbackHandlerConfirm {
  public static func live(db: DBManagerGetDB) -> AuthCallbackHandlerConfirm {
    AuthCallbackHandlerConfirm { xxContact in
      let id = try xxContact.getId()
      guard var dbContact = try db().fetchContacts(.init(id: [id])).first else {
        return
      }
      dbContact.authStatus = .friend
      dbContact = try db().saveContact(dbContact)
    }
  }
}

extension AuthCallbackHandlerConfirm {
  public static let unimplemented = AuthCallbackHandlerConfirm(
    run: XCTUnimplemented("\(Self.self)")
  )
}
