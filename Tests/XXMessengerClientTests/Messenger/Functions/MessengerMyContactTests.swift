import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerMyContactTests: XCTestCase {
  func testMyContactWithAllFacts() throws {
    let e2eContactData = "e2e-contact-data".data(using: .utf8)!
    var e2eContactSetFacts: [[Fact]] = []
    let e2eContactWithFactsData = "e2e-contact-with-facts-data".data(using: .utf8)!
    let udFacts = [
      Fact(type: .username, value: "ud-fact-username"),
      Fact(type: .email, value: "ud-fact-email"),
      Fact(type: .phone, value: "ud-fact-phone"),
    ]
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: Contact = .unimplemented(e2eContactData)
        contact.setFactsOnContact.run = { _, facts in
          e2eContactSetFacts.append(facts)
          return e2eContactWithFactsData
        }
        return contact
      }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getFacts.run = { udFacts }
      return ud
    }
    let myContact: MessengerMyContact = .live(env)

    let contact = try myContact()

    XCTAssertNoDifference(e2eContactSetFacts, [udFacts])
    XCTAssertNoDifference(contact, .unimplemented(e2eContactWithFactsData))
  }

  func testMyContactWithoutFacts() throws {
    let e2eContactData = "e2e-contact-data".data(using: .utf8)!
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = { .unimplemented(e2eContactData) }
      return e2e
    }
    let myContact: MessengerMyContact = .live(env)

    let contact = try myContact(includeFacts: .none)

    XCTAssertNoDifference(contact, .unimplemented(e2eContactData))
  }

  func testMyContactWithFactTypes() throws {
    let e2eContactData = "e2e-contact-data".data(using: .utf8)!
    var e2eContactSetFacts: [[Fact]] = []
    let e2eContactWithFactsData = "e2e-contact-with-facts-data".data(using: .utf8)!
    let udFactUsername = Fact(type: .username, value: "ud-fact-username")
    let udFactEmail = Fact(type: .email, value: "ud-fact-email")
    let udFactPhone = Fact(type: .phone, value: "ud-fact-phone")
    let udFacts = [udFactUsername, udFactEmail, udFactPhone]
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: Contact = .unimplemented(e2eContactData)
        contact.setFactsOnContact.run = { _, facts in
          e2eContactSetFacts.append(facts)
          return e2eContactWithFactsData
        }
        return contact
      }
      return e2e
    }
    env.ud.get = {
      var ud: UserDiscovery = .unimplemented
      ud.getFacts.run = { udFacts }
      return ud
    }
    let myContact: MessengerMyContact = .live(env)

    let contact = try myContact(includeFacts: .types([.username, .phone]))

    XCTAssertNoDifference(e2eContactSetFacts, [[udFactUsername, udFactPhone]])
    XCTAssertNoDifference(contact, .unimplemented(e2eContactWithFactsData))
  }

  func testMyContactWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let myContact: MessengerMyContact = .live(env)

    XCTAssertThrowsError(try myContact()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerMyContact.Error.notConnected as NSError
      )
    }
  }

  func testMyContactWithFactsWhenNotLoggedIn() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = { .unimplemented(Data()) }
      return e2e
    }
    env.ud.get = { nil }
    let myContact: MessengerMyContact = .live(env)

    XCTAssertThrowsError(try myContact()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerMyContact.Error.notLoggedIn as NSError
      )
    }
  }
}
