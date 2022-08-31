import ComposableArchitecture
import HomeFeature
import RestoreFeature
import WelcomeFeature
import XCTest
@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  func testStartWithoutMessengerCreated() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var didMakeDB = 0

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { didMakeDB += 1 }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { false }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(didMakeDB, 1)

    mainQueue.advance()

    store.receive(.set(\.$screen, .welcome(WelcomeState()))) {
      $0.screen = .welcome(WelcomeState())
    }
  }

  func testStartWithMessengerCreated() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var didMakeDB = 0
    var messengerDidLoad = 0

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { didMakeDB += 1 }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { messengerDidLoad += 1 }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(didMakeDB, 1)
    XCTAssertNoDifference(messengerDidLoad, 1)

    mainQueue.advance()

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
  }

  func testWelcomeFinished() {
    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var messengerDidLoad = 0

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { messengerDidLoad += 1 }

    store.send(.welcome(.finished)) {
      $0.screen = .loading
    }

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidLoad, 1)

    mainQueue.advance()

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
  }

  func testRestoreFinished() {
    let store = TestStore(
      initialState: AppState(
        screen: .restore(RestoreState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var messengerDidLoad = 0

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { messengerDidLoad += 1 }

    store.send(.restore(.finished)) {
      $0.screen = .loading
    }

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidLoad, 1)

    mainQueue.advance()

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
  }

  func testWelcomeRestoreTapped() {
    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.send(.welcome(.restoreTapped)) {
      $0.screen = .restore(RestoreState())
    }
  }

  func testWelcomeFailed() {
    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    let failure = "Something went wrong"

    store.send(.welcome(.failed(failure))) {
      $0.screen = .failure(failure)
    }
  }

  func testStartDatabaseMakeFailure() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerLoadFailure() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }
}
