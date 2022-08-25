import XCTest
@testable import XXMessengerClient

final class StoredTests: XCTestCase {
  func testInMemory() throws {
    let stored: Stored<String?> = .inMemory()

    XCTAssertNil(stored())

    stored.set("test")

    XCTAssertEqual(stored(), "test")

    stored.set(nil)

    XCTAssertNil(stored())
  }
}
