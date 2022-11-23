import ComposableArchitecture
import XCTest
import XXClient
@testable import ContactLookupFeature

final class ContactLookupComponentTests: XCTestCase {
  func testLookup() {
    let id: Data = "1234".data(using: .utf8)!
    var didLookupId: [Data] = []
    let lookedUpContact = Contact.unimplemented("123data".data(using: .utf8)!)

    let store = TestStore(
      initialState: ContactLookupComponent.State(id: id),
      reducer: ContactLookupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.lookupContact.run = { id in
      didLookupId.append(id)
      return lookedUpContact
    }

    store.send(.lookupTapped) {
      $0.isLookingUp = true
      $0.failure = nil
    }

    XCTAssertEqual(didLookupId, [id])

    store.receive(.didLookup(lookedUpContact)) {
      $0.isLookingUp = false
      $0.failure = nil
    }
  }

  func testLookupFailure() {
    let id: Data = "1234".data(using: .utf8)!
    let failure = NSError(domain: "test", code: 0)

    let store = TestStore(
      initialState: ContactLookupComponent.State(id: id),
      reducer: ContactLookupComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.lookupContact.run = { _ in throw failure }

    store.send(.lookupTapped) {
      $0.isLookingUp = true
      $0.failure = nil
    }

    store.receive(.didFail(failure)) {
      $0.isLookingUp = false
      $0.failure = failure.localizedDescription
    }
  }
}
