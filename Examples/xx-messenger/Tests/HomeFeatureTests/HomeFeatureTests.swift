import ComposableArchitecture
import RegisterFeature
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import HomeFeature

final class HomeFeatureTests: XCTestCase {
  func testStartUnregistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { false }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)

    mainQueue.advance()

    store.receive(.set(\.$register, RegisterState())) {
      $0.register = RegisterState()
    }
  }

  func testStartRegistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0
    var messengerDidLogIn = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)

    mainQueue.advance()
  }

  func testRegisterFinished() {
    let store = TestStore(
      initialState: HomeState(
        register: RegisterState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidLogIn = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }

    store.send(.register(.finished)) {
      $0.register = nil
    }

    store.receive(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidLogIn, 1)

    mainQueue.advance()
  }

  func testStartMessengerStartFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerConnectFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerIsRegisteredFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerLogInFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testAccountDeletion() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    var udDidPermanentDeleteAccount: [Fact] = []
    var messengerDidDestroy = 0
    var dbDidDrop = 0

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContacts.run = { query in
        dbDidFetchContacts.append(query)
        return [
          XXModels.Contact(
            id: "contact-id".data(using: .utf8)!,
            marshaled: "contact-data".data(using: .utf8)!,
            username: "MyUsername"
          )
        ]
      }
      db.drop.run = {
        dbDidDrop += 1
      }
      return db
    }
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.permanentDeleteAccount.run = { usernameFact in
        udDidPermanentDeleteAccount.append(usernameFact)
      }
      return ud
    }
    store.environment.messenger.destroy.run = {
      messengerDidDestroy += 1
    }

    store.send(.deleteAccountButtonTapped) {
      $0.alert = .confirmAccountDeletion()
    }

    store.send(.set(\.$alert, nil)) {
      $0.alert = nil
    }

    store.send(.deleteAccountConfirmed) {
      $0.isDeletingAccount = true
    }

    XCTAssertNoDifference(dbDidFetchContacts, [.init(id: ["contact-id".data(using: .utf8)!])])
    XCTAssertNoDifference(udDidPermanentDeleteAccount, [Fact(fact: "MyUsername", type: 0)])
    XCTAssertNoDifference(messengerDidDestroy, 1)
    XCTAssertNoDifference(dbDidDrop, 1)

    store.receive(.didDeleteAccount) {
      $0.isDeletingAccount = false
    }
  }

  func testAccountDeletionFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in throw error }
        return contact
      }
      return e2e
    }

    store.send(.deleteAccountConfirmed) {
      $0.isDeletingAccount = true
    }

    store.receive(.set(\.$isDeletingAccount, false)) {
      $0.isDeletingAccount = false
    }

    store.receive(.set(\.$alert, .accountDeletionFailed(error))) {
      $0.alert = .accountDeletionFailed(error)
    }
  }
}
