import XCTest
@testable import XXMessengerClient

final class MessengerIsLoadedTests: XCTestCase {
  func testWithCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { .unimplemented }
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertTrue(isLoaded())
  }

  func testWithoutCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertFalse(isLoaded())
  }
}
