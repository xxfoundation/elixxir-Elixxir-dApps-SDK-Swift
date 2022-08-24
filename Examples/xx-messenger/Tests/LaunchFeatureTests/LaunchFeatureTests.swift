import AppCore
import ComposableArchitecture
import RegisterFeature
import RestoreFeature
import WelcomeFeature
import XCTest
import XXModels
@testable import LaunchFeature

@MainActor
final class LaunchFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var didMakeDB = 0
    var messengerDidLoad = 0
    var messengerDidStart = 0
    var messengerDidConnect = 0
    var messengerDidLogIn = 0

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { didMakeDB += 1 }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { messengerDidLoad += 1 }
    store.environment.messenger.start.run = { _ in messengerDidStart += 1 }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(didMakeDB, 1)
    XCTAssertNoDifference(messengerDidLoad, 1)
    XCTAssertNoDifference(messengerDidStart, 1)
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)

    mainQueue.advance()

    store.receive(.finished)
  }

  func testStartWithoutMessengerCreated() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { false }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .welcome(WelcomeState()))) {
      $0.screen = .welcome(WelcomeState())
    }
  }

  func testStartUnregistered() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { false }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .register(RegisterState()))) {
      $0.screen = .register(RegisterState())
    }
  }

  func testStartMakeDBFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerLoadFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerStartFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.start.run = { _ in throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerConnectFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerIsRegisteredFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testStartMessengerLogInFailure() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    struct Error: Swift.Error {}
    let error = Error()

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { throw error }

    store.send(.start)

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }
  }

  func testWelcomeRestoreTapped() {
    let store = TestStore(
      initialState: LaunchState(
        screen: .welcome(WelcomeState())
      ),
      reducer: launchReducer,
      environment: .unimplemented
    )

    store.send(.welcome(.restoreTapped)) {
      $0.screen = .restore(RestoreState())
    }
  }

  func testWelcomeFailed() {
    let store = TestStore(
      initialState: LaunchState(
        screen: .welcome(WelcomeState())
      ),
      reducer: launchReducer,
      environment: .unimplemented
    )

    let failure = "Something went wrong"

    store.send(.welcome(.failed(failure))) {
      $0.screen = .failure(failure)
    }
  }

  func testFinished() {
    let store = TestStore(
      initialState: LaunchState(),
      reducer: launchReducer,
      environment: .unimplemented
    )

    store.send(.finished)
  }
}
