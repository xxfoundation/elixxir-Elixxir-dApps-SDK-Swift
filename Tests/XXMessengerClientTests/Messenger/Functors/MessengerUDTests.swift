import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerUDTests: XCTestCase {
  func testUD() throws {
    let ud: MessengerUD = .live()

    XCTAssertNil(ud())

    ud.set(.unimplemented)

    XCTAssertNotNil(ud())

    ud.set(nil)

    XCTAssertNil(ud())
  }
}
