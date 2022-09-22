import CustomDump
import ComposableArchitecture
import XCTest
@testable import RestoreFeature
import XXMessengerClient

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
    let restoreResult = MessengerRestoreBackup.Result(
      restoredParams: BackupParams.init(
        username: "",
        email: nil,
        phone: nil
      ),
      restoredContacts: []
    )

    var didRestoreWithData: [Data] = []
    var didRestoreWithPassphrase: [String] = []
    var didListenForMessages = 0

    let store = TestStore(
      initialState: RestoreState(
        file: .init(name: "file-name", data: backupData)
      ),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.restoreBackup.run = { data, passphrase in
      didRestoreWithData.append(data)
      didRestoreWithPassphrase.append(passphrase)
      return restoreResult
    }
    store.environment.messenger.listenForMessages.run = {
      didListenForMessages += 1
    }

    store.send(.set(\.$passphrase, backupPassphrase)) {
      $0.passphrase = backupPassphrase
    }

    store.send(.restoreTapped) {
      $0.isRestoring = true
    }

    XCTAssertNoDifference(didRestoreWithData, [backupData])
    XCTAssertNoDifference(didRestoreWithPassphrase, [backupPassphrase])
    XCTAssertNoDifference(didListenForMessages, 1)

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

    store.send(.restoreTapped) {
      $0.isRestoring = true
    }

    store.receive(.failed(failure as NSError)) {
      $0.isRestoring = false
      $0.restoreFailure = failure.localizedDescription
    }
  }
}
