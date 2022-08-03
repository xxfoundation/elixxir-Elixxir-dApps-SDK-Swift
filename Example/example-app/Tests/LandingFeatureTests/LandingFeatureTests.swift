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

    store.environment.cmixManager.hasStorage.run = { true }

    store.send(.viewDidLoad) {
      $0.hasStoredCmix = true
    }
  }

  func testCreateCmix() {
    var hasStoredCmix = false
    var didSetCmix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cmixManager.hasStorage.run = { hasStoredCmix }
    store.environment.cmixManager.create.run = { .unimplemented }
    store.environment.setCmix = { _ in didSetCmix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCmix) {
      $0.isMakingCmix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetCmix)

    hasStoredCmix = true
    mainScheduler.advance()

    store.receive(.didMakeCmix) {
      $0.isMakingCmix = false
      $0.hasStoredCmix = true
    }
  }

  func testLoadStoredCmix() {
    var didSetCmix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cmixManager.hasStorage.run = { true }
    store.environment.cmixManager.load.run = { .unimplemented }
    store.environment.setCmix = { _ in didSetCmix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCmix) {
      $0.isMakingCmix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didSetCmix)

    mainScheduler.advance()

    store.receive(.didMakeCmix) {
      $0.isMakingCmix = false
      $0.hasStoredCmix = true
    }
  }

  func testMakeCmixFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cmixManager.hasStorage.run = { false }
    store.environment.cmixManager.create.run = { throw error }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.makeCmix) {
      $0.isMakingCmix = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailMakingCmix(error)) {
      $0.isMakingCmix = false
      $0.hasStoredCmix = false
      $0.error = ErrorState(error: error)
    }
  }

  func testRemoveStoredCmix() {
    var hasStoredCmix = true
    var didRemoveCmix = false
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cmixManager.hasStorage.run = { hasStoredCmix }
    store.environment.cmixManager.remove.run = { didRemoveCmix = true }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.removeStoredCmix) {
      $0.isRemovingCmix = true
    }

    bgScheduler.advance()

    XCTAssertTrue(didRemoveCmix)

    hasStoredCmix = false
    mainScheduler.advance()

    store.receive(.didRemoveStoredCmix) {
      $0.isRemovingCmix = false
      $0.hasStoredCmix = false
    }
  }

  func testRemoveStoredCmixFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: LandingState(id: UUID()),
      reducer: landingReducer,
      environment: .unimplemented
    )

    store.environment.cmixManager.hasStorage.run = { true }
    store.environment.cmixManager.remove.run = { throw error }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.removeStoredCmix) {
      $0.isRemovingCmix = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFailRemovingStoredCmix(error)) {
      $0.isRemovingCmix = false
      $0.hasStoredCmix = true
      $0.error = ErrorState(error: error)
    }
  }
}
