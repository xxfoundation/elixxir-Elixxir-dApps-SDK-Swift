import CustomDump
import XCTest
import XXModels
import XXClient
@testable import AppCore

final class AuthCallbackHandlerResetTests: XCTestCase {
  func testReset() throws {
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let dbContact = XXModels.Contact(
      id: "id".data(using: .utf8)!,
      authStatus: .friend
    )
    let reset = AuthCallbackHandlerReset.live(
      db: .init {
        var db: Database = .failing
        db.fetchContacts.run = { query in
          didFetchContacts.append(query)
          return [dbContact]
        }
        db.saveContact.run = { contact in
          didSaveContact.append(contact)
          return contact
        }
        return db
      }
    )
    var xxContact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    xxContact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }

    try reset(xxContact)

    XCTAssertNoDifference(didFetchContacts, [.init(id: ["id".data(using: .utf8)!])])
    var expectedSavedContact = dbContact
    expectedSavedContact.authStatus = .stranger
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])
  }

  func testResetWhenContactNotInDatabase() throws {
    let reset = AuthCallbackHandlerReset.live(
      db: .init {
        var db: Database = .failing
        db.fetchContacts.run = { _ in [] }
        return db
      }
    )
    var contact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }

    try reset(contact)
  }
}
