import XCTest
@testable import XXMessengerClient

final class MessengerIsLoggedInTests: XCTestCase {
  func testWithUD() {
    var env: MessengerEnvironment = .unimplemented
    env.ud.get = { .unimplemented }
    let isLoggedIn: MessengerIsLoggedIn = .live(env)

    XCTAssertTrue(isLoggedIn())
  }

  func testWithoutUD() {
    var env: MessengerEnvironment = .unimplemented
    env.ud.get = { nil }
    let isLoggedIn: MessengerIsLoggedIn = .live(env)

    XCTAssertFalse(isLoggedIn())
  }
}
