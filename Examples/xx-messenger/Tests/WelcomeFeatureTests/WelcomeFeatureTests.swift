import ComposableArchitecture
import XCTest
@testable import WelcomeFeature

@MainActor
final class WelcomeFeatureTests: XCTestCase {
  func testNewAccountTapped() {
    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    var didCreateMessenger = 0

    let store = TestStore(
      initialState: WelcomeState(),
      reducer: welcomeReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.create.run = { didCreateMessenger += 1 }

    store.send(.newAccountTapped) {
      $0.isCreatingAccount = true
      $0.failure = nil
    }

    bgQueue.advance()

    XCTAssertNoDifference(didCreateMessenger, 1)

    mainQueue.advance()

    store.receive(.finished) {
      $0.isCreatingAccount = false
      $0.failure = nil
    }
  }

  func testNewAccountTappedMessengerCreateFailure() {
    struct Failure: Error {}
    let failure = Failure()
    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    let store = TestStore(
      initialState: WelcomeState(),
      reducer: welcomeReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.create.run = { throw failure }

    store.send(.newAccountTapped) {
      $0.isCreatingAccount = true
      $0.failure = nil
    }

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.failed(failure.localizedDescription)) {
      $0.isCreatingAccount = false
      $0.failure = failure.localizedDescription
    }
  }

  func testRestore() {
    let store = TestStore(
      initialState: WelcomeState(),
      reducer: welcomeReducer,
      environment: .unimplemented
    )

    store.send(.restoreTapped)
  }
}
