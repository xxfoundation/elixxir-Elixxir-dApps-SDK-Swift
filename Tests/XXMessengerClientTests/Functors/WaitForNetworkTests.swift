import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class WaitForNetworkTests: XCTestCase {
  func testWaitSuccess() throws {
    var didWaitForNetwork: [Int] = []

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForNetwork.run = { timeoutMS in
        didWaitForNetwork.append(timeoutMS)
        return true
      }
      return cMix
    }
    let waitForNetwork: WaitForNetwork = .live(env)

    try waitForNetwork(timeoutMS: 123)

    XCTAssertNoDifference(didWaitForNetwork, [123])
  }

  func testWaitWhenNotLoaded() {
    var env: Environment = .unimplemented
    env.cMix.get = { nil }
    let waitForNetwork: WaitForNetwork = .live(env)

    XCTAssertThrowsError(try waitForNetwork()) { error in
      XCTAssertEqual(
        error as? WaitForNetwork.Error,
        WaitForNetwork.Error.notLoaded
      )
    }
  }

  func testWaitTimeout() {
    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForNetwork.run = { _ in false }
      return cMix
    }
    let waitForNetwork: WaitForNetwork = .live(env)

    XCTAssertThrowsError(try waitForNetwork()) { error in
      XCTAssertEqual(
        error as? WaitForNetwork.Error,
        WaitForNetwork.Error.timeout
      )
    }
  }
}
