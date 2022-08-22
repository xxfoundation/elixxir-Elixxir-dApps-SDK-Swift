import XCTest
@testable import XXMessengerClient

final class MessengerIsConnectedTests: XCTestCase {
  func testWithE2E() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.e2e = .unimplemented
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertTrue(isConnected())
  }

  func testWithoutE2E() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.e2e = nil
    let isConnected: MessengerIsConnected = .live(env)

    XCTAssertFalse(isConnected())
  }
}
