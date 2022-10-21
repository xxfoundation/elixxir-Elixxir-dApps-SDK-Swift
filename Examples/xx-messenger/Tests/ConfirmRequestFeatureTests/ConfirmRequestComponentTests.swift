import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXModels
@testable import ConfirmRequestFeature

final class ConfirmRequestComponentTests: XCTestCase {
  func testConfirm() {
    var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
    let contactId = "contact-id".data(using: .utf8)!
    contact.getIdFromContact.run = { _ in contactId }

    let store = TestStore(
      initialState: ConfirmRequestComponent.State(
        contact: contact
      ),
      reducer: ConfirmRequestComponent()
    )

    var didConfirmRequestFromContact: [XXClient.Contact] = []
    var didBulkUpdateContactsWithQuery: [XXModels.Contact.Query] = []
    var didBulkUpdateContactsWithAssignments: [XXModels.Contact.Assignments] = []

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.confirmReceivedRequest.run = { contact in
        didConfirmRequestFromContact.append(contact)
        return 0
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContactsWithQuery.append(query)
        didBulkUpdateContactsWithAssignments.append(assignments)
        return 0
      }
      return db
    }

    store.send(.confirmTapped) {
      $0.isConfirming = true
      $0.result = nil
    }

    XCTAssertNoDifference(didConfirmRequestFromContact, [contact])
    XCTAssertNoDifference(didBulkUpdateContactsWithQuery, [
      .init(id: [contactId]),
      .init(id: [contactId]),
    ])
    XCTAssertNoDifference(didBulkUpdateContactsWithAssignments, [
      .init(authStatus: .confirming),
      .init(authStatus: .friend),
    ])

    store.receive(.didConfirm(.success)) {
      $0.isConfirming = false
      $0.result = .success
    }
  }

  func testConfirmFailure() {
    var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
    let contactId = "contact-id".data(using: .utf8)!
    contact.getIdFromContact.run = { _ in contactId }

    let store = TestStore(
      initialState: ConfirmRequestComponent.State(
        contact: contact
      ),
      reducer: ConfirmRequestComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    var didBulkUpdateContactsWithQuery: [XXModels.Contact.Query] = []
    var didBulkUpdateContactsWithAssignments: [XXModels.Contact.Assignments] = []

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.confirmReceivedRequest.run = { _ in throw error }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContactsWithQuery.append(query)
        didBulkUpdateContactsWithAssignments.append(assignments)
        return 0
      }
      return db
    }

    store.send(.confirmTapped) {
      $0.isConfirming = true
      $0.result = nil
    }

    XCTAssertNoDifference(didBulkUpdateContactsWithQuery, [
      .init(id: [contactId]),
      .init(id: [contactId]),
    ])
    XCTAssertNoDifference(didBulkUpdateContactsWithAssignments, [
      .init(authStatus: .confirming),
      .init(authStatus: .confirmationFailed),
    ])

    store.receive(.didConfirm(.failure(error.localizedDescription))) {
      $0.isConfirming = false
      $0.result = .failure(error.localizedDescription)
    }
  }
}
