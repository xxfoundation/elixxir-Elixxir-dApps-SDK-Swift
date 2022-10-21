import ChatFeature
import CheckContactAuthFeature
import Combine
import ComposableArchitecture
import ConfirmRequestFeature
import ContactLookupFeature
import CustomDump
import ResetAuthFeature
import SendRequestFeature
import VerifyContactFeature
import XCTest
import XXClient
import XXModels
@testable import ContactFeature

final class ContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: ContactComponent()
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    let dbContactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchContactsPublisher.run = { query in
        dbDidFetchContacts.append(query)
        return dbContactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(dbDidFetchContacts, [
      .init(id: ["contact-id".data(using: .utf8)!])
    ])

    let dbContact = XXModels.Contact(id: "contact-id".data(using: .utf8)!)
    dbContactsPublisher.send([dbContact])

    store.receive(.dbContactFetched(dbContact)) {
      $0.dbContact = dbContact
    }

    dbContactsPublisher.send(completion: .finished)
  }

  func testImportFacts() {
    let dbContact: XXModels.Contact = .init(
      id: "contact-id".data(using: .utf8)!
    )

    var xxContact: XXClient.Contact = .unimplemented("contact-data".data(using: .utf8)!)
    xxContact.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "contact-username"),
        Fact(type: .email, value: "contact-email"),
        Fact(type: .phone, value: "contact-phone"),
      ]
    }

    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        dbContact: dbContact,
        xxContact: xxContact
      ),
      reducer: ContactComponent()
    )

    var dbDidSaveContact: [XXModels.Contact] = []

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.saveContact.run = { contact in
        dbDidSaveContact.append(contact)
        return contact
      }
      return db
    }

    store.send(.importFactsTapped)

    var expectedSavedContact = dbContact
    expectedSavedContact.marshaled = xxContact.data
    expectedSavedContact.username = "contact-username"
    expectedSavedContact.email = "contact-email"
    expectedSavedContact.phone = "contact-phone"

    XCTAssertNoDifference(dbDidSaveContact, [expectedSavedContact])
  }

  func testLookupTapped() {
    let contactId = "contact-id".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: contactId
      ),
      reducer: ContactComponent()
    )

    store.send(.lookupTapped) {
      $0.lookup = ContactLookupComponent.State(id: contactId)
    }
  }

  func testLookupDismissed() {
    let contactId = "contact-id".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: contactId,
        lookup: ContactLookupComponent.State(id: contactId)
      ),
      reducer: ContactComponent()
    )

    store.send(.lookupDismissed) {
      $0.lookup = nil
    }
  }

  func testLookupDidLookup() {
    let contactId = "contact-id".data(using: .utf8)!
    let contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    let store = TestStore(
      initialState: ContactComponent.State(
        id: contactId,
        lookup: ContactLookupComponent.State(id: contactId)
      ),
      reducer: ContactComponent()
    )

    store.send(.lookup(.didLookup(contact))) {
      $0.xxContact = contact
      $0.lookup = nil
    }
  }

  func testSendRequestWithDBContact() {
    var dbContact = XXModels.Contact(id: "contact-id".data(using: .utf8)!)
    dbContact.marshaled = "contact-data".data(using: .utf8)!

    let store = TestStore(
      initialState: ContactComponent.State(
        id: dbContact.id,
        dbContact: dbContact
      ),
      reducer: ContactComponent()
    )

    store.send(.sendRequestTapped) {
      $0.sendRequest = SendRequestComponent.State(contact: .live(dbContact.marshaled!))
    }
  }

  func testSendRequestWithXXContact() {
    let xxContact = XXClient.Contact.unimplemented("contact-id".data(using: .utf8)!)

    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        xxContact: xxContact
      ),
      reducer: ContactComponent()
    )

    store.send(.sendRequestTapped) {
      $0.sendRequest = SendRequestComponent.State(contact: xxContact)
    }
  }

  func testSendRequestDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        sendRequest: SendRequestComponent.State(
          contact: .unimplemented("contact-id".data(using: .utf8)!)
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.sendRequestDismissed) {
      $0.sendRequest = nil
    }
  }

  func testSendRequestSucceeded() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        sendRequest: SendRequestComponent.State(
          contact: .unimplemented("contact-id".data(using: .utf8)!)
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.sendRequest(.sendSucceeded)) {
      $0.sendRequest = nil
    }
  }

  func testVerifyContactTapped() {
    let contactData = "contact-data".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: Data(),
        dbContact: XXModels.Contact(
          id: Data(),
          marshaled: contactData
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.verifyContactTapped) {
      $0.verifyContact = VerifyContactComponent.State(
        contact: .unimplemented(contactData)
      )
    }
  }

  func testVerifyContactDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        verifyContact: VerifyContactComponent.State(
          contact: .unimplemented("contact-data".data(using: .utf8)!)
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.verifyContactDismissed) {
      $0.verifyContact = nil
    }
  }

  func testCheckAuthTapped() {
    let contactData = "contact-data".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: Data(),
        dbContact: XXModels.Contact(
          id: Data(),
          marshaled: contactData
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.checkAuthTapped) {
      $0.checkAuth = CheckContactAuthComponent.State(
        contact: .unimplemented(contactData)
      )
    }
  }

  func testCheckAuthDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        checkAuth: CheckContactAuthComponent.State(
          contact: .unimplemented("contact-data".data(using: .utf8)!)
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.checkAuthDismissed) {
      $0.checkAuth = nil
    }
  }

  func testResetAuthTapped() {
    let contactData = "contact-data".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: Data(),
        dbContact: XXModels.Contact(
          id: Data(),
          marshaled: contactData
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.resetAuthTapped) {
      $0.resetAuth = ResetAuthComponent.State(
        partner: .unimplemented(contactData)
      )
    }
  }

  func testResetAuthDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: Data(),
        resetAuth: ResetAuthComponent.State(
          partner: .unimplemented(Data())
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.resetAuthDismissed) {
      $0.resetAuth = nil
    }
  }

  func testConfirmRequestTapped() {
    let contactData = "contact-data".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: Data(),
        dbContact: XXModels.Contact(
          id: Data(),
          marshaled: contactData
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.confirmRequestTapped) {
      $0.confirmRequest = ConfirmRequestComponent.State(
        contact: .unimplemented(contactData)
      )
    }
  }

  func testConfirmRequestDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        confirmRequest: ConfirmRequestComponent.State(
          contact: .unimplemented("contact-data".data(using: .utf8)!)
        )
      ),
      reducer: ContactComponent()
    )

    store.send(.confirmRequestDismissed) {
      $0.confirmRequest = nil
    }
  }

  func testChatTapped() {
    let contactId = "contact-id".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactComponent.State(
        id: contactId
      ),
      reducer: ContactComponent()
    )

    store.send(.chatTapped) {
      $0.chat = ChatComponent.State(id: .contact(contactId))
    }
  }

  func testChatDismissed() {
    let store = TestStore(
      initialState: ContactComponent.State(
        id: "contact-id".data(using: .utf8)!,
        chat: ChatComponent.State(id: .contact("contact-id".data(using: .utf8)!))
      ),
      reducer: ContactComponent()
    )

    store.send(.chatDismissed) {
      $0.chat = nil
    }
  }
}
