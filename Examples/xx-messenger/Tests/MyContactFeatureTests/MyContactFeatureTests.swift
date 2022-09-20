import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import MyContactFeature

final class MyContactFeatureTests: XCTestCase {
  func testStart() {
    let contactId = "contact-id".data(using: .utf8)!

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    let dbContactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactId }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContactsPublisher.run = { query in
        dbDidFetchContacts.append(query)
        return dbContactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(dbDidFetchContacts, [.init(id: [contactId])])

    dbContactsPublisher.send([])

    store.receive(.contactFetched(nil))

    let contact = XXModels.Contact(id: contactId)
    dbContactsPublisher.send([contact])

    store.receive(.contactFetched(contact)) {
      $0.contact = contact
    }

    dbContactsPublisher.send(completion: .finished)
  }

  func testRegisterEmail() {
    let email = "test@email.com"

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.send(.set(\.$email, email)) {
      $0.email = email
    }

    store.send(.registerEmailTapped)
  }

  func testUnregisterEmail() {
    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.send(.unregisterEmailTapped)
  }

  func testRegisterPhone() {
    let phone = "123456789"

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.send(.set(\.$phone, phone)) {
      $0.phone = phone
    }

    store.send(.registerPhoneTapped)
  }

  func testUnregisterPhone() {
    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.send(.unregisterPhoneTapped)
  }

  func testLoadFactsFromClient() {
    let contactId = "contact-id".data(using: .utf8)!
    let dbContact = XXModels.Contact(id: contactId)
    let email = "test@email.com"
    let phone = "123456789"

    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactId }
        return contact
      }
      return e2e
    }
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getFacts.run = {
        [
          Fact(type: .email, value: email),
          Fact(type: .phone, value: phone),
        ]
      }
      return ud
    }
    store.environment.db.run = {
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

    store.send(.loadFactsTapped) {
      $0.isLoadingFacts = true
    }

    XCTAssertNoDifference(didFetchContacts, [.init(id: [contactId])])
    var expectedSavedContact = dbContact
    expectedSavedContact.email = email
    expectedSavedContact.phone = phone
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])

    store.receive(.set(\.$isLoadingFacts, false)) {
      $0.isLoadingFacts = false
    }
  }

  func testErrorAlert() {
    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    let failure = "Something went wrong"

    store.send(.didFail(failure)) {
      $0.alert = .error(failure)
    }

    store.send(.alertDismissed) {
      $0.alert = nil
    }
  }
}
