import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class SendImageTests: XCTestCase {
  func testSend() {
    let image = "image-data".data(using: .utf8)!
    let recipientId = "recipient-id".data(using: .utf8)!

    var actions: [Action] = []

    let messenger: Messenger = .unimplemented
    let db: DBManagerGetDB = .unimplemented
    let now: () -> Date = Date.init
    let send: SendImage = .live(messenger: messenger, db: db, now: now)

    actions = []
    send(
      image,
      to: recipientId,
      onError: { error in
        actions.append(.didFail(error as NSError))
      },
      completion: {
        actions.append(.didComplete)
      }
    )

    XCTAssertNoDifference(actions, [
      .didComplete
    ])
  }
}

private enum Action: Equatable {
  case didFail(NSError)
  case didComplete
}
