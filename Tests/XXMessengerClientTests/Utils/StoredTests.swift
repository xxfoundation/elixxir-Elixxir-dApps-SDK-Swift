import CustomDump
import XCTest
@testable import XXMessengerClient

final class StoredTests: XCTestCase {
  func testInMemory() {
    let stored: Stored<String?> = .inMemory()

    XCTAssertNil(stored())

    stored.set("test")

    XCTAssertEqual(stored(), "test")

    stored.set(nil)

    XCTAssertNil(stored())
  }

  func testUserDefaults() {
    struct Value: Equatable, Codable {
      var id = UUID()
    }

    let key = "key"
    let userDefaults = UserDefaults(suiteName: "XXMessengerClient_StoredTests")!
    userDefaults.removeObject(forKey: key)
    let stored: Stored<Value?> = .userDefaults(
      key: key,
      userDefaults: userDefaults
    )

    XCTAssertNoDifference(stored.get(), nil)

    let value = Value()
    stored.set(value)

    XCTAssertNoDifference(
      userDefaults.data(forKey: key).map { data in
        try? JSONDecoder().decode(Value.self, from: data)
      },
      value
    )
    XCTAssertNoDifference(stored.get(), value)

    userDefaults.set(nil, forKey: key)

    XCTAssertNoDifference(stored.get(), nil)
  }
}
