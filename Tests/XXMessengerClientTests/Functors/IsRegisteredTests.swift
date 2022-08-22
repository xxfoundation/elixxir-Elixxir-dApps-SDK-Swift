import XCTest
import XXClient
@testable import XXMessengerClient

final class IsRegisteredTests: XCTestCase {
  func testRegistered() throws {
    var didIsRegisteredWithUD: [Int] = []

    var env: Environment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.isRegisteredWithUD.run = { e2eId in
      didIsRegisteredWithUD.append(e2eId)
      return true
    }
    let isRegistered: IsRegistered = .live(env)

    XCTAssertTrue(try isRegistered())
    XCTAssertEqual(didIsRegisteredWithUD, [1234])
  }

  func testNotRegistered() throws {
    var env: Environment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.isRegisteredWithUD.run = { _ in false }
    let isRegistered: IsRegistered = .live(env)

    XCTAssertFalse(try isRegistered())
  }

  func testWithoutE2E() {
    var env: Environment = .unimplemented
    env.e2e.get = { nil }
    let isRegistered: IsRegistered = .live(env)

    XCTAssertThrowsError(try isRegistered()) { err in
      XCTAssertEqual(
        err as? IsRegistered.Error,
        IsRegistered.Error.notConnected
      )
    }
  }

  func testIsRegisteredWithUDFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.isRegisteredWithUD.run = { _ in throw error }
    let isRegistered: IsRegistered = .live(env)

    XCTAssertThrowsError(try isRegistered()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
