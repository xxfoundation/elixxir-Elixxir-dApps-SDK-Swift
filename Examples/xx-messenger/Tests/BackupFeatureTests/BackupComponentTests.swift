import ComposableArchitecture
import XCTest
import XXClient
import XXMessengerClient
@testable import BackupFeature

final class BackupFeatureTests: XCTestCase {
  func testTask() {
    var isBackupRunning: [Bool] = [false]
    var observers: [UUID: BackupStorage.Observer] = [:]
    let storedBackup = BackupStorage.Backup(
      date: .init(timeIntervalSince1970: 1),
      data: "stored".data(using: .utf8)!
    )

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }
    store.dependencies.app.backupStorage.stored = {
      storedBackup
    }
    store.dependencies.app.backupStorage.observe = {
      let id = UUID()
      observers[id] = $0
      return Cancellable { observers[id] = nil }
    }

    store.send(.task)

    XCTAssertNoDifference(observers.count, 1)

    store.receive(.backupUpdated(storedBackup)) {
      $0.backup = storedBackup
    }

    let observedBackup = BackupStorage.Backup(
      date: .init(timeIntervalSince1970: 2),
      data: "observed".data(using: .utf8)!
    )
    observers.values.forEach { $0(observedBackup) }

    store.receive(.backupUpdated(observedBackup)) {
      $0.backup = observedBackup
    }

    observers.values.forEach { $0(nil) }

    store.receive(.backupUpdated(nil)) {
      $0.backup = nil
    }

    store.send(.cancelTask)

