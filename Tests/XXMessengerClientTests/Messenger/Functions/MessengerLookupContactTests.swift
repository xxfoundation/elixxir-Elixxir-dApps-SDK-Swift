import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerLookupContactTests: XCTestCase {
  func testLookup() throws {
    let contactId = "contact-id".data(using: .utf8)!
    let e2eId = 123
    let udContact = Contact.unimplemented("ud-contact".data(using: .utf8)!)
    let singleRequestParams = "single-request-params".data(using: .utf8)!
    let contact = Contact.unimplemented("contact".data(using: .utf8)!)

    var didLookupWithParams: [LookupUD.Params] = []

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
    env.lookupUD.run = { params, callback in
      didLookupWithParams.append(params)
      callback.handle(.success(contact))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }
    let lookup: MessengerLookupContact = .live(env)

    let result = try lookup(id: contactId)

    XCTAssertNoDifference(didLookupWithParams, [.init(
      e2eId: e2eId,
      udContact: udContact,
      lookupId: contactId,
      singleRequestParamsJSON: singleRequestParams
    )])
    XCTAssertNoDifference(result, contact)
  }

  func testLookupWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let lookup: MessengerLookupContact = .live(env)

    XCTAssertThrowsError(try lookup(id: Data())) { error in
      XCTAssertEqual(error as? MessengerLookupContact.Error, .notConnected)
    }
  }

  func testLookupWhenNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { .unimplemented }
    env.ud.get = { nil }
    let lookup: MessengerLookupContact = .live(env)

    XCTAssertThrowsError(try lookup(id: Data())) { error in
      XCTAssertEqual(error as? MessengerLookupContact.Error, .notLoggedIn)
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
    env.lookupUD.run = { _, _ in throw failure }
    let lookup: MessengerLookupContact = .live(env)

    XCTAssertThrowsError(try lookup(id: Data())) { error in
      XCTAssertEqual(error as? Failure, failure)
    }
  }

  func testLookupCallbackFailure() {
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
    env.lookupUD.run = { _, callback in
      callback.handle(.failure(failure as NSError))
      return SingleUseSendReport(rounds: [], roundURL: "", ephId: 0, receptionId: Data())
    }
    let lookup: MessengerLookupContact = .live(env)

    XCTAssertThrowsError(try lookup(id: Data())) { error in
      XCTAssertEqual(error as? Failure, failure)
    }
  }
}
