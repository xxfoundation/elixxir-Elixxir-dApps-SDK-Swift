import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerIsBackupRunningTests: XCTestCase {
  func testWithoutBackup() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    let isRunning: MessengerIsBackupRunning = .live(env)

    XCTAssertFalse(isRunning())
  }

  func testWithBackupRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.isRunning.run = { true }
      return backup
    }
    let isRunning: MessengerIsBackupRunning = .live(env)

    XCTAssertTrue(isRunning())
  }

  func testWithBackupNotRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.isRunning.run = { false }
      return backup
    }
    let isRunning: MessengerIsBackupRunning = .live(env)

    XCTAssertFalse(isRunning())
  }
}
