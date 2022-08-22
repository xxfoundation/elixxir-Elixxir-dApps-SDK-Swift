import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerE2ETests: XCTestCase {
  func testE2E() throws {
    let e2e: MessengerE2E = .live()

    XCTAssertNil(e2e())

    e2e.set(.unimplemented)

    XCTAssertNotNil(e2e())

    e2e.set(nil)

    XCTAssertNil(e2e())
  }
}
