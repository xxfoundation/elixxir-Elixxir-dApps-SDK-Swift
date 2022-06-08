import Combine
import ComposableArchitecture
import CustomDump
import ElixxirDAppsSDK
import ErrorFeature
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

  func testMakeIdentity() {
    let newIdentity = Identity.stub()
    var didUpdateIdentity = [Identity?]()
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyIdentityEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.makeIdentity.make = { newIdentity }
      return client
    }
    env.updateIdentity = { didUpdateIdentity.append($0) }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyIdentityState(id: UUID()),
      reducer: myIdentityReducer,
      environment: env
    )

    store.send(.makeIdentity) {
      $0.isMakingIdentity = true
    }

    bgScheduler.advance()

    XCTAssertNoDifference(didUpdateIdentity, [newIdentity])

    mainScheduler.advance()

    store.receive(.didFinishMakingIdentity(nil)) {
      $0.isMakingIdentity = false
    }
  }

  func testMakeIdentityFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyIdentityEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.makeIdentity.make = { throw error }
      return client
    }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyIdentityState(id: UUID()),
      reducer: myIdentityReducer,
      environment: env
    )

    store.send(.makeIdentity) {
      $0.isMakingIdentity = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFinishMakingIdentity(error)) {
      $0.isMakingIdentity = false
      $0.error = ErrorState(error: error)
    }

    store.send(.didDismissError) {
      $0.error = nil
    }
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
