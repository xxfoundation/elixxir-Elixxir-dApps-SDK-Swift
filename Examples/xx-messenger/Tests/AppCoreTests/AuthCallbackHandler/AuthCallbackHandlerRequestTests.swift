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
    var didVerifyContact: [XXClient.Contact] = []
    var didSaveContact: [XXModels.Contact] = []

    var messenger: Messenger = .unimplemented
    messenger.waitForNetwork.run = { _ in }
    messenger.waitForNodes.run = { _, _, _, _ in }
    messenger.verifyContact.run = { contact in
      didVerifyContact.append(contact)
      return true
    }

    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .failing
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
      messenger: messenger,
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
    XCTAssertNoDifference(didSaveContact, [
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        username: "username",
        email: "email",
        phone: "phone",
        authStatus: .verificationInProgress,
        createdAt: now
      ),
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        username: "username",
        email: "email",
        phone: "phone",
        authStatus: .verified,
        createdAt: now
      )
    ])
  }

  func testRequestWhenContactInDatabase() throws {
    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .failing
        db.fetchContacts.run = { _ in [.init(id: "id".data(using: .utf8)!)] }
        return db
      },
      messenger: .unimplemented,
      now: XCTUnimplemented("now", placeholder: Date())
    )
    var contact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }

    try request(contact)
  }

  func testRequestFromNewContactVerificationFalse() throws {
    let now = Date()
    var didSaveContact: [XXModels.Contact] = []

    var messenger: Messenger = .unimplemented
    messenger.waitForNetwork.run = { _ in }
    messenger.waitForNodes.run = { _, _, _, _ in }
    messenger.verifyContact.run = { _ in false }

    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .failing
        db.fetchContacts.run = { query in return [] }
        db.saveContact.run = { contact in
          didSaveContact.append(contact)
          return contact
        }
        return db
      },
      messenger: messenger,
      now: { now }
    )
    var xxContact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    xxContact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }
    xxContact.getFactsFromContact.run = { _ in [] }

    try request(xxContact)

    XCTAssertNoDifference(didSaveContact, [
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        authStatus: .verificationInProgress,
        createdAt: now
      ),
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        authStatus: .verificationFailed,
        createdAt: now
      )
    ])
  }

  func testRequestFromNewContactVerificationFailure() throws {
    struct Failure: Error, Equatable {}
    let failure = Failure()
    let now = Date()
    var didSaveContact: [XXModels.Contact] = []

    var messenger: Messenger = .unimplemented
    messenger.waitForNetwork.run = { _ in }
    messenger.waitForNodes.run = { _, _, _, _ in }
    messenger.verifyContact.run = { _ in throw failure }

    let request = AuthCallbackHandlerRequest.live(
      db: .init {
        var db: Database = .failing
        db.fetchContacts.run = { query in return [] }
        db.saveContact.run = { contact in
          didSaveContact.append(contact)
          return contact
        }
        return db
      },
      messenger: messenger,
      now: { now }
    )
    var xxContact = XXClient.Contact.unimplemented("contact".data(using: .utf8)!)
    xxContact.getIdFromContact.run = { _ in "id".data(using: .utf8)! }
    xxContact.getFactsFromContact.run = { _ in [] }

    XCTAssertThrowsError(try request(xxContact)) { error in
      XCTAssertNoDifference(error as? Failure, failure)
    }

    XCTAssertNoDifference(didSaveContact, [
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        authStatus: .verificationInProgress,
        createdAt: now
      ),
      .init(
        id: "id".data(using: .utf8)!,
        marshaled: "contact".data(using: .utf8)!,
        authStatus: .verificationFailed,
        createdAt: now
      )
    ])
  }
}
