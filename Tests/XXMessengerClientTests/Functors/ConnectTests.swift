import CustomDump
import XXClient
import XCTest
@testable import XXMessengerClient

final class ConnectTests: XCTestCase {
  func testConnect() throws {
    struct DidLogIn: Equatable {
      var ephemeral: Bool
      var cMixId: Int
      var authCallbacksProvided: Bool
      var identity: ReceptionIdentity
      var e2eParamsJSON: Data
    }

    var didLogIn: [DidLogIn] = []
    var didSetE2E: [E2E?] = []

    let cMixId = 1234
    let receptionId = ReceptionIdentity.stub
    let e2eParams = "e2e-params".data(using: .utf8)!

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { cMixId }
      cMix.makeLegacyReceptionIdentity.run = { receptionId }
      return cMix
    }
    env.e2e.set = { didSetE2E.append($0) }
    env.getE2EParams.run = { e2eParams }
    env.login.run = { ephemeral, cMixId, authCallbacks, identity, e2eParamsJSON in
      didLogIn.append(.init(
        ephemeral: ephemeral,
        cMixId: cMixId,
        authCallbacksProvided: authCallbacks != nil,
        identity: identity,
        e2eParamsJSON: e2eParamsJSON
      ))
      return .unimplemented
    }
    let connect: Connect = .live(env)

    try connect()

    XCTAssertNoDifference(didLogIn, [
      DidLogIn(
        ephemeral: false,
        cMixId: 1234,
        authCallbacksProvided: false,
        identity: .stub,
        e2eParamsJSON: e2eParams
      )
    ])
    XCTAssertEqual(didSetE2E.compactMap { $0 }.count, 1)
  }

  func testConnectWithoutCMix() {
    var env: Environment = .unimplemented
    env.cMix.get = { nil }
    let connect: Connect = .live(env)

    XCTAssertThrowsError(try connect()) { error in
      XCTAssertEqual(
        error as? Connect.Error,
        Connect.Error.notLoaded
      )
    }
  }

  func testMakeLegacyReceptionIdentityFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { 1234 }
      cMix.makeLegacyReceptionIdentity.run = { throw error }
      return cMix
    }
    let connect: Connect = .live(env)

    XCTAssertThrowsError(try connect()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testLoginFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { 1234 }
      cMix.makeLegacyReceptionIdentity.run = { .stub }
      return cMix
    }
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.login.run = { _, _, _, _, _ in throw error }
    let connect: Connect = .live(env)

    XCTAssertThrowsError(try connect()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}

private extension ReceptionIdentity {
  static let stub = ReceptionIdentity(
    id: "id".data(using: .utf8)!,
    rsaPrivatePem: "rsaPrivatePem".data(using: .utf8)!,
    salt: "salt".data(using: .utf8)!,
    dhKeyPrivate: "dhKeyPrivate".data(using: .utf8)!,
    e2eGrp: "e2eGrp".data(using: .utf8)!
  )
}
