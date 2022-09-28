import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerResumeBackupTests: XCTestCase {
  func testResume() throws {
    struct ResumeBackupParams: Equatable {
      var e2eId: Int
      var udId: Int
    }
    var didResumeBackup: [ResumeBackupParams] = []
    var backupCallbacks: [UpdateBackupFunc] = []
    var didHandleCallback: [Data] = []
    var didSetBackup: [Backup?] = []

    let e2eId = 123
    let udId = 321
    let data = "test-data".data(using: .utf8)!

    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    env.backup.set = { didSetBackup.append($0) }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getId.run = { udId }
      return ud
    }
    env.backupCallbacks.registered = {
      UpdateBackupFunc { didHandleCallback.append($0) }
    }
    env.resumeBackup.run = { e2eId, udId, callback in
      didResumeBackup.append(.init(e2eId: e2eId, udId: udId))
      backupCallbacks.append(callback)
      return .unimplemented
    }
    let resume: MessengerResumeBackup = .live(env)

    try resume()

    XCTAssertNoDifference(didResumeBackup, [
      .init(e2eId: e2eId, udId: udId)
    ])
    XCTAssertNoDifference(didSetBackup.map { $0 != nil }, [true])

    backupCallbacks.forEach { $0.handle(data) }

    XCTAssertNoDifference(didHandleCallback, [data])
  }

  func testResumeWhenRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = {
      var backup: Backup = .unimplemented
      backup.isRunning.run = { true }
      return backup
    }
    let resume: MessengerResumeBackup = .live(env)

    XCTAssertThrowsError(try resume()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerResumeBackup.Error.isRunning as NSError
      )
    }
  }

  func testResumeWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    env.e2e.get = { nil }
    let resume: MessengerResumeBackup = .live(env)

    XCTAssertThrowsError(try resume()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerResumeBackup.Error.notConnected as NSError
      )
    }
  }

  func testResumeWhenNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    env.e2e.get = { .unimplemented }
    env.ud.get = { nil }
    let resume: MessengerResumeBackup = .live(env)

    XCTAssertThrowsError(try resume()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerResumeBackup.Error.notLoggedIn as NSError
      )
    }
  }

  func testResumeFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.backup.get = { nil }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getId.run = { 321 }
      return ud
    }
    env.backupCallbacks.registered = { UpdateBackupFunc { _ in  } }
    env.resumeBackup.run = { _, _ , _ in throw failure }
    let resume: MessengerResumeBackup = .live(env)

    XCTAssertThrowsError(try resume()) { error in
      XCTAssertNoDifference(error as NSError, failure as NSError)
    }
  }
}
