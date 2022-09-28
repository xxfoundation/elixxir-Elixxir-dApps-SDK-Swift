import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerBackupParamsTests: XCTestCase {
  func testBackupParams() throws {
    var didAddJSON: [String] = []

    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.isRunning.run = { true }
      backup.addJSON.run = { didAddJSON.append($0) }
      return backup
    }
    let backup: MessengerBackupParams = .live(env)

    try backup(.stub)

    XCTAssertNoDifference(didAddJSON, [
      String(data: try BackupParams.stub.encode(), encoding: .utf8)!
    ])
  }

  func testBackupParamsWhenNoBackup() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    let backup: MessengerBackupParams = .live(env)

    XCTAssertThrowsError(try backup(.stub)) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerBackupParams.Error.notRunning as NSError
      )
    }
  }

  func testBackupParamsWhenBackupNotRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.isRunning.run = { false }
      return backup
    }
    let backup: MessengerBackupParams = .live(env)

    XCTAssertThrowsError(try backup(.stub)) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerBackupParams.Error.notRunning as NSError
      )
    }
  }
}
