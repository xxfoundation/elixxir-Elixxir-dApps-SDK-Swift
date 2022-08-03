import Combine
import ComposableArchitecture
import LandingFeature
import SessionFeature
import XCTest
@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    let newId = UUID()
    let hasCmix = PassthroughSubject<Bool, Never>()
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.makeId = { newId }
    store.environment.hasCmix = { hasCmix.eraseToAnyPublisher() }
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.viewDidLoad)

    hasCmix.send(false)
    mainScheduler.advance()

    store.receive(.cmixDidChange(hasCmix: false))

    hasCmix.send(true)
    mainScheduler.advance()

    store.receive(.cmixDidChange(hasCmix: true)) {
      $0.scene = .session(SessionState(id: newId))
    }

    hasCmix.send(true)
    mainScheduler.advance()

    hasCmix.send(false)
    mainScheduler.advance()

    store.receive(.cmixDidChange(hasCmix: false)) {
      $0.scene = .landing(LandingState(id: newId))
    }

    hasCmix.send(completion: .finished)
    mainScheduler.advance()
  }
}
