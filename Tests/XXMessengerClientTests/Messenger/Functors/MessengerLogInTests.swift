import XCTest
import XXClient
@testable import XXMessengerClient
import CustomDump

final class MessengerLogInTests: XCTestCase {
  func testLogin() throws {
    var didStartNetworkFollower: [Int] = []
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didNewOrLoadUDWithFollower: [UdNetworkStatus] = []

    let e2eId = 1234
    let networkFollowerStatus: NetworkFollowerStatus = .stopped
    let udCertFromNDF = "ndf-ud-cert".data(using: .utf8)!
    let udContactFromNDF = "ndf-ud-contact".data(using: .utf8)!
    let udAddressFromNDF = "ndf-ud-address"

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { networkFollowerStatus }
    env.ctx.cMix!.startNetworkFollower.run = { timeout in
      didStartNetworkFollower.append(timeout)
    }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { e2eId }
    env.udCert = nil
    env.udContact = nil
    env.udAddress = nil
    env.ctx.e2e!.getUdCertFromNdf.run = { udCertFromNDF }
    env.ctx.e2e!.getUdContactFromNdf.run = { udContactFromNDF }
    env.ctx.e2e!.getUdAddressFromNdf.run = { udAddressFromNDF }
    env.newOrLoadUd.run = { params, follower in
      didNewOrLoadUDWithParams.append(params)
      didNewOrLoadUDWithFollower.append(follower)
      return .unimplemented
    }
    let logIn: MessengerLogIn = .live(env)
    try logIn()

    XCTAssertEqual(didStartNetworkFollower, [30_000])
    XCTAssertNoDifference(didNewOrLoadUDWithParams, [.init(
      e2eId: e2eId,
      username: nil,
      registrationValidationSignature: nil,
      cert: udCertFromNDF,
      contactFile: udContactFromNDF,
      address: udAddressFromNDF
    )])
    XCTAssertEqual(didNewOrLoadUDWithFollower.count, 1)
    XCTAssertEqual(
      didNewOrLoadUDWithFollower.first?.handle(),
      networkFollowerStatus.rawValue
    )
    XCTAssertNotNil(env.ctx.ud)
  }

  func testLoginWithAlternativeUD() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    let e2eId = 1234
    let altUdCert = "alt-ud-cert".data(using: .utf8)!
    let altUdContact = "alt-ud-contact".data(using: .utf8)!
    let altUdAddress = "alt-ud-address"

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { e2eId }
    env.udCert = altUdCert
    env.udContact = altUdContact
    env.udAddress = altUdAddress
    env.newOrLoadUd.run = { params, _ in
      didNewOrLoadUDWithParams.append(params)
      return .unimplemented
    }
    let logIn: MessengerLogIn = .live(env)
    try logIn()

    XCTAssertNoDifference(didNewOrLoadUDWithParams, [.init(
      e2eId: e2eId,
      username: nil,
      registrationValidationSignature: nil,
      cert: altUdCert,
      contactFile: altUdContact,
      address: altUdAddress
    )])
    XCTAssertNotNil(env.ctx.ud)
  }

  func testLoginWithoutCMix() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = nil
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { error in
      XCTAssertEqual(
        error as? MessengerLogIn.Error,
        MessengerLogIn.Error.notLoaded
      )
    }
  }

  func testLoginWithoutE2E() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.e2e = nil
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { error in
      XCTAssertEqual(
        error as? MessengerLogIn.Error,
        MessengerLogIn.Error.notConnected
      )
    }
  }

  func testStartNetworkFollowerFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .stopped }
    env.ctx.cMix!.startNetworkFollower.run = { _ in throw error }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testGetUdContactFromNdfFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { 1234 }
    env.udCert = nil
    env.udContact = nil
    env.ctx.e2e!.getUdCertFromNdf.run = { "ndf-ud-cert".data(using: .utf8)! }
    env.ctx.e2e!.getUdContactFromNdf.run = { throw error }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testNewOrLoadUdFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { 1234 }
    env.udCert = "ud-cert".data(using: .utf8)!
    env.udContact = "ud-contact".data(using: .utf8)!
    env.udAddress = "ud-address"
    env.newOrLoadUd.run = { _, _ in throw error }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
