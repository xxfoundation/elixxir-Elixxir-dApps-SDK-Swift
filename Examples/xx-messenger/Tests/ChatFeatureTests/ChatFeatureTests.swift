import ComposableArchitecture
import XCTest
@testable import ChatFeature

final class ChatFeatureTests: XCTestCase {
  func testStart() {
    let contactId = "contact-id".data(using: .utf8)!

    let store = TestStore(
      initialState: ChatState(id: .contact(contactId)),
      reducer: chatReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
