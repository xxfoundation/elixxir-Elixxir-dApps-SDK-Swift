import XCTest
@testable import XXMessengerClient

final class MessengerIsLoadedTests: XCTestCase {
  func testWithCMix() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertTrue(isLoaded())
  }

  func testWithoutCMix() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = nil
    let isLoaded: MessengerIsLoaded = .live(env)

    XCTAssertFalse(isLoaded())
  }
}
