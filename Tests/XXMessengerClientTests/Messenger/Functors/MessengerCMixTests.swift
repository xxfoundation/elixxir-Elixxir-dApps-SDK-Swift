import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerCMixTests: XCTestCase {
  func testCMix() throws {
    let cMix: MessengerCMix = .live()

    XCTAssertNil(cMix())

    cMix.set(.unimplemented)

    XCTAssertNotNil(cMix())

    cMix.set(nil)

    XCTAssertNil(cMix())
  }
}
