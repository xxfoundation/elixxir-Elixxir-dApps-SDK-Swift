import CustomDump
import XCTest
@testable import XXClient

final class ContactTests: XCTestCase {
  func testGetFact() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getFactsFromContact.run = { _ in
      [
        Fact(fact: "username", type: 0),
        Fact(fact: "email", type: 1),
        Fact(fact: "phone", type: 2),
        Fact(fact: "other", type: 3),
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
        Fact(fact: "username", type: 0),
        Fact(fact: "email", type: 1),
        Fact(fact: "phone", type: 2),
        Fact(fact: "other", type: 3),
        nil
      ]
    )
  }

  func testSetFact() throws {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    var facts: [Fact] = [
      Fact(fact: "username", type: 0),
      Fact(fact: "email", type: 1),
      Fact(fact: "phone", type: 2),
      Fact(fact: "other-3", type: 3),
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
      Fact(fact: "new-username", type: 0),
      Fact(fact: "phone", type: 2),
      Fact(fact: "new-other-3", type: 3),
      Fact(fact: "new-other-4", type: 4),
    ])
  }
}
