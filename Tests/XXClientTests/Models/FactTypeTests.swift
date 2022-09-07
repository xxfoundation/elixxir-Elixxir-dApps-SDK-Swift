import CustomDump
import Foundation
import XCTest
@testable import XXClient

final class FactTypeTests: XCTestCase {
  func testDecoding() throws {
    let decoder = Foundation.JSONDecoder()

    XCTAssertNoDifference(
      [
        try decoder.decode(FactType.self, from: "0".data(using: .utf8)!),
        try decoder.decode(FactType.self, from: "1".data(using: .utf8)!),
        try decoder.decode(FactType.self, from: "2".data(using: .utf8)!),
        try decoder.decode(FactType.self, from: "3".data(using: .utf8)!),
      ],
      [
        FactType.username,
        FactType.email,
        FactType.phone,
        FactType.other(3),
      ]
    )
  }

  func testEncoding() throws {
    let encoder = Foundation.JSONEncoder()

    XCTAssertNoDifference(
      [
        try encoder.encode(FactType.username),
        try encoder.encode(FactType.email),
        try encoder.encode(FactType.phone),
        try encoder.encode(FactType.other(3)),
      ],
      [
        "0".data(using: .utf8)!,
        "1".data(using: .utf8)!,
        "2".data(using: .utf8)!,
        "3".data(using: .utf8)!,
      ]
    )
  }
}
