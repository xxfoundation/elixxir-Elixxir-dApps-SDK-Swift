import ComposableArchitecture
import RegisterFeature
import XCTest
import XXClient
import XXMessengerClient
@testable import HomeFeature

final class HomeFeatureTests: XCTestCase {
  func testStartUnregistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { false }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)

    mainQueue.advance()

    store.receive(.set(\.$register, RegisterState())) {
      $0.register = RegisterState()
    }
  }

  func testStartRegistered() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidConnect = 0
    var messengerDidLogIn = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { messengerDidConnect += 1 }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }

    store.send(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidConnect, 1)
    XCTAssertNoDifference(messengerDidLogIn, 1)

    mainQueue.advance()
  }

  func testRegisterFinished() {
    let store = TestStore(
      initialState: HomeState(
        register: RegisterState()
      ),
      reducer: homeReducer,
      environment: .unimplemented
    )

    let bgQueue = DispatchQueue.test
    let mainQueue = DispatchQueue.test
    var messengerDidStartWithTimeout: [Int] = []
    var messengerDidLogIn = 0

    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.messenger.start.run = { messengerDidStartWithTimeout.append($0) }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { messengerDidLogIn += 1 }

    store.send(.register(.finished)) {
      $0.register = nil
    }

    store.receive(.start)

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidStartWithTimeout, [30_000])
    XCTAssertNoDifference(messengerDidLogIn, 1)

    mainQueue.advance()
  }

  func testStartMessengerStartFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerConnectFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { false }
    store.environment.messenger.connect.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerIsRegisteredFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }

  func testStartMessengerLogInFailure() {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.start.run = { _ in }
    store.environment.messenger.isConnected.run = { true }
    store.environment.messenger.isLoggedIn.run = { false }
    store.environment.messenger.isRegistered.run = { true }
    store.environment.messenger.logIn.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$failure, error.localizedDescription)) {
      $0.failure = error.localizedDescription
    }
  }
}
