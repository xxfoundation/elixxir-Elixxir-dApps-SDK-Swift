import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class AuthCallbackHandlerRequestTests: XCTestCase {
  func testRequestFromNewContact() throws {
    let now = Date()
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .unimplemented
        db.fetchContacts.run = { query in
          didFetchContacts.append(query)
          return []
        }
        db.saveContact.run = { contact in
          didSaveContact.append(contact)
          return contact
        }
        return db
      },
      now: { now }
    )
    var xxContact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    xxContact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }
    xxContact.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
      ]
    }

    try request(xxContact)

    XCTAssertNoDifference(didFetchContacts, [.init(id: ["id".data(using: .utf8)!])])
    XCTAssertNoDifference(didSaveContact, [.init(
      id: "id".data(using: .utf8)!,
      marshaled: "contact".data(using: .utf8)!,
      username: "username",
      email: "email",
      phone: "phone",
      authStatus: .stranger,
      createdAt: now
    )])
  }

  func testRequestWhenContactInDatabase() throws {
    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .unimplemented
        db.fetchContacts.run = { _ in [.init(id: "id".data(using: .utf8)!)] }
        return db
      },
      now: XCTUnimplemented("now", placeholder: Date())
    )
    var contact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }

    try request(contact)
  }
}
