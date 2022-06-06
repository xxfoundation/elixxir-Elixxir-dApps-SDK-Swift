import Combine
import ComposableArchitecture
import LandingFeature
import SessionFeature
import XCTest
@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    let newId = UUID()
    let hasClient = PassthroughSubject<Bool, Never>()
    let mainScheduler = DispatchQueue.test

    var env = AppEnvironment.failing
    env.makeId = { newId }
    env.hasClient = hasClient.eraseToAnyPublisher()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: env
    )

    store.send(.viewDidLoad)

    hasClient.send(false)
    mainScheduler.advance()

    store.receive(.clientDidChange(hasClient: false))

    hasClient.send(true)
    mainScheduler.advance()

    store.receive(.clientDidChange(hasClient: true)) {
      $0.scene = .session(SessionState(id: newId))
    }

    hasClient.send(true)
    mainScheduler.advance()

    hasClient.send(false)
    mainScheduler.advance()

    store.receive(.clientDidChange(hasClient: false)) {
      $0.scene = .landing(LandingState(id: newId))
    }

    hasClient.send(completion: .finished)
    mainScheduler.advance()
  }
}
