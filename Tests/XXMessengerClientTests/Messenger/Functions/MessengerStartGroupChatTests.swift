import CustomDump
import XXClient
import XCTest
@testable import XXMessengerClient

final class MessengerStartGroupChatTests: XCTestCase {
  func testStart() throws {
    var didCreateNewGroupChatWithE2eId: [Int] = []
    var didSetGroupChat: [GroupChat?] = []

    let e2eId = 123
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.groupRequests.registered = { .unimplemented }
    env.groupChatProcessors.registered = { .unimplemented }
    env.newGroupChat.run = { e2eId, _, _ in
      didCreateNewGroupChatWithE2eId.append(e2eId)
      return .unimplemented
    }
    env.groupChat.set = { groupChat in
      didSetGroupChat.append(groupChat)
    }
    let start: MessengerStartGroupChat = .live(env)

    try start()

    XCTAssertEqual(didCreateNewGroupChatWithE2eId, [e2eId])
    XCTAssertEqual(didSetGroupChat.map { $0 != nil }, [true])
  }

  func testStartWithoutE2E() throws {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let start: MessengerStartGroupChat = .live(env)

    XCTAssertThrowsError(try start()) { error in
      XCTAssertEqual(error as? MessengerStartGroupChat.Error, .notConnected)
    }
  }
}
