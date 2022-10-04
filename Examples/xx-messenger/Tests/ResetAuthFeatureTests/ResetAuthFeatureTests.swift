import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
@testable import ResetAuthFeature

final class ResetAuthFeatureTests: XCTestCase {
  func testReset() {
    let partnerData = "contact-data".data(using: .utf8)!
    let partner = Contact.unimplemented(partnerData)

    var didResetAuthChannel: [Contact] = []

    let store = TestStore(
      initialState: ResetAuthState(
        partner: partner
      ),
      reducer: resetAuthReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.resetAuthenticatedChannel.run = { contact in
        didResetAuthChannel.append(contact)
        return 0
      }
      return e2e
    }

    store.send(.resetTapped) {
      $0.isResetting = true
    }

    XCTAssertNoDifference(didResetAuthChannel, [partner])

    store.receive(.didReset) {
      $0.isResetting = false
      $0.didReset = true
    }
  }

  func testResetFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: ResetAuthState(
        partner: .unimplemented(Data())
      ),
      reducer: resetAuthReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.resetAuthenticatedChannel.run = { _ in throw failure }
      return e2e
    }

    store.send(.resetTapped) {
      $0.isResetting = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.isResetting = false
      $0.failure = failure.localizedDescription
    }
  }
}
