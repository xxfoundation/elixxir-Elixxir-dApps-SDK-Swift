import AppCore
import BackupFeature
import ComposableArchitecture
import ContactsFeature
import CustomDump
import GroupsFeature
import RegisterFeature
import UserSearchFeature
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import HomeFeature

final class HomeComponentTests: XCTestCase {
  func testMessengerStartUnregistered() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0
    var messengerDidListenForMessages = 0
    var messengerDidStartFileTransfer = 0
    var messengerDidStartGroupChat = 0

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.dependencies.app.messenger.isConnected.run = { false }
    store.dependencies.app.messenger.connect.run = { messengerDidConnect += 1 }
    store.dependencies.app.messenger.isListeningForMessages.run = { false }
    store.dependencies.app.messenger.listenForMessages.run = { messengerDidListenForMessages += 1 }
    store.dependencies.app.messenger.isFileTransferRunning.run = { false }
    store.dependencies.app.messenger.startFileTransfer.run = { messengerDidStartFileTransfer += 1 }
    store.dependencies.app.messenger.isLoggedIn.run = { false }
    store.dependencies.app.messenger.isRegistered.run = { false }
    store.dependencies.app.messenger.isGroupChatRunning.run = { false }
    store.dependencies.app.messenger.startGroupChat.run = { messengerDidStartGroupChat += 1 }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidListenForMessages, 1)
    XCTAssertNoDifference(messengerDidStartFileTransfer, 1)
    XCTAssertNoDifference(messengerDidStartGroupChat, 1)

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartUnregistered)) {
      $0.register = RegisterComponent.State()
    }
  }

  func testMessengerStartRegistered() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0
    var messengerDidListenForMessages = 0
    var messengerDidStartFileTransfer = 0
    var messengerDidLogIn = 0
    var messengerDidResumeBackup = 0
    var messengerDidStartGroupChat = 0

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.dependencies.app.messenger.isConnected.run = { false }
    store.dependencies.app.messenger.connect.run = { messengerDidConnect += 1 }
    store.dependencies.app.messenger.isListeningForMessages.run = { false }
    store.dependencies.app.messenger.listenForMessages.run = { messengerDidListenForMessages += 1 }
    store.dependencies.app.messenger.isFileTransferRunning.run = { false }
    store.dependencies.app.messenger.startFileTransfer.run = { messengerDidStartFileTransfer += 1 }
    store.dependencies.app.messenger.isLoggedIn.run = { false }
    store.dependencies.app.messenger.isRegistered.run = { true }
    store.dependencies.app.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.dependencies.app.messenger.isBackupRunning.run = { false }
    store.dependencies.app.messenger.resumeBackup.run = { messengerDidResumeBackup += 1 }
    store.dependencies.app.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      cMix.getNodeRegistrationStatus.run = {
        struct Unimplemented: Error {}
        throw Unimplemented()
      }
      return cMix
    }
    store.dependencies.app.messenger.isGroupChatRunning.run = { false }
    store.dependencies.app.messenger.startGroupChat.run = { messengerDidStartGroupChat += 1 }

    store.send(.messenger(.start))

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidListenForMessages, 1)
    XCTAssertNoDifference(messengerDidStartFileTransfer, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)
    XCTAssertNoDifference(messengerDidResumeBackup, 1)
    XCTAssertNoDifference(messengerDidStartGroupChat, 1)

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.didStartRegistered))
    store.receive(.networkMonitor(.start))

    store.send(.networkMonitor(.stop))
  }

  func testRegisterFinished() {
    let store = TestStore(
      initialState: HomeComponent.State(
        register: RegisterComponent.State()
      ),
      reducer: HomeComponent()
    )

    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidLogIn = 0

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.dependencies.app.messenger.isConnected.run = { true }
    store.dependencies.app.messenger.isListeningForMessages.run = { true }
    store.dependencies.app.messenger.isFileTransferRunning.run = { true }
    store.dependencies.app.messenger.isLoggedIn.run = { false }
    store.dependencies.app.messenger.isRegistered.run = { true }
    store.dependencies.app.messenger.logIn.run = { messengerDidLogIn += 1 }
    store.dependencies.app.messenger.isBackupRunning.run = { true }
    store.dependencies.app.messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.addHealthCallback.run = { _ in Cancellable {} }
      cMix.getNodeRegistrationStatus.run = {
        struct Unimplemented: Error {}
        throw Unimplemented()
      }
      return cMix
    }
    store.dependencies.app.messenger.isGroupChatRunning.run = { true }

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
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { _ in throw error }

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartConnectFailure() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { _ in }
    store.dependencies.app.messenger.isConnected.run = { false }
    store.dependencies.app.messenger.connect.run = { throw error }

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartIsRegisteredFailure() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { _ in }
    store.dependencies.app.messenger.isConnected.run = { true }
    store.dependencies.app.messenger.isListeningForMessages.run = { true }
    store.dependencies.app.messenger.isFileTransferRunning.run = { true }
    store.dependencies.app.messenger.isLoggedIn.run = { false }
    store.dependencies.app.messenger.isRegistered.run = { throw error }
    store.dependencies.app.messenger.isGroupChatRunning.run = { true }

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testMessengerStartLogInFailure() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.start.run = { _ in }
    store.dependencies.app.messenger.isConnected.run = { true }
    store.dependencies.app.messenger.isListeningForMessages.run = { true }
    store.dependencies.app.messenger.isFileTransferRunning.run = { true }
    store.dependencies.app.messenger.isLoggedIn.run = { false }
    store.dependencies.app.messenger.isRegistered.run = { true }
    store.dependencies.app.messenger.logIn.run = { throw error }
    store.dependencies.app.messenger.isGroupChatRunning.run = { true }

    store.send(.messenger(.start))

    store.receive(.networkMonitor(.stop))
    store.receive(.messenger(.failure(error as NSError))) {
      $0.failure = error.localizedDescription
    }
  }

  func testNetworkMonitorStart() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
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

    store.dependencies.app.bgQueue = bgQueue.eraseToAnyScheduler()
    store.dependencies.app.mainQueue = mainQueue.eraseToAnyScheduler()
    store.dependencies.app.messenger.cMix.get = {
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
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    var udDidPermanentDeleteAccount: [Fact] = []
    var messengerDidDestroy = 0
    var didRemoveDB = 0

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
        return contact
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
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
    store.dependencies.app.dbManager.removeDB.run = {
      didRemoveDB += 1
    }
    store.dependencies.app.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.permanentDeleteAccount.run = { usernameFact in
        udDidPermanentDeleteAccount.append(usernameFact)
      }
      return ud
    }
    store.dependencies.app.messenger.destroy.run = {
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
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
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
      initialState: HomeComponent.State(
        alert: AlertState(title: TextState(""))
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissAlert) {
      $0.alert = nil
    }
  }

  func testDidDismissRegister() {
    let store = TestStore(
      initialState: HomeComponent.State(
        register: RegisterComponent.State()
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissRegister) {
      $0.register = nil
    }
  }

  func testUserSearchButtonTapped() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    store.send(.userSearchButtonTapped) {
      $0.userSearch = UserSearchComponent.State()
    }
  }

  func testDidDismissUserSearch() {
    let store = TestStore(
      initialState: HomeComponent.State(
        userSearch: UserSearchComponent.State()
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissUserSearch) {
      $0.userSearch = nil
    }
  }

  func testContactsButtonTapped() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    store.send(.contactsButtonTapped) {
      $0.contacts = ContactsComponent.State()
    }
  }

  func testDidDismissContacts() {
    let store = TestStore(
      initialState: HomeComponent.State(
        contacts: ContactsComponent.State()
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissContacts) {
      $0.contacts = nil
    }
  }

  func testBackupButtonTapped() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    store.send(.backupButtonTapped) {
      $0.backup = BackupComponent.State()
    }
  }

  func testDidDismissBackup() {
    let store = TestStore(
      initialState: HomeComponent.State(
        backup: BackupComponent.State()
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissBackup) {
      $0.backup = nil
    }
  }

  func testGroupsButtonTapped() {
    let store = TestStore(
      initialState: HomeComponent.State(),
      reducer: HomeComponent()
    )

    store.send(.groupsButtonTapped) {
      $0.groups = GroupsComponent.State()
    }
  }

  func testDidDismissGroups() {
    let store = TestStore(
      initialState: HomeComponent.State(
        groups: GroupsComponent.State()
      ),
      reducer: HomeComponent()
    )

    store.send(.didDismissGroups) {
      $0.groups = nil
    }
  }
}
