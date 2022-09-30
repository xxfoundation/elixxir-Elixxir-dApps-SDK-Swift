import ComposableArchitecture
import XCTest
import XXClient
@testable import ContactLookupFeature

final class ContactLookupFeatureTests: XCTestCase {
  func testLookup() {
    let id: Data = "1234".data(using: .utf8)!
    var didLookupId: [Data] = []
    let lookedUpContact = Contact.unimplemented("123data".data(using: .utf8)!)

    let store = TestStore(
      initialState: ContactLookupState(id: id),
      reducer: contactLookupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.lookupContact.run = { id in
      didLookupId.append(id)
      return lookedUpContact
    }

    store.send(.lookupTapped) {
      $0.isLookingUp = true
    }

    XCTAssertEqual(didLookupId, [id])

    store.receive(.didLookup(lookedUpContact)) {
      $0.isLookingUp = false
    }
  }

  func testLookupFailure() {
    let id: Data = "1234".data(using: .utf8)!
    let failure = NSError(domain: "test", code: 0)

    let store = TestStore(
      initialState: ContactLookupState(id: id),
      reducer: contactLookupReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.lookupContact.run = { _ in throw failure }

    store.send(.lookupTapped) {
      $0.isLookingUp = true
    }

    store.receive(.didFail(failure)) {
      $0.failure = failure.localizedDescription
      $0.isLookingUp = false
    }
  }
}
