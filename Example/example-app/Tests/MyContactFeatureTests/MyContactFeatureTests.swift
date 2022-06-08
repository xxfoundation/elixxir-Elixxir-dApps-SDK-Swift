import Combine
import ComposableArchitecture
import CustomDump
import ElixxirDAppsSDK
import ErrorFeature
import XCTest
@testable import MyContactFeature

final class MyContactFeatureTests: XCTestCase {
  func testViewDidLoad() {
    let myContactSubject = PassthroughSubject<Data?, Never>()
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyContactEnvironment.failing
    env.observeContact = { myContactSubject.eraseToAnyPublisher() }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyContactState(id: UUID()),
      reducer: myContactReducer,
      environment: env
    )

    store.send(.viewDidLoad)
    store.receive(.observeMyContact)

    bgScheduler.advance()
    let contact = "\(Int.random(in: 100...999))".data(using: .utf8)!
    myContactSubject.send(contact)
    mainScheduler.advance()

    store.receive(.didUpdateMyContact(contact)) {
      $0.contact = contact
    }

    myContactSubject.send(nil)
    mainScheduler.advance()

    store.receive(.didUpdateMyContact(nil)) {
      $0.contact = nil
    }

    myContactSubject.send(completion: .finished)
    mainScheduler.advance()
  }

  func testMakeContact() {
    let identity = Identity.stub()
    let newContact = "\(Int.random(in: 100...999))".data(using: .utf8)!
    var didMakeContactFromIdentity = [Identity]()
    var didUpdateContact = [Data?]()
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyContactEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.makeContactFromIdentity.get = { identity in
        didMakeContactFromIdentity.append(identity)
        return newContact
      }
      return client
    }
    env.updateContact = { didUpdateContact.append($0) }
    env.getIdentity = { identity }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyContactState(id: UUID()),
      reducer: myContactReducer,
      environment: env
    )

    store.send(.makeContact) {
      $0.isMakingContact = true
    }

    bgScheduler.advance()

    XCTAssertNoDifference(didMakeContactFromIdentity, [identity])
    XCTAssertNoDifference(didUpdateContact, [newContact])

    mainScheduler.advance()

    store.receive(.didFinishMakingContact(nil)) {
      $0.isMakingContact = false
    }
  }

  func testMakeContactWithoutIdentity() {
    let error = NoIdentityError() as NSError
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyContactEnvironment.failing
    env.getIdentity = { nil }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyContactState(id: UUID()),
      reducer: myContactReducer,
      environment: env
    )

    store.send(.makeContact) {
      $0.isMakingContact = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFinishMakingContact(error)) {
      $0.isMakingContact = false
      $0.error = ErrorState(error: error)
    }

    store.send(.didDismissError) {
      $0.error = nil
    }
  }

  func testMakeContactFailure() {
    let error = NSError(domain: "test", code: 1234)
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = MyContactEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.makeContactFromIdentity.get = { _ in throw error }
      return client
    }
    env.getIdentity = { .stub() }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: MyContactState(id: UUID()),
      reducer: myContactReducer,
      environment: env
    )

    store.send(.makeContact) {
      $0.isMakingContact = true
    }

    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didFinishMakingContact(error)) {
      $0.isMakingContact = false
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
