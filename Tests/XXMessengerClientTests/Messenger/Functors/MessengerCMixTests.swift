import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerCMixTests: XCTestCase {
  func testCMix() throws {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = { .unimplemented }
    let cMix: MessengerCMix = .live(env)

    XCTAssertNotNil(cMix())
  }

  func testCMixWhenNotSet() throws {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = { nil }
    let cMix: MessengerCMix = .live(env)

    XCTAssertNil(cMix())
  }
}
