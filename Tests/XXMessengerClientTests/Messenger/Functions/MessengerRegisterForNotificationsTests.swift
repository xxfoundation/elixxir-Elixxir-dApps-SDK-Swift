import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterForNotificationsTest: XCTestCase {
  func testRegister() throws {
    struct DidRegister: Equatable {
      var e2eId: Int
      var token: String
    }
    var didRegister: [DidRegister] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.registerForNotifications.run = { e2eId, token in
      didRegister.append(.init(e2eId: e2eId, token: token))
    }

    let register: MessengerRegisterForNotifications = .live(env)
    let token = "test-token".data(using: .utf8)!

    try register(token: token)

    XCTAssertNoDifference(didRegister, [.init(e2eId: 1234, token: "746573742d746f6b656e")])
  }

  func testRegisterWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let register: MessengerRegisterForNotifications = .live(env)
    let token = "test-token".data(using: .utf8)!

    XCTAssertThrowsError(try register(token: token)) { error in
      XCTAssertEqual(error as? MessengerRegisterForNotifications.Error, .notConnected)
    }
  }

  func testRegisterFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.registerForNotifications.run = { _, _ in throw failure }
    let register: MessengerRegisterForNotifications = .live(env)
    let token = "test-token".data(using: .utf8)!

    XCTAssertThrowsError(try register(token: token)) { error in
      XCTAssertEqual(error as? Failure, failure)
    }
  }
}
