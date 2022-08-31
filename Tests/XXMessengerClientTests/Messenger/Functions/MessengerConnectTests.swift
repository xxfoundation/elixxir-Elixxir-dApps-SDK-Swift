import CustomDump
import XXClient
import XCTest
@testable import XXMessengerClient

final class MessengerConnectTests: XCTestCase {
  func testConnect() throws {
    struct DidLogIn: Equatable {
      var ephemeral: Bool
      var cMixId: Int
      var identity: ReceptionIdentity
      var e2eParamsJSON: Data
    }

    var didMakeReceptionIdentity: [Bool] = []
    var didLogIn: [DidLogIn] = []
    var didLogInWithAuthCallbacks: [AuthCallbacks?] = []
    var didSetE2E: [E2E?] = []
    var didHandleAuthCallbacks: [AuthCallbacks.Callback] = []

    let cMixId = 1234
    let receptionId = ReceptionIdentity.stub
    let e2eParams = "e2e-params".data(using: .utf8)!

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { cMixId }
      cMix.makeReceptionIdentity.run = { legacy in
        didMakeReceptionIdentity.append(legacy)
        return receptionId
      }
      return cMix
    }
    env.e2e.set = { didSetE2E.append($0) }
    env.getE2EParams.run = { e2eParams }
    env.authCallbacks.registered = {
      AuthCallbacks { callback in
        didHandleAuthCallbacks.append(callback)
      }
    }
    env.login.run = { ephemeral, cMixId, authCallbacks, identity, e2eParamsJSON in
      didLogIn.append(.init(
        ephemeral: ephemeral,
        cMixId: cMixId,
        identity: identity,
        e2eParamsJSON: e2eParamsJSON
      ))
      didLogInWithAuthCallbacks.append(authCallbacks)
      return .unimplemented
    }
    let connect: MessengerConnect = .live(env)

    try connect()

    XCTAssertNoDifference(didMakeReceptionIdentity, [true])
    XCTAssertNoDifference(didLogIn, [
      DidLogIn(
        ephemeral: false,
        cMixId: 1234,
        identity: receptionId,
        e2eParamsJSON: e2eParams
      )
    ])
    XCTAssertEqual(didLogInWithAuthCallbacks.compactMap { $0 }.count, 1)
    XCTAssertEqual(didSetE2E.compactMap { $0 }.count, 1)

    didLogInWithAuthCallbacks.forEach { authCallbacks in
      [AuthCallbacks.Callback].stubs.forEach { callback in
        authCallbacks?.handle(callback)
      }
    }
    XCTAssertNoDifference(didHandleAuthCallbacks, .stubs)
  }

  func testConnectWithoutCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let connect: MessengerConnect = .live(env)

    XCTAssertThrowsError(try connect()) { error in
      XCTAssertEqual(
        error as? MessengerConnect.Error,
        MessengerConnect.Error.notLoaded
      )
    }
  }

  func testMakeLegacyReceptionIdentityFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { 1234 }
      cMix.makeReceptionIdentity.run = { _ in throw error }
      return cMix
    }
    env.authCallbacks.registered = { .unimplemented }
    let connect: MessengerConnect = .live(env)

    XCTAssertThrowsError(try connect()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testLoginFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getId.run = { 1234 }
      cMix.makeReceptionIdentity.run = { _ in .stub }
      return cMix
    }
    env.authCallbacks.registered = { .unimplemented }
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.login.run = { _, _, _, _, _ in throw error }
    let connect: MessengerConnect = .live(env)

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
