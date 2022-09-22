import XCTest
@testable import XXMessengerClient

final class MessengerIsListeningForMessagesTests: XCTestCase {
  func testListening() {
    var env: MessengerEnvironment = .unimplemented
    env.isListeningForMessages.get = { true }
    let isListening: MessengerIsListeningForMessages = .live(env)

    XCTAssertTrue(isListening())
  }

  func testNotListening() {
    var env: MessengerEnvironment = .unimplemented
    env.isListeningForMessages.get = { false }
    let isListening: MessengerIsListeningForMessages = .live(env)

    XCTAssertFalse(isListening())
  }
}
