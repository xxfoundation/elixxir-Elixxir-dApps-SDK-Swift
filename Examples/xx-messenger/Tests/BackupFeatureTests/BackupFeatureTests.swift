import ComposableArchitecture
import XCTest
import XXClient
import XXMessengerClient
import XXModels
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
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }
    store.environment.backupStorage.stored = {
      storedBackup
    }
    store.environment.backupStorage.observe = {
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
    let contactID = "contact-id".data(using: .utf8)!
    let dbContact = XXModels.Contact(
      id: contactID,
      username: "db-contact-username"
    )
    let passphrase = "backup-password"

    let store = TestStore(
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.startBackup.run = { passphrase, params in
      actions.append(.didStartBackup(passphrase: passphrase, params: params))
    }
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
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
      db.fetchContacts.run = { _ in return [dbContact] }
      return db
    }

    actions = []
    store.send(.set(\.$passphrase, passphrase)) {
      $0.passphrase = passphrase
    }

    XCTAssertNoDifference(actions, [])

    actions = []
    store.send(.startTapped) {
      $0.isStarting = true
    }

    XCTAssertNoDifference(actions, [
      .didStartBackup(
        passphrase: passphrase,
        params: .init(username: dbContact.username!)
      )
    ])

    store.receive(.didStart(failure: nil)) {
      $0.isRunning = true
      $0.isStarting = false
      $0.passphrase = ""
    }
  }

  func testStartBackupWithoutDbContact() {
    var isBackupRunning: [Bool] = [false]
    let contactID = "contact-id".data(using: .utf8)!

    let store = TestStore(
      initialState: BackupState(
        passphrase: "1234"
      ),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
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
      db.fetchContacts.run = { _ in [] }
      return db
    }

    store.send(.startTapped) {
      $0.isStarting = true
    }

    let failure = BackupState.Error.dbContactNotFound
    store.receive(.didStart(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isStarting = false
      $0.alert = .error(failure)
    }
  }

  func testStartBackupWithoutDbContactUsername() {
    var isBackupRunning: [Bool] = [false]
    let contactID = "contact-id".data(using: .utf8)!
    let dbContact = XXModels.Contact(
      id: contactID,
      username: nil
    )

    let store = TestStore(
      initialState: BackupState(
        passphrase: "1234"
      ),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
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
      db.fetchContacts.run = { _ in [dbContact] }
      return db
    }

    store.send(.startTapped) {
      $0.isStarting = true
    }

    let failure = BackupState.Error.dbContactUsernameMissing
    store.receive(.didStart(failure: failure as NSError)) {
      $0.isRunning = false
      $0.isStarting = false
      $0.alert = .error(failure)
    }
  }

  func testStartBackupFailure() {
    struct Failure: Error {}
    let failure = Failure()
    var isBackupRunning: [Bool] = [false]
    let contactID = "contact-id".data(using: .utf8)!
    let dbContact = XXModels.Contact(
      id: contactID,
      username: "db-contact-username"
    )

    let store = TestStore(
      initialState: BackupState(
        passphrase: "1234"
      ),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.startBackup.run = { _, _ in
      throw failure
    }
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
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
      db.fetchContacts.run = { _ in return [dbContact] }
      return db
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
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.resumeBackup.run = {
      actions.append(.didResumeBackup)
    }
    store.environment.messenger.isBackupRunning.run = {
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
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.resumeBackup.run = {
      throw failure
    }
    store.environment.messenger.isBackupRunning.run = {
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
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.stopBackup.run = {
      actions.append(.didStopBackup)
    }
    store.environment.messenger.isBackupRunning.run = {
      isBackupRunning.removeFirst()
    }
    store.environment.backupStorage.remove = {
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
      initialState: BackupState(),
      reducer: backupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.stopBackup.run = {
      throw failure
    }
    store.environment.messenger.isBackupRunning.run = {
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
      initialState: BackupState(
        alert: .error(NSError(domain: "test", code: 0))
      ),
      reducer: backupReducer,
      environment: .unimplemented
    )

    store.send(.alertDismissed) {
      $0.alert = nil
    }
  }

  func testExportBackup() {
    let backupData = "backup-data".data(using: .utf8)!

    let store = TestStore(
      initialState: BackupState(
        backup: .init(
          date: Date(),
          data: backupData
        )
      ),
      reducer: backupReducer,
      environment: .unimplemented
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
  case didFetchContacts(XXModels.Contact.Query)
}
