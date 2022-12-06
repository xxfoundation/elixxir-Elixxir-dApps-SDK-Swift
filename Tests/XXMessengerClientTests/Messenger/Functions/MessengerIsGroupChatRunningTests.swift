import XCTest
@testable import XXMessengerClient

final class MessengerIsGroupChatRunningTests: XCTestCase {
  func testIsRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.groupChat.get = { .unimplemented }
    let isRunning: MessengerIsGroupChatRunning = .live(env)

    XCTAssertTrue(isRunning())
  }

  func testIsNotRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.groupChat.get = { nil }
    let isRunning: MessengerIsGroupChatRunning = .live(env)

    XCTAssertFalse(isRunning())
  }
}
