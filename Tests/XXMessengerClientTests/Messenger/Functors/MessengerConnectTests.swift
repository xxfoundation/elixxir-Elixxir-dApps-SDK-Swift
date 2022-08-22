import CustomDump
import XXClient
import XCTest
@testable import XXMessengerClient

final class MessengerConnectTests: XCTestCase {
  func testConnect() throws {
    struct DidLogIn: Equatable {
      var ephemeral: Bool
      var cMixId: Int
      var authCallbacksProvided: Bool
      var identity: ReceptionIdentity
      var e2eParamsJSON: Data
    }
    var didLogIn: [DidLogIn] = []

    let cMixId = 1234
    let receptionId = ReceptionIdentity.stub
    let e2eParams = "e2e-params".data(using: .utf8)!

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.getId.run = { cMixId }
    env.ctx.cMix!.makeLegacyReceptionIdentity.run = { receptionId }
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
    let connect: MessengerConnect = .live(env)

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

    XCTAssertNotNil(env.ctx.e2e)
  }

  func testConnectWithoutCMix() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = nil
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

    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.getId.run = { 1234 }
    env.ctx.cMix!.makeLegacyReceptionIdentity.run = { throw error }
    let connect: MessengerConnect = .live(env)

    XCTAssertThrowsError(try connect()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testLoginFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.getId.run = { 1234 }
    env.ctx.cMix!.makeLegacyReceptionIdentity.run = { .stub }
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
