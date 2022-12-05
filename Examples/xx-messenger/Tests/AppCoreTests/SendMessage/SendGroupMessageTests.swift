import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class SendGroupMessageTests: XCTestCase {
  enum Action: Equatable {
    case didReceiveError(String)
    case didComplete
  }

  var actions: [Action]!

  override func setUp() {
    actions = []
  }

  override func tearDown() {
    actions = nil
  }

  func testSend() {
    let text = "Hello!"
    let groupId = "group-id".data(using: .utf8)!

    var messenger: Messenger = .unimplemented
    var db: DBManagerGetDB = .unimplemented
    let now = Date()
    let send: SendGroupMessage = .live(
      messenger: messenger,
      db: db,
      now: { now }
    )

    send(
      text: text,
      to: groupId,
      onError: { error in
        self.actions.append(.didReceiveError(error.localizedDescription))
      },
      completion: {
        self.actions.append(.didComplete)
      }
    )

    XCTAssertNoDifference(actions, [
      .didReceiveError("SendGroupMessage is not implemented!"),
      .didComplete
    ])
  }
}

