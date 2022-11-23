import CustomDump
import XCTest
@testable import XXMessengerClient

final class MessengerIsCreatedTests: XCTestCase {
  func testStorageDirNotEmpty() {
    var didIsDirectoryEmpty: [String] = []
    let storageDir = "storage-dir"

    var env: MessengerEnvironment = .unimplemented
    env.storageDir = storageDir
    env.fileManager.isDirectoryEmpty = { path in
      didIsDirectoryEmpty.append(path)
      return false
    }
    let isCreated: MessengerIsCreated = .live(env)

    XCTAssertTrue(isCreated())
    XCTAssertNoDifference(didIsDirectoryEmpty, [storageDir])
  }

  func testStorageDirEmpty() {
    var didIsDirectoryEmpty: [String] = []
    let storageDir = "storage-dir"

    var env: MessengerEnvironment = .unimplemented
    env.storageDir = storageDir
    env.fileManager.isDirectoryEmpty = { path in
      didIsDirectoryEmpty.append(path)
      return true
    }
    let isCreated: MessengerIsCreated = .live(env)

    XCTAssertFalse(isCreated())
    XCTAssertNoDifference(didIsDirectoryEmpty, [storageDir])
  }
}
