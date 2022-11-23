import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStopBackupTests: XCTestCase {
  func testStop() throws {
    var didStopBackup = 0
    var didSetBackup: [Backup?] = []

    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.stop.run = { didStopBackup += 1 }
      return backup
    }
    env.backup.set = { backup in
      didSetBackup.append(backup)
    }
    let stop: MessengerStopBackup = .live(env)

    try stop()

    XCTAssertEqual(didStopBackup, 1)
    XCTAssertEqual(didSetBackup.count, 1)
    XCTAssertNil(didSetBackup.first as? Backup)
  }

  func testStopFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.stop.run = { throw failure }
      return backup
    }
    let stop: MessengerStopBackup = .live(env)

    XCTAssertThrowsError(try stop()) { error in
      XCTAssertNoDifference(error as NSError, failure as NSError)
    }
  }

  func testStopWithoutBackup() throws {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    let stop: MessengerStopBackup = .live(env)

    try stop()
  }
}
