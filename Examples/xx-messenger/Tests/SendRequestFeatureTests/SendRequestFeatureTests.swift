import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXModels
@testable import SendRequestFeature

final class SendRequestFeatureTests: XCTestCase {
  func testStart() {
    var didSetFactsOnE2EContact: [[Fact]] = []
    let e2eContactData = "e2e-contact-data".data(using: .utf8)!
    let e2eContactDataWithFacts = "e2e-contact-data-with-facts".data(using: .utf8)!
    let e2eContact: XXClient.Contact = {
      var contact = XXClient.Contact.unimplemented(e2eContactData)
      contact.setFactsOnContact.run = { data, facts in
        didSetFactsOnE2EContact.append(facts)
        return e2eContactDataWithFacts
      }
      return contact
    }()
    let udFacts = [
      Fact(type: .username, value: "ud-username"),
      Fact(type: .email, value: "ud-email"),
      Fact(type: .phone, value: "ud-phone"),
    ]
    let store = TestStore(
      initialState: SendRequestState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = { e2eContact }
      return e2e
    }
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getFacts.run = { udFacts }
      return ud
    }

    store.send(.start)

    store.receive(.myContactFetched(.unimplemented(e2eContactDataWithFacts))) {
      $0.myContact = .unimplemented(e2eContactDataWithFacts)
    }
  }

  func testMyContactFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: SendRequestState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )
    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = { .unimplemented(Data()) }
      return e2e
    }
    store.environment.messenger.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getFacts.run = { throw failure }
      return ud
    }

    store.send(.start)

    store.receive(.myContactFetchFailed(failure as NSError)) {
      $0.myContact = nil
      $0.failure = failure.localizedDescription
    }
  }

  func testSendRequest() {
    var contact: XXClient.Contact = .unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }

    var myContact: XXClient.Contact = .unimplemented("my-contact-data".data(using: .utf8)!)
    let myFacts = [
      Fact(type: .username, value: "my-username"),
      Fact(type: .email, value: "my-email"),
      Fact(type: .phone, value: "my-phone"),
    ]
    myContact.getFactsFromContact.run = { _ in myFacts }

    let store = TestStore(
      initialState: SendRequestState(
        contact: contact,
        myContact: myContact
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    struct DidBulkUpdateContacts: Equatable {
      var query: XXModels.Contact.Query
      var assignments: XXModels.Contact.Assignments
    }
    struct DidRequestAuthChannel: Equatable {
      var partner: XXClient.Contact
      var myFacts: [XXClient.Fact]
    }

    var didBulkUpdateContacts: [DidBulkUpdateContacts] = []
    var didRequestAuthChannel: [DidRequestAuthChannel] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.db.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContacts.append(.init(query: query, assignments: assignments))
        return 0
      }
      return db
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.requestAuthenticatedChannel.run = { partner, myFacts in
        didRequestAuthChannel.append(.init(partner: partner, myFacts: myFacts))
        return 0
      }
      return e2e
    }

    store.send(.sendTapped) {
      $0.isSending = true
    }

    XCTAssertNoDifference(didBulkUpdateContacts, [
      .init(
        query: .init(id: ["contact-id".data(using: .utf8)!]),
        assignments: .init(authStatus: .requesting)
      ),
      .init(
        query: .init(id: ["contact-id".data(using: .utf8)!]),
        assignments: .init(authStatus: .requested)
      )
    ])

    XCTAssertNoDifference(didRequestAuthChannel, [
      .init(
        partner: contact,
        myFacts: myFacts
      )
    ])

    store.receive(.sendSucceeded) {
      $0.isSending = false
    }
  }

  func testSendRequestFailure() {
    var contact: XXClient.Contact = .unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }

    var myContact: XXClient.Contact = .unimplemented("my-contact-data".data(using: .utf8)!)
    let myFacts = [
      Fact(type: .username, value: "my-username"),
      Fact(type: .email, value: "my-email"),
      Fact(type: .phone, value: "my-phone"),
    ]
    myContact.getFactsFromContact.run = { _ in myFacts }

    let store = TestStore(
      initialState: SendRequestState(
        contact: contact,
        myContact: myContact
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let failure = Failure()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.db.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { _, _ in return 0 }
      return db
    }
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.requestAuthenticatedChannel.run = { _, _ in throw failure }
      return e2e
    }

    store.send(.sendTapped) {
      $0.isSending = true
    }

    store.receive(.sendFailed(failure.localizedDescription)) {
      $0.isSending = false
      $0.failure = failure.localizedDescription
    }
  }
}