    XCTAssertNoDifference(observers.count, 0)
  }

  func testStartBackup() {
    var actions: [Action]!
    var isBackupRunning: [Bool] = [true]
    let username = "test-username"
    let passphrase = "backup-password"

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { includeFacts in
      actions.append(.didGetMyContact(includingFacts: includeFacts))
      var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
      contact.getFactsFromContact.run = { _ in [Fact(type: .username, value: username)] }
      return contact
    }
    store.dependencies.app.messenger.startBackup.run = { passphrase, params in
      actions.append(.didStartBackup(passphrase: passphrase, params: params))
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    actions = []
    store.send(.set(\.$focusedField, .passphrase)) {
      $0.focusedField = .passphrase
    }
    store.send(.set(\.$passphrase, passphrase)) {
      $0.passphrase = passphrase
    }

    XCTAssertNoDifference(actions, [])

    actions = []
    store.send(.startTapped) {
      $0.isStarting = true
      $0.focusedField = nil
    }

    XCTAssertNoDifference(actions, [
      .didGetMyContact(
        includingFacts: .types([.username])
      ),
      .didStartBackup(
        passphrase: passphrase,
        params: .init(username: username)
      )
    ])

    store.receive(.didStart(failure: nil)) {
      $0.isRunning = true
      $0.isStarting = false
      $0.passphrase = ""
    }
  }

  func testStartBackupWithoutContactUsername() {
    var isBackupRunning: [Bool] = [false]

    let store = TestStore(
      initialState: BackupComponent.State(
        passphrase: "1234"
      ),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { _ in
      var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
      contact.getFactsFromContact.run = { _ in [] }
      return contact
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    store.send(.startTapped) {
      $0.isStarting = true
    }

    let failure = BackupComponent.State.Error.contactUsernameMissing
    store.receive(.didStart(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isStarting = false
      $0.alert = .error(failure)
    }
  }

  func testStartBackupMyContactFailure() {
    struct Failure: Error {}
    let failure = Failure()
    var isBackupRunning: [Bool] = [false]

    let store = TestStore(
      initialState: BackupComponent.State(
        passphrase: "1234"
      ),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { _ in throw failure }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    store.send(.startTapped) {
      $0.isStarting = true
    }

    store.receive(.didStart(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isStarting = false
      $0.alert = .error(failure)
    }
  }

  func testStartBackupStartFailure() {
    struct Failure: Error {}
    let failure = Failure()
    var isBackupRunning: [Bool] = [false]

    let store = TestStore(
      initialState: BackupComponent.State(
        passphrase: "1234"
      ),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { _ in
      var contact = Contact.unimplemented("data".data(using: .utf8)!)
      contact.getFactsFromContact.run = { _ in [Fact(type: .username, value: "username")] }
      return contact
    }
    store.dependencies.app.messenger.startBackup.run = { _, _ in
      throw failure
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    store.send(.startTapped) {
      $0.isStarting = true
    }

    store.receive(.didStart(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isStarting = false
      $0.alert = .error(failure)
    }
  }

  func testResumeBackup() {
    var actions: [Action]!
    var isBackupRunning: [Bool] = [true]

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.resumeBackup.run = {
      actions.append(.didResumeBackup)
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    actions = []
    store.send(.resumeTapped) {
      $0.isResuming = true
    }

    XCTAssertNoDifference(actions, [.didResumeBackup])

    actions = []
    store.receive(.didResume(failure: nil)) {
      $0.isRunning = true
      $0.isResuming = false
    }

    XCTAssertNoDifference(actions, [])
  }

  func testResumeBackupFailure() {
    struct Failure: Error {}
    let failure = Failure()
    var isBackupRunning: [Bool] = [false]

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.resumeBackup.run = {
      throw failure
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    store.send(.resumeTapped) {
      $0.isResuming = true
    }

    store.receive(.didResume(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isResuming = false
      $0.alert = .error(failure)
    }
  }

  func testStopBackup() {
    var actions: [Action]!
    var isBackupRunning: [Bool] = [false]

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.stopBackup.run = {
      actions.append(.didStopBackup)
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }
    store.dependencies.app.backupStorage.remove = {
      actions.append(.didRemoveBackup)
    }

    actions = []
    store.send(.stopTapped) {
      $0.isStopping = true
    }

    XCTAssertNoDifference(actions, [
      .didStopBackup,
      .didRemoveBackup,
    ])

    actions = []
    store.receive(.didStop(failure: nil)) {
      $0.isRunning = false
      $0.isStopping = false
    }

    XCTAssertNoDifference(actions, [])
  }

  func testStopBackupFailure() {
    struct Failure: Error {}
    let failure = Failure()
    var isBackupRunning: [Bool] = [true]

    let store = TestStore(
      initialState: BackupComponent.State(),
      reducer: BackupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.stopBackup.run = {
      throw failure
    }
    store.dependencies.app.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }

    store.send(.stopTapped) {
      $0.isStopping = true
    }

    store.receive(.didStop(failure: failure as NSError)) {
      $0.isRunning = true
      $0.isStopping = false
      $0.alert = .error(failure)
    }
  }

  func testAlertDismissed() {
    let store = TestStore(
      initialState: BackupComponent.State(
        alert: .error(NSError(domain: "test", code: 0))
      ),
      reducer: BackupComponent()
    )

    store.send(.alertDismissed) {
      $0.alert = nil
    }
  }

  func testExportBackup() {
    let backupData = "backup-data".data(using: .utf8)!

    let store = TestStore(
      initialState: BackupComponent.State(
        backup: .init(
          date: Date(),
          data: backupData
        )
      ),
      reducer: BackupComponent()
    )

    store.send(.exportTapped) {
      $0.isExporting = true
      $0.exportData = backupData
    }

    store.send(.didExport(failure: nil)) {
      $0.isExporting = false
      $0.exportData = nil
    }

    store.send(.exportTapped) {
      $0.isExporting = true
      $0.exportData = backupData
    }

    let failure = NSError(domain: "test", code: 0)
    store.send(.didExport(failure: failure)) {
      $0.isExporting = false
      $0.exportData = nil
      $0.alert = .error(failure)
    }
  }
}

private enum Action: Equatable {
  case didRegisterObserver
  case didStartBackup(passphrase: String, params: BackupParams)
  case didResumeBackup
  case didStopBackup
  case didRemoveBackup
  case didGetMyContact(includingFacts: MessengerMyContact.IncludeFacts?)
}
