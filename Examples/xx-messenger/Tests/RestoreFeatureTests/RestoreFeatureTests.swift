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
    let lookedUpContacts = [XXClient.Contact.stub(1), .stub(2), .stub(3)]
    let now = Date()
    let contactId = "contact-id".data(using: .utf8)!


    var udFacts: [Fact] = []
    var didRestoreWithData: [Data] = []
    var didRestoreWithPassphrase: [String] = []
    var didSaveContact: [XXModels.Contact] = []
    var didLookupContactIds: [[Data]] = []

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
    store.environment.messenger.lookupContacts.run = { contactIds in
      didLookupContactIds.append(contactIds)
      return .init(
        contacts: lookedUpContacts,
        failedIds: [],
        errors: []
      )
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
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
    XCTAssertNoDifference(didLookupContactIds, [restoreResult.restoredContacts])
    XCTAssertNoDifference(didSaveContact, [
      Contact(
        id: contactId,
        username: restoreResult.restoredParams.username,
        email: restoredFacts.get(.email)?.value,
        phone: restoredFacts.get(.phone)?.value,
        createdAt: now
      ),
      Contact(
        id: "contact-\(1)-id".data(using: .utf8)!,
        marshaled: "contact-\(1)-data".data(using: .utf8)!,
        username: "contact-\(1)-username",
        email: "contact-\(1)-email",
        phone: "contact-\(1)-phone",
        authStatus: .friend,
        createdAt: now
      ),
      Contact(
        id: "contact-\(2)-id".data(using: .utf8)!,
        marshaled: "contact-\(2)-data".data(using: .utf8)!,
        username: "contact-\(2)-username",
        email: "contact-\(2)-email",
        phone: "contact-\(2)-phone",
        authStatus: .friend,
        createdAt: now
      ),
      Contact(
        id: "contact-\(3)-id".data(using: .utf8)!,
        marshaled: "contact-\(3)-data".data(using: .utf8)!,
        username: "contact-\(3)-username",
        email: "contact-\(3)-email",
        phone: "contact-\(3)-phone",
        authStatus: .friend,
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
    struct Failure: Error {}
    let failure = Failure()

    var didDestroyMessenger = 0

    let store = TestStore(
      initialState: RestoreState(
        file: .init(name: "name", data: "data".data(using: .utf8)!)
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.restoreBackup.run = { _, _ in throw failure }
    store.environment.messenger.destroy.run = { didDestroyMessenger += 1 }

    store.send(.restoreTapped) {
      $0.isRestoring = true
    }

    XCTAssertEqual(didDestroyMessenger, 1)

    store.receive(.failed([failure as NSError])) {
      $0.isRestoring = false
      $0.restoreFailures = [failure.localizedDescription]
    }
  }
}

private extension XXClient.Contact {
  static func stub(_ id: Int) -> XXClient.Contact {
    var contact = XXClient.Contact.unimplemented(
      "contact-\(id)-data".data(using: .utf8)!
    )
    contact.getIdFromContact.run = { _ in
      "contact-\(id)-id".data(using: .utf8)!
    }
    contact.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "contact-\(id)-username"),
        Fact(type: .email, value: "contact-\(id)-email"),
        Fact(type: .phone, value: "contact-\(id)-phone"),
      ]
    }
    return contact
  }
}
