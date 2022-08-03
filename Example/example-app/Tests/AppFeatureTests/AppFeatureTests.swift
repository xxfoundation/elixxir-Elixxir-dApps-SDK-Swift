import Combine
import ComposableArchitecture
import LandingFeature
import SessionFeature
import XCTest
@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    let newId = UUID()
    let hasCMix = PassthroughSubject<Bool, Never>()
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.makeId = { newId }
    store.environment.hasCMix = { hasCMix.eraseToAnyPublisher() }
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.viewDidLoad)

    hasCMix.send(false)
    mainScheduler.advance()

    store.receive(.cMixDidChange(hasCMix: false))

    hasCMix.send(true)
    mainScheduler.advance()

    store.receive(.cMixDidChange(hasCMix: true)) {
      $0.scene = .session(SessionState(id: newId))
    }

    hasCMix.send(true)
    mainScheduler.advance()

    hasCMix.send(false)
    mainScheduler.advance()

    store.receive(.cMixDidChange(hasCMix: false)) {
      $0.scene = .landing(LandingState(id: newId))
    }

    hasCMix.send(completion: .finished)
    mainScheduler.advance()
  }
}
