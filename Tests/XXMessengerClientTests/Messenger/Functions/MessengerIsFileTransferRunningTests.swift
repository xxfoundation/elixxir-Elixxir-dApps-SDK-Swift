import XCTest
@testable import XXMessengerClient

final class MessengerIsFileTransferRunningTests: XCTestCase {
  func testIsRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = { .unimplemented }
    let isRunning: MessengerIsFileTransferRunning = .live(env)

    XCTAssertTrue(isRunning())
  }

  func testIsNotRunning() {
    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = { nil }
    let isRunning: MessengerIsFileTransferRunning = .live(env)

    XCTAssertFalse(isRunning())
  }
}
