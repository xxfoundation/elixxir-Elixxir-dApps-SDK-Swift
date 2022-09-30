import ComposableArchitecture
import XCTest
@testable import ContactLookupFeature

final class ContactLookupFeatureTests: XCTestCase {
  func testTask() {
    let store = TestStore(
      initialState: ContactLookupState(
        id: "1234".data(using: .utf8)!
      ),
      reducer: contactLookupReducer,
      environment: .unimplemented
    )

    store.send(.task)

    store.send(.cancelTask)
  }

  func testLookup() {
    let store = TestStore(
      initialState: ContactLookupState(
        id: "1234".data(using: .utf8)!
      ),
      reducer: contactLookupReducer,
      environment: .unimplemented
    )

    store.send(.lookupTapped)
  }
}
