import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXModels
@testable import CheckContactAuthFeature

final class CheckContactAuthFeatureTests: XCTestCase {
  func testCheck() {
    var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
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
    var didBulkUpdateContactsWithQuery: [XXModels.Contact.Query] = []
    var didBulkUpdateContactsWithAssignments: [XXModels.Contact.Assignments] = []

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
    store.environment.db.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContactsWithQuery.append(query)
        didBulkUpdateContactsWithAssignments.append(assignments)
        return 0
      }
      return db
    }

    store.send(.checkTapped) {
      $0.isChecking = true
      $0.result = nil
    }

    XCTAssertNoDifference(didCheckPartnerId, [contactId])
    XCTAssertNoDifference(didBulkUpdateContactsWithQuery, [.init(id: [contactId])])
    XCTAssertNoDifference(didBulkUpdateContactsWithAssignments, [.init(authStatus: .friend)])

    store.receive(.didCheck(.success(true))) {
      $0.isChecking = false
      $0.result = .success(true)
    }
  }

  func testCheckNoConnection() {
    var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
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
    var didBulkUpdateContactsWithQuery: [XXModels.Contact.Query] = []
    var didBulkUpdateContactsWithAssignments: [XXModels.Contact.Assignments] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.hasAuthenticatedChannel.run = { partnerId in
        didCheckPartnerId.append(partnerId)
        return false
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContactsWithQuery.append(query)
        didBulkUpdateContactsWithAssignments.append(assignments)
        return 0
      }
      return db
    }

    store.send(.checkTapped) {
      $0.isChecking = true
      $0.result = nil
    }

    XCTAssertNoDifference(didCheckPartnerId, [contactId])
    XCTAssertNoDifference(didBulkUpdateContactsWithQuery, [.init(id: [contactId])])
    XCTAssertNoDifference(didBulkUpdateContactsWithAssignments, [.init(authStatus: .stranger)])

    store.receive(.didCheck(.success(false))) {
      $0.isChecking = false
      $0.result = .success(false)
    }
  }

  func testCheckFailure() {
    var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
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
