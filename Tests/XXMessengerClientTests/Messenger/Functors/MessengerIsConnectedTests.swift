import XCTest
@testable import XXMessengerClient

final class MessengerIsConnectedTests: XCTestCase {
  func testWithE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getE2E = { .unimplemented }
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertTrue(isConnected())
  }

  func testWithoutE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getE2E = { nil }
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertFalse(isConnected())
  }
}
