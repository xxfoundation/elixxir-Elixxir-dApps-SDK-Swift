import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerLookupContactsTests: XCTestCase {
  func testLookup() throws {
    let contactIds = ["contact-id".data(using: .utf8)!]
    let e2eId = 123
    let udContact = Contact.unimplemented("ud-contact".data(using: .utf8)!)
    let singleRequestParams = "single-request-params".data(using: .utf8)!
    let contacts = [Contact.unimplemented("contact".data(using: .utf8)!)]

    var didMultiLookupWithParams: [MultiLookupUD.Params] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { udContact }
      return ud
    }
    env.getSingleUseParams.run = { singleRequestParams }
    env.multiLookupUD.run = { params, callback in
      didMultiLookupWithParams.append(params)
      callback.handle(.init(
        contacts: contacts,
        failedIds: [],
        errors: []
      ))
    }
    let lookup: MessengerLookupContacts = .live(env)

    let result = try lookup(ids: contactIds)

    XCTAssertNoDifference(didMultiLookupWithParams, [.init(
      e2eId: e2eId,
      udContact: udContact,
      lookupIds: contactIds,
      singleRequestParams: singleRequestParams
    )])
    XCTAssertNoDifference(result, .init(contacts: contacts, failedIds: [], errors: []))
  }

  func testLookupWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let lookup: MessengerLookupContacts = .live(env)

    XCTAssertThrowsError(try lookup(ids: [])) { error in
      XCTAssertEqual(error as? MessengerLookupContacts.Error, .notConnected)
    }
  }

  func testLookupWhenNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    env.ud.get = { nil }
    let lookup: MessengerLookupContacts = .live(env)

    XCTAssertThrowsError(try lookup(ids: [])) { error in
      XCTAssertEqual(error as? MessengerLookupContacts.Error, .notLoggedIn)
    }
  }

  func testLookupFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

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
    env.multiLookupUD.run = { _, _ in throw failure }
    let lookup: MessengerLookupContacts = .live(env)

    XCTAssertThrowsError(try lookup(ids: [])) { error in
      XCTAssertEqual(error as? Failure, failure)
    }
  }
}
