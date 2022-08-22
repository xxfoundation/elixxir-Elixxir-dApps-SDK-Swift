import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerUDTests: XCTestCase {
  func testUD() throws {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getE2E = { .unimplemented }
    let e2e: MessengerE2E = .live(env)

    XCTAssertNotNil(e2e())
  }

  func testE2EWhenNotSet() throws {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getE2E = { nil }
    let e2e: MessengerE2E = .live(env)

    XCTAssertNil(e2e())
  }
}
