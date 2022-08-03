import ComposableArchitecture
import ErrorFeature
import XCTest
@testable import LandingFeature

final class LandingFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { true }

    store.send(.viewDidLoad) {
      $0.hasStoredCMix = true
    }
  }

  func testCreateCMix() {
    var hasStoredCMix = false
    var didSetCMix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { hasStoredCMix }
    store.environment.cMixManager.create.run = { .unimplemented }
    store.environment.setCMix = { _ in didSetCMix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCMix) {
      $0.isMakingCMix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetCMix)

    hasStoredCMix = true
    mainScheduler.advance()

    store.receive(.didMakeCMix) {
      $0.isMakingCMix = false
      $0.hasStoredCMix = true
    }
  }

  func testLoadStoredCMix() {
    var didSetCMix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { true }
    store.environment.cMixManager.load.run = { .unimplemented }
    store.environment.setCMix = { _ in didSetCMix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCMix) {
      $0.isMakingCMix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetCMix)

    mainScheduler.advance()

    store.receive(.didMakeCMix) {
      $0.isMakingCMix = false
      $0.hasStoredCMix = true
    }
  }

  func testMakeCMixFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { false }
    store.environment.cMixManager.create.run = { throw error }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCMix) {
      $0.isMakingCMix = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailMakingCMix(error)) {
      $0.isMakingCMix = false
      $0.hasStoredCMix = false
      $0.error = ErrorState(error: error)
    }
  }

  func testRemoveStoredCMix() {
    var hasStoredCMix = true
    var didRemoveCMix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { hasStoredCMix }
    store.environment.cMixManager.remove.run = { didRemoveCMix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.removeStoredCMix) {
      $0.isRemovingCMix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didRemoveCMix)

    hasStoredCMix = false
    mainScheduler.advance()

    store.receive(.didRemoveStoredCMix) {
      $0.isRemovingCMix = false
      $0.hasStoredCMix = false
    }
  }

  func testRemoveStoredCMixFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cMixManager.hasStorage.run = { true }
    store.environment.cMixManager.remove.run = { throw error }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.removeStoredCMix) {
      $0.isRemovingCMix = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailRemovingStoredCMix(error)) {
      $0.isRemovingCMix = false
      $0.hasStoredCMix = true
      $0.error = ErrorState(error: error)
    }
  }
}
