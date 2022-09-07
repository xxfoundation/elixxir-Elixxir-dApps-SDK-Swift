import CustomDump
import XCTest
@testable import XXClient

final class ContactTests: XCTestCase {
  func testGetFact() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
        Fact(type: .other(3), value: "other"),
      ]
    }

    XCTAssertNoDifference(
      [
        try contact.getFact(.username),
        try contact.getFact(.email),
        try contact.getFact(.phone),
        try contact.getFact(.other(3)),
        try contact.getFact(.other(4)),
      ],
      [
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
        Fact(type: .other(3), value: "other"),
        nil
      ]
    )
  }

  func testSetFact() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    var facts: [Fact] = [
      Fact(type: .username, value: "username"),
      Fact(type: .email, value: "email"),
      Fact(type: .phone, value: "phone"),
      Fact(type: .other(3), value: "other-3"),
    ]
    contact.getFactsFromContact.run = { _ in facts }
    contact.setFactsOnContact.run = { data, newFacts in
      facts = newFacts
      return data
    }

    try contact.setFact(.username, "new-username")
    try contact.setFact(.other(4), "new-other-4")
    try contact.setFact(.other(3), "new-other-3")
    try contact.setFact(.email, nil)

    XCTAssertNoDifference(facts, [
      Fact(type: .username, value: "new-username"),
      Fact(type: .phone, value: "phone"),
      Fact(type: .other(3), value: "new-other-3"),
      Fact(type: .other(4), value: "new-other-4"),
    ])
  }
}
