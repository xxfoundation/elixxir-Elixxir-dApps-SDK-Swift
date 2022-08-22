import CustomDump
import XCTest
@testable import XXMessengerClient

final class IsCreatedTests: XCTestCase {
  func testStorageDirNotEmpty() {
    var didIsDirectoryEmpty: [String] = []
    let storageDir = "storage-dir"

    var env: Environment = .unimplemented
    env.storageDir = storageDir
    env.directoryManager.isEmpty = { path in
      didIsDirectoryEmpty.append(path)
      return false
    }
    let isCreated: IsCreated = .live(env)

    XCTAssertTrue(isCreated())
    XCTAssertNoDifference(didIsDirectoryEmpty, [storageDir])
  }

  func testStorageDirEmpty() {
    var didIsDirectoryEmpty: [String] = []
    let storageDir = "storage-dir"

    var env: Environment = .unimplemented
    env.storageDir = storageDir
    env.directoryManager.isEmpty = { path in
      didIsDirectoryEmpty.append(path)
      return true
    }
    let isCreated: IsCreated = .live(env)

    XCTAssertFalse(isCreated())
    XCTAssertNoDifference(didIsDirectoryEmpty, [storageDir])
  }
}
