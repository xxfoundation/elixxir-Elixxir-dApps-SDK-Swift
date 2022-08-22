import XCTest
@testable import XXMessengerClient

final class IsLoadedTests: XCTestCase {
  func testWithCMix() {
    var env: Environment = .unimplemented
    env.cMix.get = { .unimplemented }
    let isLoaded: IsLoaded = .live(env)

    XCTAssertTrue(isLoaded())
  }

  func testWithoutCMix() {
    var env: Environment = .unimplemented
    env.cMix.get = { nil }
    let isLoaded: IsLoaded = .live(env)

    XCTAssertFalse(isLoaded())
  }
}
