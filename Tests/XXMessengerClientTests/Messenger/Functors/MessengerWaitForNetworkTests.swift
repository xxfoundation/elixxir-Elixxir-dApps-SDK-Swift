import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerWaitForNetworkTests: XCTestCase {
  func testWaitSuccess() throws {
    var didWaitForNetwork: [Int] = []

    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = {
      var cMix: CMix = .unimplemented
      cMix.waitForNetwork.run = { timeoutMS in
        didWaitForNetwork.append(timeoutMS)
        return true
      }
      return cMix
    }
    let waitForNetwork: MessengerWaitForNetwork = .live(env)

    try waitForNetwork(timeoutMS: 123)

    XCTAssertNoDifference(didWaitForNetwork, [123])
  }

  func testWaitWhenNotLoaded() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = { nil }
    let waitForNetwork: MessengerWaitForNetwork = .live(env)

    XCTAssertThrowsError(try waitForNetwork()) { error in
      XCTAssertEqual(
        error as? MessengerWaitForNetwork.Error,
        MessengerWaitForNetwork.Error.notLoaded
      )
    }
  }

  func testWaitTimeout() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = {
      var cMix: CMix = .unimplemented
      cMix.waitForNetwork.run = { _ in false }
      return cMix
    }
    let waitForNetwork: MessengerWaitForNetwork = .live(env)

    XCTAssertThrowsError(try waitForNetwork()) { error in
      XCTAssertEqual(
        error as? MessengerWaitForNetwork.Error,
        MessengerWaitForNetwork.Error.timeout
      )
    }
  }
}
