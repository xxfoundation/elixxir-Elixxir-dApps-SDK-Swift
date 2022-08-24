import ComposableArchitecture
import XCTest
@testable import RegisterFeature

@MainActor
final class RegisterFeatureTests: XCTestCase {
  func testRegister() throws {
    let store = TestStore(
      initialState: RegisterState(),
      reducer: registerReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test
    var messengerDidRegisterUsername: [String] = []

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.register.run = { username in
      messengerDidRegisterUsername.append(username)
    }

    store.send(.set(\.$username, "NewUser")) {
      $0.username = "NewUser"
    }

    store.send(.registerTapped) {
      $0.isRegistering = true
    }

    XCTAssertNoDifference(messengerDidRegisterUsername, [])

    bgQueue.advance()

    XCTAssertNoDifference(messengerDidRegisterUsername, ["NewUser"])

    mainQueue.advance()

    store.receive(.finished)
  }

  func testRegisterFailure() throws {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    let store = TestStore(
      initialState: RegisterState(),
      reducer: registerReducer,
      environment: .unimplemented
    )

    let mainQueue = DispatchQueue.test
    let bgQueue = DispatchQueue.test

    store.environment.mainQueue = mainQueue.eraseToAnyScheduler()
    store.environment.bgQueue = bgQueue.eraseToAnyScheduler()
    store.environment.messenger.register.run = { _ in throw error }

    store.send(.registerTapped) {
      $0.isRegistering = true
    }

    bgQueue.advance()
    mainQueue.advance()

    store.receive(.failed(error.localizedDescription)) {
      $0.isRegistering = false
      $0.failure = error.localizedDescription
    }
  }
}
