import XCTest
@testable import XXMessengerClient

final class MessengerIsConnectedTests: XCTestCase {
  func testWithE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertTrue(isConnected())
  }

  func testWithoutE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertFalse(isConnected())
  }
}
