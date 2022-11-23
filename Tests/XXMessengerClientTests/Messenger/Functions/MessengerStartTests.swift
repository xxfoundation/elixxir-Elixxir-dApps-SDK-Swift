import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStartTests: XCTestCase {
  func testStart() throws {
    var didStartNetworkFollower: [Int] = []

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .stopped }
      cMix.startNetworkFollower.run = { timeoutMS in
        didStartNetworkFollower.append(timeoutMS)
      }
      return cMix
    }
    let start: MessengerStart = .live(env)

    try start(timeoutMS: 123)

    XCTAssertNoDifference(didStartNetworkFollower, [123])
  }

  func testStartWhenNotLoaded() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let start: MessengerStart = .live(env)

    XCTAssertThrowsError(try start()) { error in
      XCTAssertEqual(
        error as? MessengerStart.Error,
        MessengerStart.Error.notLoaded
      )
    }
  }

  func testStartWhenRunning() throws {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      return cMix
    }
    let start: MessengerStart = .live(env)

    try start()
  }

  func testStartNetworkFollowerFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .stopped }
      cMix.startNetworkFollower.run = { _ in throw error }
      return cMix
    }
    let start: MessengerStart = .live(env)

    XCTAssertThrowsError(try start()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
