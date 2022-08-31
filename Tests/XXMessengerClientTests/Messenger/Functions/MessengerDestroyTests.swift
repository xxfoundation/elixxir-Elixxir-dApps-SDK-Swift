import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerDestroyTests: XCTestCase {
  func testDestroy() throws {
    let storageDir = "test-storage-dir"
    var didRemoveDirectory: [String] = []
    var didSetUD: [UserDiscovery?] = []
    var didSetE2E: [E2E?] = []
    var didSetCMix: [CMix?] = []

    var env: MessengerEnvironment = .unimplemented
    env.storageDir = storageDir
    env.ud.set = { didSetUD.append($0) }
    env.e2e.set = { didSetE2E.append($0) }
    env.cMix.set = { didSetCMix.append($0) }
    env.fileManager.removeDirectory = { didRemoveDirectory.append($0) }
    let destroy: MessengerDestroy = .live(env)

    try destroy()

    XCTAssertNoDifference(didSetUD.map { $0 == nil }, [true])
    XCTAssertNoDifference(didSetE2E.map { $0 == nil }, [true])
    XCTAssertNoDifference(didSetCMix.map { $0 == nil }, [true])
    XCTAssertNoDifference(didRemoveDirectory, [storageDir])
  }

  func testRemoveDirectoryFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()
    var didSetUD: [UserDiscovery?] = []
    var didSetE2E: [E2E?] = []
    var didSetCMix: [CMix?] = []

    var env: MessengerEnvironment = .unimplemented
    env.ud.set = { didSetUD.append($0) }
    env.e2e.set = { didSetE2E.append($0) }
    env.cMix.set = { didSetCMix.append($0) }
    env.fileManager.removeDirectory = { _ in throw error }
    let destroy: MessengerDestroy = .live(env)

    XCTAssertThrowsError(try destroy()) { err in
      XCTAssertEqual(err as? Error, error)
    }
    XCTAssertNoDifference(didSetUD.map { $0 == nil }, [true])
    XCTAssertNoDifference(didSetE2E.map { $0 == nil }, [true])
    XCTAssertNoDifference(didSetCMix.map { $0 == nil }, [true])
  }
}
