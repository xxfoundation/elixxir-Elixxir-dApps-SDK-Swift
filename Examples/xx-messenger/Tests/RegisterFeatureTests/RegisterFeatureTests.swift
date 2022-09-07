import ComposableArchitecture
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import RegisterFeature

final class RegisterFeatureTests: XCTestCase {
  func testRegister() throws {
    let store = TestStore(
      initialState: RegisterState(),
      reducer: registerReducer,
      environment: .unimplemented
    )

    let now = Date()
    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var didSetFactsOnContact: [[XXClient.Fact]] = []
    var dbDidSaveContact: [XXModels.Contact] = []
    var messengerDidRegisterUsername: [String] = []

    store.environment.now = { now }
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.register.run = { username in
      messengerDidRegisterUsername.append(username)
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
        contact.getFactsFromContact.run = { _ in [] }
        contact.setFactsOnContact.run = { data, facts in
          didSetFactsOnContact.append(facts)
          return data
        }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .failing
      db.saveContact.run = { contact in
        dbDidSaveContact.append(contact)
        return contact
      }
      return db
    }

    store.send(.set(\.$username, "NewUser")) {
      $0.username = "NewUser"
    }

    store.send(.registerTapped) {
      $0.isRegistering = true
    }

    XCTAssertNoDifference(messengerDidRegisterUsername, [])
    XCTAssertNoDifference(dbDidSaveContact, [])

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidRegisterUsername, ["NewUser"])
    XCTAssertNoDifference(didSetFactsOnContact, [[Fact(fact: "NewUser", type: 0)]])
    XCTAssertNoDifference(dbDidSaveContact, [
      XXModels.Contact(
        id: "contact-id".data(using: .utf8)!,
        marshaled: "contact-data".data(using: .utf8)!,
        username: "NewUser",
        createdAt: now
      )
    ])

    mainQueue.advance()

    store.receive(.finished)
  }

  func testGetDbFailure() throws {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    let store = TestStore(
      initialState: RegisterState(),
      reducer: registerReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.db.run = { throw error }

    store.send(.registerTapped) {
      $0.isRegistering = true
    }

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.failed(error.localizedDescription)) {
      $0.isRegistering = false
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerRegisterFailure() throws {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    let store = TestStore(
      initialState: RegisterState(),
      reducer: registerReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.db.run = { .failing }
    store.environment.messenger.register.run = { _ in throw error }

    store.send(.registerTapped) {
      $0.isRegistering = true
    }

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.failed(error.localizedDescription)) {
      $0.isRegistering = false
      $0.failure = error.localizedDescription
    }
  }
}
