import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct AuthCallbackHandlerRequest {
  public var run: (XXClient.Contact) throws -> Void

  public func callAsFunction(_ contact: XXClient.Contact) throws {
    try run(contact)
  }
}

extension AuthCallbackHandlerRequest {
  public static func live(
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> AuthCallbackHandlerRequest {
    AuthCallbackHandlerRequest { xxContact in
      let id = try xxContact.getId()
      guard try db().fetchContacts(.init(id: [id])).isEmpty else {
        return
      }
      var dbContact = XXModels.Contact(id: id)
      dbContact.marshaled = xxContact.data
      dbContact.username = try xxContact.getFact(.username)?.value
      dbContact.email = try xxContact.getFact(.email)?.value
      dbContact.phone = try xxContact.getFact(.phone)?.value
      dbContact.authStatus = .stranger
      dbContact.createdAt = now()
      dbContact = try db().saveContact(dbContact)
    }
  }
}

extension AuthCallbackHandlerRequest {
  public static let unimplemented = AuthCallbackHandlerRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
