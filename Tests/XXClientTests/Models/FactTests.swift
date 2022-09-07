import CustomDump
import XCTest
@testable import XXClient

final class FactTests: XCTestCase {
  func testCoding() throws {
    let factValue = "Zezima"
    let factType: Int = 123
    let jsonString = """
    {
      "Fact": "\(factValue)",
      "T": \(factType)
    }
    """
    let jsonData = jsonString.data(using: .utf8)!
    let model = try Fact.decode(jsonData)

    XCTAssertNoDifference(model, Fact(
      type: .other(123),
      value: factValue
    ))

    let encodedModel = try model.encode()
    let decodedModel = try Fact.decode(encodedModel)

    XCTAssertNoDifference(decodedModel, model)
  }

  func testCodingArray() throws {
    let models = [
      Fact(type: .username, value: "abcd"),
      Fact(type: .email, value: "efgh"),
      Fact(type: .phone, value: "ijkl"),
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
      Fact(type: .username, value: "username"),
      Fact(type: .email, value: "email"),
      Fact(type: .phone, value: "phone"),
      Fact(type: .other(3), value: "other"),
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
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
        Fact(type: .other(3), value: "other"),
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
        Fact(type: .username, value: "username"),
        Fact(type: .email, value: "email"),
        Fact(type: .phone, value: "phone"),
        Fact(type: .other(3), value: "other"),
      ]
    )
  }
}
