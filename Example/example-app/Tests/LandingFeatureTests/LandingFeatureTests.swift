import ComposableArchitecture
import ErrorFeature
import XCTest
@testable import LandingFeature

final class LandingFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { true }

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.viewDidLoad) {
      $0.hasStoredClient = true
    }
  }

  func testCreateClient() {
    var hasStoredClient = false
    var didSetClient = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { hasStoredClient }
    env.clientStorage.createClient = { .failing }
    env.setClient = { _ in didSetClient = true }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.makeClient) {
      $0.isMakingClient = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetClient)

    hasStoredClient = true
    mainScheduler.advance()

    store.receive(.didMakeClient) {
      $0.isMakingClient = false
      $0.hasStoredClient = true
    }
  }

  func testLoadStoredClient() {
    var didSetClient = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { true }
    env.clientStorage.loadClient = { .failing }
    env.setClient = { _ in didSetClient = true }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.makeClient) {
      $0.isMakingClient = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetClient)

    mainScheduler.advance()

    store.receive(.didMakeClient) {
      $0.isMakingClient = false
      $0.hasStoredClient = true
    }
  }

  func testMakeClientFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { false }
    env.clientStorage.createClient = { throw error }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.makeClient) {
      $0.isMakingClient = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailMakingClient(error)) {
      $0.isMakingClient = false
      $0.hasStoredClient = false
      $0.error = ErrorState(error: error)
    }
  }

  func testRemoveStoredClient() {
    var hasStoredClient = true
    var didRemoveClient = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { hasStoredClient }
    env.clientStorage.removeClient = { didRemoveClient = true }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.removeStoredClient) {
      $0.isRemovingClient = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didRemoveClient)

    hasStoredClient = false
    mainScheduler.advance()

    store.receive(.didRemoveStoredClient) {
      $0.isRemovingClient = false
      $0.hasStoredClient = false
    }
  }

  func testRemoveStoredClientFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = LandingEnvironment.failing
    env.clientStorage.hasStoredClient = { true }
    env.clientStorage.removeClient = { throw error }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: env
    )

    store.send(.removeStoredClient) {
      $0.isRemovingClient = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailRemovingStoredClient(error)) {
      $0.isRemovingClient = false
      $0.hasStoredClient = true
      $0.error = ErrorState(error: error)
    }
  }
}
