import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerSearchContactsTests: XCTestCase {
  func testSearch() throws {
    struct SearchUdParams: Equatable {
      var e2eId: Int
      var udContact: Contact
      var facts: [Fact]
      var singleRequestParamsJSON: Data
    }

    var didSearchUdWithParams: [SearchUdParams] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { e2eId, udContact, facts, singleRequestParamsJSON, callback in
      didSearchUdWithParams.append(.init(
        e2eId: e2eId,
        udContact: udContact,
        facts: facts,
        singleRequestParamsJSON: singleRequestParamsJSON
      ))
      callback.handle(.success([
        .unimplemented("contact-1".data(using: .utf8)!),
        .unimplemented("contact-2".data(using: .utf8)!),
        .unimplemented("contact-3".data(using: .utf8)!),
      ]))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let search: MessengerSearchContacts = .live(env)
    let query = MessengerSearchContacts.Query(
      username: "Username",
      email: "Email",
      phone: "Phone"
    )

    let contacts = try search(query: query)

    XCTAssertNoDifference(didSearchUdWithParams, [.init(
      e2eId: 123,
      udContact: .unimplemented("ud-contact".data(using: .utf8)!),
      facts: query.facts,
      singleRequestParamsJSON: "single-use-params".data(using: .utf8)!
    )])

    XCTAssertNoDifference(contacts, [
      .unimplemented("contact-1".data(using: .utf8)!),
      .unimplemented("contact-2".data(using: .utf8)!),
      .unimplemented("contact-3".data(using: .utf8)!),
    ])
  }

  func testSearchNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let search: MessengerSearchContacts = .live(env)

    XCTAssertThrowsError(try search(query: .init())) { error in
      XCTAssertNoDifference(error as? MessengerSearchContacts.Error, .notConnected)
    }
  }

  func testSearchNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    env.ud.get = { nil }
    let search: MessengerSearchContacts = .live(env)

    XCTAssertThrowsError(try search(query: .init())) { error in
      XCTAssertNoDifference(error as? MessengerSearchContacts.Error, .notLoggedIn)
    }
  }

  func testSearchFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 0 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented(Data()) }
      return ud
    }
    env.getSingleUseParams.run = { Data() }
    env.searchUD.run = { _, _, _, _, _ in throw error }

    let search: MessengerSearchContacts = .live(env)

    XCTAssertThrowsError(try search(query: .init())) { err in
      XCTAssertNoDifference(err as? Failure, error)
    }
  }

  func testSearchCallbackFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 0 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented(Data()) }
      return ud
    }
    env.getSingleUseParams.run = { Data() }
    env.searchUD.run = { _, _, _, _, callback in
      callback.handle(.failure(error as NSError))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let search: MessengerSearchContacts = .live(env)

    XCTAssertThrowsError(try search(query: .init())) { err in
      XCTAssertNoDifference(err as? Failure, error)
    }
  }

  func testQueryIsEmpty() {
    let emptyQueries: [MessengerSearchContacts.Query] = [
      .init(username: nil, email: nil, phone: nil),
      .init(username: "", email: nil, phone: nil),
      .init(username: nil, email: "", phone: nil),
      .init(username: nil, email: nil, phone: ""),
      .init(username: "", email: "", phone: ""),
    ]

    emptyQueries.forEach { query in
      XCTAssertTrue(query.isEmpty, "\(query) should be empty")
    }

    let nonEmptyQueries: [MessengerSearchContacts.Query] = [
      .init(username: "test", email: nil, phone: nil),
      .init(username: nil, email: "test", phone: nil),
      .init(username: nil, email: nil, phone: "test"),
      .init(username: "a", email: "b", phone: "c"),
    ]

    nonEmptyQueries.forEach { query in
      XCTAssertFalse(query.isEmpty, "\(query) should not be empty")
    }
  }

  func testQueryFacts() {
    XCTAssertNoDifference(
      MessengerSearchContacts.Query(username: nil, email: nil, phone: nil).facts,
      []
    )

    XCTAssertNoDifference(
      MessengerSearchContacts.Query(username: "", email: "", phone: "").facts,
      []
    )

    XCTAssertNoDifference(
      MessengerSearchContacts.Query(
        username: "username",
        email: "email",
        phone: "phone"
      ).facts,
      [
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
      ]
    )

    XCTAssertNoDifference(
      MessengerSearchContacts.Query(
        username: "username",
        email: "",
        phone: nil
      ).facts,
      [
        Fact(type: .username, value: "username"),
      ]
    )
  }
}
