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
      var db: Database = .unimplemented
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
    let confirmationID = "123"

    var didSendRegisterFact: [Fact] = []

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.sendRegisterFact.run = { fact in
        didSendRegisterFact.append(fact)
        return confirmationID
      }
      return ud
    }

    store.send(.set(\.$focusedField, .email)) {
      $0.focusedField = .email
    }

    store.send(.set(\.$email, email)) {
      $0.email = email
    }

    store.send(.registerEmailTapped) {
      $0.focusedField = nil
      $0.isRegisteringEmail = true
    }

    XCTAssertNoDifference(didSendRegisterFact, [.init(type: .email, value: email)])

    store.receive(.set(\.$emailConfirmationID, confirmationID)) {
      $0.emailConfirmationID = confirmationID
    }

    store.receive(.set(\.$isRegisteringEmail, false)) {
      $0.isRegisteringEmail = false
    }
  }

  func testRegisterEmailFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.sendRegisterFact.run = { _ in throw failure }
      return ud
    }

    store.send(.registerEmailTapped) {
      $0.isRegisteringEmail = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isRegisteringEmail, false)) {
      $0.isRegisteringEmail = false
    }
  }

  func testConfirmEmail() {
    let contactID = "contact-id".data(using: .utf8)!
    let email = "test@email.com"
    let confirmationID = "123"
    let confirmationCode = "321"
    let dbContact = XXModels.Contact(id: contactID)

    var didConfirmWithID: [String] = []
    var didConfirmWithCode: [String] = []
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: MyContactState(
        email: email,
        emailConfirmationID: confirmationID
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.confirmFact.run = { id, code in
        didConfirmWithID.append(id)
        didConfirmWithCode.append(code)
      }
      return ud
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactID }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
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

    store.send(.set(\.$focusedField, .emailCode)) {
      $0.focusedField = .emailCode
    }

    store.send(.set(\.$emailConfirmationCode, confirmationCode)) {
      $0.emailConfirmationCode = confirmationCode
    }

    store.send(.confirmEmailTapped) {
      $0.focusedField = nil
      $0.isConfirmingEmail = true
    }

    XCTAssertNoDifference(didConfirmWithID, [confirmationID])
    XCTAssertNoDifference(didConfirmWithCode, [confirmationCode])
    XCTAssertNoDifference(didFetchContacts, [.init(id: [contactID])])
    var expectedSavedContact = dbContact
    expectedSavedContact.email = email
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])

    store.receive(.set(\.$email, "")) {
      $0.email = ""
    }
    store.receive(.set(\.$emailConfirmationID, nil)) {
      $0.emailConfirmationID = nil
    }
    store.receive(.set(\.$emailConfirmationCode, "")) {
      $0.emailConfirmationCode = ""
    }
    store.receive(.set(\.$isConfirmingEmail, false)) {
      $0.isConfirmingEmail = false
    }
  }

  func testConfirmEmailFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(
        emailConfirmationID: "123"
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.confirmFact.run = { _, _ in throw failure }
      return ud
    }

    store.send(.confirmEmailTapped) {
      $0.isConfirmingEmail = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isConfirmingEmail, false)) {
      $0.isConfirmingEmail = false
    }
  }

  func testUnregisterEmail() {
    let contactID = "contact-id".data(using: .utf8)!
    let email = "test@email.com"
    let dbContact = XXModels.Contact(id: contactID, email: email)

    var didRemoveFact: [Fact] = []
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: MyContactState(
        contact: dbContact
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.removeFact.run = { didRemoveFact.append($0) }
      return ud
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactID }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
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

    store.send(.unregisterEmailTapped) {
      $0.isUnregisteringEmail = true
    }

    XCTAssertNoDifference(didRemoveFact, [.init(type: .email, value: email)])
    XCTAssertNoDifference(didFetchContacts, [.init(id: [contactID])])
    var expectedSavedContact = dbContact
    expectedSavedContact.email = nil
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])

    store.receive(.set(\.$isUnregisteringEmail, false)) {
      $0.isUnregisteringEmail = false
    }
  }

  func testUnregisterEmailFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(
        contact: .init(id: Data(), email: "test@email.com")
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.removeFact.run = { _ in throw failure }
      return ud
    }

    store.send(.unregisterEmailTapped) {
      $0.isUnregisteringEmail = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isUnregisteringEmail, false)) {
      $0.isUnregisteringEmail = false
    }
  }

  func testRegisterPhone() {
    let phone = "+123456789"
    let confirmationID = "123"

    var didSendRegisterFact: [Fact] = []

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.sendRegisterFact.run = { fact in
        didSendRegisterFact.append(fact)
        return confirmationID
      }
      return ud
    }

    store.send(.set(\.$focusedField, .phone)) {
      $0.focusedField = .phone
    }

    store.send(.set(\.$phone, phone)) {
      $0.phone = phone
    }

    store.send(.registerPhoneTapped) {
      $0.focusedField = nil
      $0.isRegisteringPhone = true
    }

    XCTAssertNoDifference(didSendRegisterFact, [.init(type: .phone, value: phone)])

    store.receive(.set(\.$phoneConfirmationID, confirmationID)) {
      $0.phoneConfirmationID = confirmationID
    }

    store.receive(.set(\.$isRegisteringPhone, false)) {
      $0.isRegisteringPhone = false
    }
  }

  func testRegisterPhoneFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.sendRegisterFact.run = { _ in throw failure }
      return ud
    }

    store.send(.registerPhoneTapped) {
      $0.isRegisteringPhone = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isRegisteringPhone, false)) {
      $0.isRegisteringPhone = false
    }
  }

  func testConfirmPhone() {
    let contactID = "contact-id".data(using: .utf8)!
    let phone = "+123456789"
    let confirmationID = "123"
    let confirmationCode = "321"
    let dbContact = XXModels.Contact(id: contactID)

    var didConfirmWithID: [String] = []
    var didConfirmWithCode: [String] = []
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: MyContactState(
        phone: phone,
        phoneConfirmationID: confirmationID
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.confirmFact.run = { id, code in
        didConfirmWithID.append(id)
        didConfirmWithCode.append(code)
      }
      return ud
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactID }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
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

    store.send(.set(\.$focusedField, .phoneCode)) {
      $0.focusedField = .phoneCode
    }

    store.send(.set(\.$phoneConfirmationCode, confirmationCode)) {
      $0.phoneConfirmationCode = confirmationCode
    }

    store.send(.confirmPhoneTapped) {
      $0.focusedField = nil
      $0.isConfirmingPhone = true
    }

    XCTAssertNoDifference(didConfirmWithID, [confirmationID])
    XCTAssertNoDifference(didConfirmWithCode, [confirmationCode])
    XCTAssertNoDifference(didFetchContacts, [.init(id: [contactID])])
    var expectedSavedContact = dbContact
    expectedSavedContact.phone = phone
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])

    store.receive(.set(\.$phone, "")) {
      $0.phone = ""
    }
    store.receive(.set(\.$phoneConfirmationID, nil)) {
      $0.phoneConfirmationID = nil
    }
    store.receive(.set(\.$phoneConfirmationCode, "")) {
      $0.phoneConfirmationCode = ""
    }
    store.receive(.set(\.$isConfirmingPhone, false)) {
      $0.isConfirmingPhone = false
    }
  }

  func testConfirmPhoneFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(
        phoneConfirmationID: "123"
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.confirmFact.run = { _, _ in throw failure }
      return ud
    }

    store.send(.confirmPhoneTapped) {
      $0.isConfirmingPhone = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isConfirmingPhone, false)) {
      $0.isConfirmingPhone = false
    }
  }
  
  func testUnregisterPhone() {
    let contactID = "contact-id".data(using: .utf8)!
    let phone = "+123456789"
    let dbContact = XXModels.Contact(id: contactID, phone: phone)

    var didRemoveFact: [Fact] = []
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: MyContactState(
        contact: dbContact
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.removeFact.run = { didRemoveFact.append($0) }
      return ud
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in contactID }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
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

    store.send(.unregisterPhoneTapped) {
      $0.isUnregisteringPhone = true
    }

    XCTAssertNoDifference(didRemoveFact, [.init(type: .phone, value: phone)])
    XCTAssertNoDifference(didFetchContacts, [.init(id: [contactID])])
    var expectedSavedContact = dbContact
    expectedSavedContact.phone = nil
    XCTAssertNoDifference(didSaveContact, [expectedSavedContact])

    store.receive(.set(\.$isUnregisteringPhone, false)) {
      $0.isUnregisteringPhone = false
    }
  }

  func testUnregisterPhoneFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: MyContactState(
        contact: .init(id: Data(), phone: "+123456789")
      ),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.removeFact.run = { _ in throw failure }
      return ud
    }

    store.send(.unregisterPhoneTapped) {
      $0.isUnregisteringPhone = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

    store.receive(.set(\.$isUnregisteringPhone, false)) {
      $0.isUnregisteringPhone = false
    }
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
      var db: Database = .unimplemented
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

  func testLoadFactsFromClientFailure() {
    struct Failure: Error {}
    let failure = Failure()

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
        contact.getIdFromContact.run = { _ in throw failure }
        return contact
      }
      return e2e
    }

    store.send(.loadFactsTapped) {
      $0.isLoadingFacts = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.alert = .error(failure.localizedDescription)
    }

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
