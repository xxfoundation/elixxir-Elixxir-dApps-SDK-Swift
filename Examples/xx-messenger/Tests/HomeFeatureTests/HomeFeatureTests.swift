import ComposableArchitecture
import RegisterFeature
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import HomeFeature

final class HomeFeatureTests: XCTestCase {
  func testMessengerStartUnregistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { false }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartUnregistered)) {
      $0.register = RegisterState()
    }
  }

  func testMessengerStartRegistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0
    var messengerDidLogIn = 0

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      return cMix
    }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartRegistered))
    store.receive(.networkMonitor(.start))

    store.send(.networkMonitor(.stop))
  }

  func testRegisterFinished() {
    let store = TestStore(
      initialState: HomeState(
        register: RegisterState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidLogIn = 0

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      return cMix
    }

    store.send(.register(.finished)) {
      $0.register = nil
    }

    store.receive(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidLogIn, 1)

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartRegistered))
    store.receive(.networkMonitor(.start))

    store.send(.networkMonitor(.stop))
  }

  func testMessengerStartFailure() {
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

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartConnectFailure() {
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

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartIsRegisteredFailure() {
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

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartLogInFailure() {
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

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testNetworkMonitorStart() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var cMixDidAddHealthCallback: [HealthCallback] = []
    var healthCallbackDidCancel = 0

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { callback in
        cMixDidAddHealthCallback.append(callback)
        return Cancellable { healthCallbackDidCancel += 1 }
      }
      return cMix
    }

    store.send(.networkMonitor(.start))

    XCTAssertNoDifference(cMixDidAddHealthCallback.count, 1)

    cMixDidAddHealthCallback.first?.handle(true)

    store.receive(.networkMonitor(.health(true))) {
      $0.isNetworkHealthy = true
    }

    cMixDidAddHealthCallback.first?.handle(false)

    store.receive(.networkMonitor(.health(false))) {
      $0.isNetworkHealthy = false
    }

    store.send(.networkMonitor(.stop)) {
      $0.isNetworkHealthy = nil
    }

    XCTAssertNoDifference(healthCallbackDidCancel, 1)
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

    store.send(.deleteAccount(.buttonTapped)) {
      $0.alert = .confirmAccountDeletion()
    }

    store.send(.didDismissAlert) {
      $0.alert = nil
    }

    store.send(.deleteAccount(.confirmed)) {
      $0.isDeletingAccount = true
    }

    XCTAssertNoDifference(dbDidFetchContacts, [.init(id: ["contact-id".data(using: .utf8)!])])
    XCTAssertNoDifference(udDidPermanentDeleteAccount, [Fact(fact: "MyUsername", type: 0)])
    XCTAssertNoDifference(messengerDidDestroy, 1)
    XCTAssertNoDifference(dbDidDrop, 1)

    store.receive(.deleteAccount(.success)) {
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

    store.send(.deleteAccount(.confirmed)) {
      $0.isDeletingAccount = true
    }

    store.receive(.deleteAccount(.failure(error as NSError))) {
      $0.isDeletingAccount = false
      $0.alert = .accountDeletionFailed(error)
    }
  }

  func testDidDismissAlert() {
    let store = TestStore(
      initialState: HomeState(
        alert: AlertState(title: TextState(""))
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.didDismissAlert) {
      $0.alert = nil
    }
  }

  func testDidDismissRegister() {
    let store = TestStore(
      initialState: HomeState(
        register: RegisterState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.didDismissRegister) {
      $0.register = nil
    }
  }
}
