import XCTest
@testable import XXMessengerClient

final class MessengerIsLoadedTests: XCTestCase {
  func testWithCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = { .unimplemented }
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertTrue(isLoaded())
  }

  func testWithoutCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.ctx.getCMix = { nil }
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertFalse(isLoaded())
  }
}
