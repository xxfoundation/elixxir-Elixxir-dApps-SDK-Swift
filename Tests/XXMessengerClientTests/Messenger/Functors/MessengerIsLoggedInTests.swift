import XCTest
@testable import XXMessengerClient

final class MessengerIsLoggedInTests: XCTestCase {
  func testWithUD() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.ud = .unimplemented
    let isLoggedIn: MessengerIsLoggedIn = .live(env)

    XCTAssertTrue(isLoggedIn())
  }

  func testWithoutUD() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.ud = nil
    let isLoggedIn: MessengerIsLoggedIn = .live(env)

    XCTAssertFalse(isLoggedIn())
  }
}
