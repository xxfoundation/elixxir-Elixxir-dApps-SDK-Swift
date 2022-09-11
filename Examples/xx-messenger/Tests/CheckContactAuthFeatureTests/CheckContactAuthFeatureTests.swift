import ComposableArchitecture
import XCTest
import XXClient
@testable import CheckContactAuthFeature

final class CheckContactAuthFeatureTests: XCTestCase {
  func testCheck() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    let contactId = "contact-id".data(using: .utf8)!
    contact.getIdFromContact.run = { _ in contactId }

    let store = TestStore(
      initialState: CheckContactAuthState(
        contact: contact
      ),
      reducer: checkContactAuthReducer,
      environment: .unimplemented
    )

    var didCheckPartnerId: [Data] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.hasAuthenticatedChannel.run = { partnerId in
        didCheckPartnerId.append(partnerId)
        return true
      }
      return e2e
    }

    store.send(.checkTapped) {
      $0.isChecking = true
      $0.result = nil
    }

    store.receive(.didCheck(.success(true))) {
      $0.isChecking = false
      $0.result = .success(true)
    }
  }

  func testCheckNoConnection() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    let contactId = "contact-id".data(using: .utf8)!
    contact.getIdFromContact.run = { _ in contactId }

    let store = TestStore(
      initialState: CheckContactAuthState(
        contact: contact
      ),
      reducer: checkContactAuthReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.hasAuthenticatedChannel.run = { _ in false }
      return e2e
    }

    store.send(.checkTapped) {
      $0.isChecking = true
      $0.result = nil
    }

    store.receive(.didCheck(.success(false))) {
      $0.isChecking = false
      $0.result = .success(false)
    }
  }

  func testCheckFailure() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    let contactId = "contact-id".data(using: .utf8)!
    contact.getIdFromContact.run = { _ in contactId }

    let store = TestStore(
      initialState: CheckContactAuthState(
        contact: contact
      ),
      reducer: checkContactAuthReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let error = Failure()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.hasAuthenticatedChannel.run = { _ in throw error }
      return e2e
    }

    store.send(.checkTapped) {
      $0.isChecking = true
      $0.result = nil
    }

    store.receive(.didCheck(.failure(error.localizedDescription))) {
      $0.isChecking = false
      $0.result = .failure(error.localizedDescription)
    }
  }
}
