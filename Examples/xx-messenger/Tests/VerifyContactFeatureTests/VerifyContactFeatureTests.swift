import ComposableArchitecture
import XCTest
import XXClient
@testable import VerifyContactFeature

final class VerifyContactFeatureTests: XCTestCase {
  func testVerify() {
    let store = TestStore(
      initialState: VerifyContactState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: verifyContactReducer,
      environment: .unimplemented
    )

    var didVerifyContact: [Contact] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.verifyContact.run = { contact in
      didVerifyContact.append(contact)
      return true
    }

    store.send(.verifyTapped) {
      $0.isVerifying = true
      $0.result = nil
    }

    store.receive(.didVerify(.success(true))) {
      $0.isVerifying = false
      $0.result = .success(true)
    }
  }

  func testVerifyNotVerified() {
    let store = TestStore(
      initialState: VerifyContactState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: verifyContactReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.verifyContact.run = { _ in false }

    store.send(.verifyTapped) {
      $0.isVerifying = true
      $0.result = nil
    }

    store.receive(.didVerify(.success(false))) {
      $0.isVerifying = false
      $0.result = .success(false)
    }
  }

  func testVerifyFailure() {
    let store = TestStore(
      initialState: VerifyContactState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: verifyContactReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.verifyContact.run = { _ in throw error }

    store.send(.verifyTapped) {
      $0.isVerifying = true
      $0.result = nil
    }

    store.receive(.didVerify(.failure(error.localizedDescription))) {
      $0.isVerifying = false
      $0.result = .failure(error.localizedDescription)
    }
  }
}
