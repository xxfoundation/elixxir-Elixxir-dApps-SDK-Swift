import CustomDump
import XCTest
@testable import XXClient

final class FactTests: XCTestCase {
  func testCoding() throws {
    let factValue = "Zezima"
    let factType: Int = 0
    let jsonString = """
    {
      "Fact": "\(factValue)",
      "T": \(factType)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Fact.decode(jsonData)

    XCTAssertNoDifference(model, Fact(
      fact: factValue,
      type: factType
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Fact.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testCodingArray() throws {
    let models = [
      Fact(fact: "abcd", type: 0),
      Fact(fact: "efgh", type: 1),
      Fact(fact: "ijkl", type: 2),
    ]

    let encodedModels = try models.encode()
    let decodedModels = try [Fact].decode(encodedModels)

    XCTAssertNoDifference(models, decodedModels)
  }

  func testCodingEmptyArray() throws {
    let jsonString = "null"
    let jsonData = jsonString.data(using: .utf8)!

    let decodedModels = try [Fact].decode(jsonData)

    XCTAssertNoDifference(decodedModels, [])

    let encodedModels = try decodedModels.encode()

    XCTAssertNoDifference(encodedModels, jsonData)
  }

  func testArrayGetter() {
    let facts = [
      Fact(fact: "username", type: 0),
      Fact(fact: "email", type: 1),
      Fact(fact: "phone", type: 2),
      Fact(fact: "other", type: 3),
    ]

    XCTAssertNoDifference(
      [
        facts.get(.username),
        facts.get(.email),
        facts.get(.phone),
        facts.get(.other(3)),
        facts.get(.other(4)),
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

  func testArraySetter() {
    var facts: [Fact] = []

    facts.set(.email, "email")
    facts.set(.phone, "phone")
    facts.set(.other(3), "other")
    facts.set(.username, "username")

    XCTAssertNoDifference(
      facts,
      [
        Fact(fact: "username", type: 0),
        Fact(fact: "email", type: 1),
        Fact(fact: "phone", type: 2),
        Fact(fact: "other", type: 3),
      ]
    )
  }
}
