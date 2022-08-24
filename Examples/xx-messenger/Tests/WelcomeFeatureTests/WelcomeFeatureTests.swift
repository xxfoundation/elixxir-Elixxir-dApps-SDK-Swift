import ComposableArchitecture
import XCTest
@testable import WelcomeFeature

@MainActor
final class WelcomeFeatureTests: XCTestCase {
  func testNewAccountTapped() {
    let store = TestStore(
      initialState: WelcomeState(),
      reducer: welcomeReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var messengerDidCreate = false

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.create.run = { messengerDidCreate = true }

    store.send(.newAccountTapped) {
      $0.isCreatingAccount = true
    }

    bgQueue.advance()

    XCTAssertTrue(messengerDidCreate)

    mainQueue.advance()

    store.receive(.finished) {
      $0.isCreatingAccount = false
    }
  }

  func testNewAccountTappedMessengerCreateFailure() {
    let store = TestStore(
      initialState: WelcomeState(),
      reducer: welcomeReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.create.run = { throw error }

    store.send(.newAccountTapped) {
      $0.isCreatingAccount = true
    }

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.failed(error.localizedDescription)) {
      $0.isCreatingAccount = false
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
