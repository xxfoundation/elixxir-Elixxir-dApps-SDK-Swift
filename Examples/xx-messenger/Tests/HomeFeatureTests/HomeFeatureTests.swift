import AppCore
import ComposableArchitecture
import ContactsFeature
import RegisterFeature
import UserSearchFeature
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { false }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartUnregistered)) {
      $0.register = RegisterState()
    }

    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      cMix.getNodeRegistrationStatus.run = {
        struct Unimplemented: Error {}
        throw Unimplemented()
      }
      return cMix
    }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartRegistered))
    store.receive(.networkMonitor(.start))

    store.send(.networkMonitor(.stop))
    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      cMix.getNodeRegistrationStatus.run = {
        struct Unimplemented: Error {}
        throw Unimplemented()
      }
      return cMix
    }

    store.send(.register(.finished)) {
      $0.register = nil
    }

    store.receive(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidLogIn, 1)

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartRegistered))
    store.receive(.networkMonitor(.start))

    store.send(.networkMonitor(.stop))
    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { _ in throw error }

    store.send(.messenger(.start))

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }

    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { throw error }

    store.send(.messenger(.start))

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }

    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { throw error }

    store.send(.messenger(.start))

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }

    store.send(.authHandler(.stop))
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
    store.environment.authHandler.run = { _ in Cancellable {} }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { throw error }

    store.send(.messenger(.start))

    store.receive(.authHandler(.start))
    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }

    store.send(.authHandler(.stop))
  }

  func testNetworkMonitorStart() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test

    var cMixDidAddHealthCallback: [HealthCallback] = []
    var healthCallbackDidCancel = 0
    var nodeRegistrationStatusIndex = 0
    let nodeRegistrationStatus: [NodeRegistrationReport] = [
      .init(registered: 0, total: 10),
      .init(registered: 1, total: 11),
      .init(registered: 2, total: 12),
    ]

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { callback in
        cMixDidAddHealthCallback.append(callback)
        return Cancellable { healthCallbackDidCancel += 1 }
      }
      cMix.getNodeRegistrationStatus.run = {
        defer { nodeRegistrationStatusIndex += 1 }
        return nodeRegistrationStatus[nodeRegistrationStatusIndex]
      }
      return cMix
    }

    store.send(.networkMonitor(.start))

    bgQueue.advance()

    XCTAssertNoDifference(cMixDidAddHealthCallback.count, 1)

    cMixDidAddHealthCallback.first?.handle(true)
    mainQueue.advance()

    store.receive(.networkMonitor(.health(true))) {
      $0.isNetworkHealthy = true
    }

    cMixDidAddHealthCallback.first?.handle(false)
    mainQueue.advance()

    store.receive(.networkMonitor(.health(false))) {
      $0.isNetworkHealthy = false
    }

    bgQueue.advance(by: 2)
    mainQueue.advance()

    store.receive(.networkMonitor(.nodes(nodeRegistrationStatus[0]))) {
      $0.networkNodesReport = nodeRegistrationStatus[0]
    }

    bgQueue.advance(by: 2)
    mainQueue.advance()

    store.receive(.networkMonitor(.nodes(nodeRegistrationStatus[1]))) {
      $0.networkNodesReport = nodeRegistrationStatus[1]
    }

    bgQueue.advance(by: 2)
    mainQueue.advance()

    store.receive(.networkMonitor(.nodes(nodeRegistrationStatus[2]))) {
      $0.networkNodesReport = nodeRegistrationStatus[2]
    }

    store.send(.networkMonitor(.stop)) {
      $0.isNetworkHealthy = nil
      $0.networkNodesReport = nil
    }

    XCTAssertNoDifference(healthCallbackDidCancel, 1)

    mainQueue.advance()
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
    var didRemoveDB = 0

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
    store.environment.dbManager.getDB.run = {
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
      return db
    }
    store.environment.dbManager.removeDB.run = {
      didRemoveDB += 1
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
    XCTAssertNoDifference(udDidPermanentDeleteAccount, [Fact(type: .username, value: "MyUsername")])
    XCTAssertNoDifference(messengerDidDestroy, 1)
    XCTAssertNoDifference(didRemoveDB, 1)

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

  func testUserSearchButtonTapped() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.userSearchButtonTapped) {
      $0.userSearch = UserSearchState()
    }
  }

  func testDidDismissUserSearch() {
    let store = TestStore(
      initialState: HomeState(
        userSearch: UserSearchState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.didDismissUserSearch) {
      $0.userSearch = nil
    }
  }

  func testContactsButtonTapped() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.contactsButtonTapped) {
      $0.contacts = ContactsState()
    }
  }

  func testDidDismissContacts() {
    let store = TestStore(
      initialState: HomeState(
        contacts: ContactsState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    store.send(.didDismissContacts) {
      $0.contacts = nil
    }
  }

  func testAuthCallbacks() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    var didRunAuthHandler = 0
    var didCancelAuthHandler = 0
    var authHandlerOnError: [AuthCallbackHandler.OnError] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.authHandler.run = { onError in
      didRunAuthHandler += 1
      authHandlerOnError.append(onError)
      return Cancellable { didCancelAuthHandler += 1 }
    }

    store.send(.authHandler(.start))

    XCTAssertNoDifference(didRunAuthHandler, 1)

    struct AuthHandlerError: Error { var id: Int }
    authHandlerOnError.first?(AuthHandlerError(id: 1))

    store.receive(.authHandler(.failure(AuthHandlerError(id: 1) as NSError))) {
      $0.authFailure = AuthHandlerError(id: 1).localizedDescription
    }

    store.send(.authHandler(.failureDismissed)) {
      $0.authFailure = nil
    }

    store.send(.authHandler(.stop))

    XCTAssertNoDifference(didCancelAuthHandler, 1)

    authHandlerOnError.first?(AuthHandlerError(id: 2))
  }
}
