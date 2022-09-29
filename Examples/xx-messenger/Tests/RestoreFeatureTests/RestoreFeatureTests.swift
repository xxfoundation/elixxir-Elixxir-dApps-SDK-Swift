import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import RestoreFeature

final class RestoreFeatureTests: XCTestCase {
  func testFileImport() {
    let fileURL = URL(string: "file-url")!
    var didLoadDataFromURL: [URL] = []
    let dataFromURL = "data-from-url".data(using: .utf8)!

    let store = TestStore(
      initialState: RestoreState(),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.loadData.load = { url in
      didLoadDataFromURL.append(url)
      return dataFromURL
    }

    store.send(.importFileTapped) {
      $0.isImportingFile = true
    }

    store.send(.fileImport(.success(fileURL))) {
      $0.isImportingFile = false
      $0.file = .init(name: fileURL.lastPathComponent, data: dataFromURL)
      $0.fileImportFailure = nil
    }

    XCTAssertNoDifference(didLoadDataFromURL, [fileURL])
  }

  func testFileImportFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: RestoreState(
        isImportingFile: true
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.send(.fileImport(.failure(failure as NSError))) {
      $0.isImportingFile = false
      $0.file = nil
      $0.fileImportFailure = failure.localizedDescription
    }
  }

  func testFileImportLoadingFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: RestoreState(
        isImportingFile: true
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.loadData.load = { _ in throw failure }

    store.send(.fileImport(.success(URL(string: "test")!))) {
      $0.isImportingFile = false
      $0.file = nil
      $0.fileImportFailure = failure.localizedDescription
    }
  }

  func testRestore() {
    let backupData = "backup-data".data(using: .utf8)!
    let backupPassphrase = "backup-passphrase"
    let restoredFacts = [
      Fact(type: .email, value: "restored-email"),
      Fact(type: .phone, value: "restored-phone"),
    ]
    let restoreResult = MessengerRestoreBackup.Result(
      restoredParams: BackupParams(username: "restored-username"),
      restoredContacts: [
        "contact-1-id".data(using: .utf8)!,
        "contact-2-id".data(using: .utf8)!,
        "contact-3-id".data(using: .utf8)!,
      ]
    )
    let now = Date()
    let contactId = "contact-id".data(using: .utf8)!

    var udFacts: [Fact] = []
    var didRestoreWithData: [Data] = []
    var didRestoreWithPassphrase: [String] = []
    var didFetchContacts: [XXModels.Contact.Query] = []
    var didSaveContact: [XXModels.Contact] = []

    let store = TestStore(
      initialState: RestoreState(
        file: .init(name: "file-name", data: backupData)
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.now = { now }
    store.environment.messenger.restoreBackup.run = { data, passphrase in
      didRestoreWithData.append(data)
      didRestoreWithPassphrase.append(passphrase)
      udFacts = restoredFacts
      return restoreResult
    }
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
      ud.getFacts.run = { udFacts }
      return ud
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
      db.fetchContacts.run = { query in
        didFetchContacts.append(query)
        return []
      }
      db.saveContact.run = { contact in
        didSaveContact.append(contact)
        return contact
      }
      return db
    }

    store.send(.set(\.$passphrase, backupPassphrase)) {
      $0.passphrase = backupPassphrase
    }

    store.send(.restoreTapped) {
      $0.isRestoring = true
    }

    XCTAssertNoDifference(didRestoreWithData, [backupData])
    XCTAssertNoDifference(didRestoreWithPassphrase, [backupPassphrase])
    XCTAssertNoDifference(didFetchContacts, [
      .init(id: [restoreResult.restoredContacts[0]]),
      .init(id: [restoreResult.restoredContacts[1]]),
      .init(id: [restoreResult.restoredContacts[2]]),
    ])
    XCTAssertNoDifference(didSaveContact, [
      Contact(
        id: contactId,
        username: restoreResult.restoredParams.username,
        email: restoredFacts.get(.email)?.value,
        phone: restoredFacts.get(.phone)?.value,
        createdAt: now
      ),
      Contact(
        id: restoreResult.restoredContacts[0],
        createdAt: now
      ),
      Contact(
        id: restoreResult.restoredContacts[1],
        createdAt: now
      ),
      Contact(
        id: restoreResult.restoredContacts[2],
        createdAt: now
      ),
    ])

    store.receive(.finished) {
      $0.isRestoring = false
    }
  }

  func testRestoreWithoutFile() {
    let store = TestStore(
      initialState: RestoreState(
        file: nil
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.send(.restoreTapped)
  }

  func testRestoreFailure() {
    enum Failure: Error {
      case restore
      case destroy
    }

    let store = TestStore(
      initialState: RestoreState(
        file: .init(name: "name", data: "data".data(using: .utf8)!)
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.restoreBackup.run = { _, _ in throw Failure.restore }
    store.environment.messenger.destroy.run = { throw Failure.destroy }

    store.send(.restoreTapped) {
      $0.isRestoring = true
    }

    store.receive(.failed([Failure.restore as NSError, Failure.destroy as NSError])) {
      $0.isRestoring = false
      $0.restoreFailures = [
        Failure.restore.localizedDescription,
        Failure.destroy.localizedDescription,
      ]
    }
  }
}
