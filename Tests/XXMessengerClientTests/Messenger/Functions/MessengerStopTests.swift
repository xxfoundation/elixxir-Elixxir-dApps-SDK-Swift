import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStopTests: XCTestCase {
  func testStop() throws {
    var didStopNetworkFollower = 0

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.stopNetworkFollower.run = { didStopNetworkFollower += 1 }
      return cMix
    }
    let stop: MessengerStop = .live(env)

    try stop()

    XCTAssertNoDifference(didStopNetworkFollower, 1)
  }

  func testStopWhenNotLoaded() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let stop: MessengerStop = .live(env)

    XCTAssertThrowsError(try stop()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerStop.Error.notLoaded as NSError
      )
    }
  }

  func testStopWhenNotRunning() throws {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .stopped }
      return cMix
    }
    let stop: MessengerStop = .live(env)

    try stop()
  }

  func testStopFailure() {
    struct Failure: Error {}
    let failure = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.stopNetworkFollower.run = { throw failure }
      return cMix
    }
    let stop: MessengerStop = .live(env)

    XCTAssertThrowsError(try stop()) { error in
      XCTAssertNoDifference(
        error as NSError,
        failure as NSError
      )
    }
  }

  func testStopAndWait() throws {
    var hasRunningProcesses: [Bool] = [true, true, false]
    var didStopNetworkFollower = 0
    var didSleep: [TimeInterval] = []

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.stopNetworkFollower.run = { didStopNetworkFollower += 1 }
      cMix.hasRunningProcesses.run = { hasRunningProcesses.removeFirst() }
      return cMix
    }
    env.sleep = { didSleep.append($0) }
    let stop: MessengerStop = .live(env)

    try stop(wait: .init(sleepInterval: 123, retries: 3))

    XCTAssertNoDifference(didStopNetworkFollower, 1)
    XCTAssertNoDifference(didSleep, [123, 123])
  }

  func testStopAndWaitTimeout() {
    var hasRunningProcesses: [Bool] = [true, true, true, true]
    var didStopNetworkFollower = 0
    var didSleep: [TimeInterval] = []

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.stopNetworkFollower.run = { didStopNetworkFollower += 1 }
      cMix.hasRunningProcesses.run = { hasRunningProcesses.removeFirst() }
      return cMix
    }
    env.sleep = { didSleep.append($0) }
    let stop: MessengerStop = .live(env)

    XCTAssertThrowsError(
      try stop(wait: .init(
        sleepInterval: 123,
        retries: 3
      ))
    ) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerStop.Error.timedOut as NSError
      )
    }

    XCTAssertNoDifference(didStopNetworkFollower, 1)
    XCTAssertNoDifference(didSleep, [123, 123, 123])
  }
}
