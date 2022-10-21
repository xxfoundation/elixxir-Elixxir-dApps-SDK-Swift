import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import SendRequestFeature

final class SendRequestComponentTests: XCTestCase {
  func testStart() {
    let myContact = XXClient.Contact.unimplemented("my-contact-data".data(using: .utf8)!)

    var didGetMyContact: [MessengerMyContact.IncludeFacts?] = []

    let store = TestStore(
      initialState: SendRequestComponent.State(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: SendRequestComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { includeFacts in
      didGetMyContact.append(includeFacts)
      return myContact
    }

    store.send(.start)

    store.receive(.myContactFetched(myContact)) {
      $0.myContact = myContact
    }
  }

  func testMyContactFailure() {
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: SendRequestComponent.State(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: SendRequestComponent()
    )
    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.myContact.run = { _ in throw failure }

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
      initialState: SendRequestComponent.State(
        contact: contact,
        myContact: myContact
      ),
      reducer: SendRequestComponent()
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

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { query, assignments in
        didBulkUpdateContacts.append(.init(query: query, assignments: assignments))
        return 0
      }
      return db
    }
    store.dependencies.app.messenger.e2e.get = {
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
      initialState: SendRequestComponent.State(
        contact: contact,
        myContact: myContact
      ),
      reducer: SendRequestComponent()
    )

    struct Failure: Error {}
    let failure = Failure()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.bulkUpdateContacts.run = { _, _ in return 0 }
      return db
    }
    store.dependencies.app.messenger.e2e.get = {
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
