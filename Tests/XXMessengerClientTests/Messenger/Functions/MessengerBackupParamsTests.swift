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
    let params = BackupParams(
      username: "test-username",
      email: "test-email",
      phone: "test-phone"
    )

    try backup(params)

    XCTAssertNoDifference(didAddJSON, [
      String(data: try params.encode(), encoding: .utf8)!
    ])
  }

  func testBackupParamsWhenNoBackup() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    let backup: MessengerBackupParams = .live(env)
    let params = BackupParams(username: "test", email: nil, phone: nil)

    XCTAssertThrowsError(try backup(params)) { error in
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
    let params = BackupParams(username: "test", email: nil, phone: nil)

    XCTAssertThrowsError(try backup(params)) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerBackupParams.Error.notRunning as NSError
      )
    }
  }
}
