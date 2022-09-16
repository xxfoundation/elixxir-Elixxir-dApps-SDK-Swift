import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerVerifyContactTests: XCTestCase {
  func testVerifyWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let verify: MessengerVerifyContact = .live(env)
    let contact = Contact.unimplemented("data".data(using: .utf8)!)

    XCTAssertThrowsError(try verify(contact)) { error in
      XCTAssertNoDifference(error as? MessengerVerifyContact.Error, .notConnected)
    }
  }

  func testVerifyWhenNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    env.ud.get = { nil }
    let verify: MessengerVerifyContact = .live(env)
    let contact = Contact.unimplemented("data".data(using: .utf8)!)

    XCTAssertThrowsError(try verify(contact)) { error in
      XCTAssertNoDifference(error as? MessengerVerifyContact.Error, .notLoggedIn)
    }
  }

  func testVerifyContactWithoutFacts() throws {
    struct VerifyOwnershipParams: Equatable {
      var received: Contact
      var verified: Contact
      var e2eId: Int
    }
    var didLookupUDWithParams: [LookupUD.Params] = []
    var didVerifyOwnershipWithParams: [VerifyOwnershipParams] = []

    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    contact.getFactsFromContact.run = { _ in [] }

    let lookedUpContact = Contact.unimplemented("looked-up-contact-data".data(using: .utf8)!)

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      e2e.verifyOwnership.run = { received, verified, e2eId in
        didVerifyOwnershipWithParams.append(.init(
          received: received,
          verified: verified,
          e2eId: e2eId
        ))
        return true
      }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.lookupUD.run = { params, callback in
      didLookupUDWithParams.append(params)
      callback.handle(.success(lookedUpContact))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }
    let verify: MessengerVerifyContact = .live(env)

    let result = try verify(contact)

    XCTAssertNoDifference(didLookupUDWithParams, [.init(
      e2eId: 123,
      udContact: .unimplemented("ud-contact-data".data(using: .utf8)!),
      lookupId: "contact-id".data(using: .utf8)!,
      singleRequestParamsJSON: "single-use-params".data(using: .utf8)!
    )])

    XCTAssertNoDifference(didVerifyOwnershipWithParams, [.init(
      received: contact,
      verified: lookedUpContact,
      e2eId: 123
    )])

    XCTAssertTrue(result)
  }

  func testVerifyContactWithoutFactsLookupFailure() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getFactsFromContact.run = { _ in [] }
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }

    let lookupFailure = NSError(domain: "test", code: 111)

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.lookupUD.run = { _, callback in
      callback.handle(.failure(lookupFailure))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }
    let verify: MessengerVerifyContact = .live(env)

    XCTAssertThrowsError(try verify(contact)) { error in
      XCTAssertNoDifference(error as NSError, lookupFailure)
    }
  }

  func testVerifyContactWithFacts() throws {
    struct VerifyOwnershipParams: Equatable {
      var received: Contact
      var verified: Contact
      var e2eId: Int
    }
    var didSearchUDWithParams: [SearchUD.Params] = []
    var didVerifyOwnershipWithParams: [VerifyOwnershipParams] = []

    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    let contactFacts = [
      Fact(type: .username, value: "contact-username"),
      Fact(type: .email, value: "contact-email"),
      Fact(type: .phone, value: "contact-phone"),
    ]
    contact.getFactsFromContact.run = { _ in contactFacts }

    let foundContact = Contact.unimplemented("found-contact-data".data(using: .utf8)!)

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      e2e.verifyOwnership.run = { received, verified, e2eId in
        didVerifyOwnershipWithParams.append(.init(
          received: received,
          verified: verified,
          e2eId: e2eId
        ))
        return true
      }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { params, callback in
      didSearchUDWithParams.append(params)
      callback.handle(.success([foundContact]))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let verify: MessengerVerifyContact = .live(env)

    let result = try verify(contact)

    XCTAssertNoDifference(didSearchUDWithParams, [.init(
      e2eId: 123,
      udContact: .unimplemented("ud-contact-data".data(using: .utf8)!),
      facts: contactFacts,
      singleRequestParamsJSON: "single-use-params".data(using: .utf8)!
    )])
    XCTAssertNoDifference(didVerifyOwnershipWithParams, [.init(
      received: contact,
      verified: foundContact,
      e2eId: 123
    )])

    XCTAssertTrue(result)
  }

  func testVerifyContactWithFactsEmptySearchResults() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    let contactFacts = [
      Fact(type: .username, value: "contact-username"),
      Fact(type: .email, value: "contact-email"),
      Fact(type: .phone, value: "contact-phone"),
    ]
    contact.getFactsFromContact.run = { _ in contactFacts }

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { _, callback in
      callback.handle(.success([]))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let verify: MessengerVerifyContact = .live(env)

    let result = try verify(contact)

    XCTAssertFalse(result)
  }

  func testVerifyContactWithFactsSearchFailure() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    let contactFacts = [
      Fact(type: .username, value: "contact-username"),
      Fact(type: .email, value: "contact-email"),
      Fact(type: .phone, value: "contact-phone"),
    ]
    contact.getFactsFromContact.run = { _ in contactFacts }

    let searchFailure = NSError(domain: "test", code: 111)

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { _, callback in
      callback.handle(.failure(searchFailure))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let verify: MessengerVerifyContact = .live(env)

    XCTAssertThrowsError(try verify(contact)) { error in
      XCTAssertNoDifference(error as NSError, searchFailure)
    }
  }
  func testVerifyContactWithFactsVerifyOwnershipReturnsFalse() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    let contactFacts = [
      Fact(type: .username, value: "contact-username"),
      Fact(type: .email, value: "contact-email"),
      Fact(type: .phone, value: "contact-phone"),
    ]
    contact.getFactsFromContact.run = { _ in contactFacts }

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      e2e.verifyOwnership.run = { _, _, _ in false }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { _, callback in
      callback.handle(.success([.unimplemented("found-contact-data".data(using: .utf8)!)]))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let verify: MessengerVerifyContact = .live(env)

    let result = try verify(contact)

    XCTAssertFalse(result)
  }

  func testVerifyContactWithFactsVerifyOwnershipFailure() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getIdFromContact.run = { _ in "contact-id".data(using: .utf8)! }
    let contactFacts = [
      Fact(type: .username, value: "contact-username"),
      Fact(type: .email, value: "contact-email"),
      Fact(type: .phone, value: "contact-phone"),
    ]
    contact.getFactsFromContact.run = { _ in contactFacts }

    let verifyOwnershipFailure = NSError(domain: "test", code: 111)

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      e2e.verifyOwnership.run = { _, _, _ in
        throw verifyOwnershipFailure
      }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getContact.run = { .unimplemented("ud-contact-data".data(using: .utf8)!) }
      return ud
    }
    env.getSingleUseParams.run = { "single-use-params".data(using: .utf8)! }
    env.searchUD.run = { _, callback in
      callback.handle(.success([.unimplemented("found-contact-data".data(using: .utf8)!)]))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }

    let verify: MessengerVerifyContact = .live(env)

    XCTAssertThrowsError(try verify(contact)) { error in
      XCTAssertNoDifference(error as NSError, verifyOwnershipFailure)
    }
  }
}
