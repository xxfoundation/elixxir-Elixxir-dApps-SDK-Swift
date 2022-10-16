import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerReceiveFileTests: XCTestCase {
  func testReceiveFile() throws {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    let receiveFile: MessengerReceiveFile = .live(env)

    try receiveFile()
  }

  func testReceiveFileWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let receiveFile: MessengerReceiveFile = .live(env)

    XCTAssertThrowsError(try receiveFile()) { error in
      XCTAssertNoDifference(
        error as? MessengerReceiveFile.Error,
        MessengerReceiveFile.Error.notConnected
      )
    }
  }
}
