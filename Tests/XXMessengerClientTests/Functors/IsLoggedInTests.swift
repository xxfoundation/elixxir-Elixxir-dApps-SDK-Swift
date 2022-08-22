import XCTest
@testable import XXMessengerClient

final class IsLoggedInTests: XCTestCase {
  func testWithUD() {
    var env: Environment = .unimplemented
    env.ud.get = { .unimplemented }
    let isLoggedIn: IsLoggedIn = .live(env)

    XCTAssertTrue(isLoggedIn())
  }

  func testWithoutUD() {
    var env: Environment = .unimplemented
    env.ud.get = { nil }
    let isLoggedIn: IsLoggedIn = .live(env)

    XCTAssertFalse(isLoggedIn())
  }
}
