import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import XCTest
@testable import MyIdentityFeature

final class MyIdentityFeatureTests: XCTestCase {
  func testViewDidLoad() {
    let myIdentitySubject = PassthroughSubject<Identity?, Never>()
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyIdentityEnvironment.failing
    env.observeIdentity = { myIdentitySubject.eraseToAnyPublisher() }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyIdentityState(id: UUID()),
      reducer: myIdentityReducer,
      environment: env
    )

    store.send(.viewDidLoad)
    store.receive(.observeMyIdentity)

    bgScheduler.advance()
    let identity = Identity.stub()
    myIdentitySubject.send(identity)
    mainScheduler.advance()

    store.receive(.didUpdateMyIdentity(identity)) {
      $0.identity = identity
    }

    myIdentitySubject.send(nil)
    mainScheduler.advance()

    store.receive(.didUpdateMyIdentity(nil)) {
      $0.identity = nil
    }

    myIdentitySubject.send(completion: .finished)
    mainScheduler.advance()
  }
}

private extension Identity {
  static func stub() -> Identity {
    Identity(
      id: "\(Int.random(in: 100...999))".data(using: .utf8)!,
      rsaPrivatePem: "\(Int.random(in: 100...999))".data(using: .utf8)!,
      salt: "\(Int.random(in: 100...999))".data(using: .utf8)!,
      dhKeyPrivate: "\(Int.random(in: 100...999))".data(using: .utf8)!
    )
  }
}
