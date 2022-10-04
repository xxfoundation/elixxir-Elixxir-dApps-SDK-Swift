import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerSetLogLevelTests: XCTestCase {
  func testSetLogLevel() throws {
    var didSetLogLevel: [LogLevel] = []
    var env: MessengerEnvironment = .unimplemented
    env.setLogLevel.run = { level in
      didSetLogLevel.append(level)
      return true
    }
    let setLogLevel: MessengerSetLogLevel = .live(env)

    let result = try setLogLevel(.debug)

    XCTAssertNoDifference(didSetLogLevel, [.debug])
    XCTAssertNoDifference(result, true)
  }

  func testSetLogLevelReturnsFalse() throws {
    var env: MessengerEnvironment = .unimplemented
    env.setLogLevel.run = { _ in return false }
    let setLogLevel: MessengerSetLogLevel = .live(env)

    let result = try setLogLevel(.debug)

    XCTAssertNoDifference(result, false)
  }

  func testSetLogLevelFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.setLogLevel.run = { _ in throw failure }
    let setLogLevel: MessengerSetLogLevel = .live(env)

    XCTAssertThrowsError(try setLogLevel(.debug)) { error in
      XCTAssertNoDifference(error as NSError, failure as NSError)
    }
  }
}
