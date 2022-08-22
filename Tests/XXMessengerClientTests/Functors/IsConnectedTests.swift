import XCTest
@testable import XXMessengerClient

final class IsConnectedTests: XCTestCase {
  func testWithE2E() {
    var env: Environment = .unimplemented
    env.e2e.get = { .unimplemented }
    let isConnected: IsConnected = .live(env)

    XCTAssertTrue(isConnected())
  }

  func testWithoutE2E() {
    var env: Environment = .unimplemented
    env.e2e.get = { nil }
    let isConnected: IsConnected = .live(env)

    XCTAssertFalse(isConnected())
  }
}
