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

    enum Action: Equatable {
      case didCreateMessenger
      case didRemoveDB
    }
    var actions: [Action] = []

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.create.run = { actions.append(.didCreateMessenger) }
    store.environment.dbManager.removeDB.run = { actions.append(.didRemoveDB) }

    store.send(.newAccountTapped) {
      $0.isCreatingAccount = true
      $0.failure = nil
    }

    bgQueue.advance()

    XCTAssertNoDifference(actions, [
      .didRemoveDB,
      .didCreateMessenger
    ])

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
    store.environment.dbManager.removeDB.run = {}

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

  func testNewAccountTappedRemoveDBFailure() {
    struct Failure: Error, Equatable {}
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
    store.environment.messenger.create.run = {}
    store.environment.dbManager.removeDB.run = { throw failure }

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
