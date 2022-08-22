import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterTests: XCTestCase {
  func testRegister() throws {
    var didStartNetworkFollower: [Int] = []
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didNewOrLoadUDWithFollower: [UdNetworkStatus] = []

    let e2eId = 1234
    let networkFollowerStatus: NetworkFollowerStatus = .stopped
    let registrationSignature = "registration-signature".data(using: .utf8)!
    let udCertFromNDF = "ndf-ud-cert".data(using: .utf8)!
    let udContactFromNDF = "ndf-ud-contact".data(using: .utf8)!
    let udAddressFromNDF = "ndf-ud-address"
    let username = "new-user-name"

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { networkFollowerStatus }
    env.ctx.cMix!.startNetworkFollower.run = { timeout in
      didStartNetworkFollower.append(timeout)
    }
    env.ctx.cMix!.getReceptionRegistrationValidationSignature.run = {
      registrationSignature
    }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { e2eId }
    env.udCert = { nil }
    env.udContact = { nil }
    env.udAddress = { nil }
    env.ctx.e2e!.getUdCertFromNdf.run = { udCertFromNDF }
    env.ctx.e2e!.getUdContactFromNdf.run = { udContactFromNDF }
    env.ctx.e2e!.getUdAddressFromNdf.run = { udAddressFromNDF }
    env.newOrLoadUd.run = { params, follower in
      didNewOrLoadUDWithParams.append(params)
      didNewOrLoadUDWithFollower.append(follower)
      return .unimplemented
    }
    let register: MessengerRegister = .live(env)
    try register(username: username)

    XCTAssertEqual(didStartNetworkFollower, [30_000])
    XCTAssertNoDifference(didNewOrLoadUDWithParams, [.init(
      e2eId: e2eId,
      username: username,
      registrationValidationSignature: registrationSignature,
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

  func testRegisterWithAlternativeUD() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    let e2eId = 1234
    let registrationSignature = "registration-signature".data(using: .utf8)!
    let altUdCert = "alt-ud-cert".data(using: .utf8)!
    let altUdContact = "alt-ud-contact".data(using: .utf8)!
    let altUdAddress = "alt-ud-address"
    let username = "new-user-name"

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.cMix!.getReceptionRegistrationValidationSignature.run = {
      registrationSignature
    }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { e2eId }
    env.udCert = { altUdCert }
    env.udContact = { altUdContact }
    env.udAddress = { altUdAddress }
    env.newOrLoadUd.run = { params, _ in
      didNewOrLoadUDWithParams.append(params)
      return .unimplemented
    }
    let register: MessengerRegister = .live(env)
    try register(username: username)

    XCTAssertNoDifference(didNewOrLoadUDWithParams, [.init(
      e2eId: e2eId,
      username: username,
      registrationValidationSignature: registrationSignature,
      cert: altUdCert,
      contactFile: altUdContact,
      address: altUdAddress
    )])
    XCTAssertNotNil(env.ctx.ud)
  }

  func testRegisterWithoutCMix() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = nil
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { error in
      XCTAssertEqual(
        error as? MessengerRegister.Error,
        MessengerRegister.Error.notLoaded
      )
    }
  }

  func testRegisterWithoutE2E() {
    let env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.e2e = nil
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { error in
      XCTAssertEqual(
        error as? MessengerRegister.Error,
        MessengerRegister.Error.notConnected
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
    env.ctx.e2e = .unimplemented
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testGetUdContactFromNdfFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.cMix!.getReceptionRegistrationValidationSignature.run = {
      "registration-signature".data(using: .utf8)!
    }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { 1234 }
    env.udCert = { nil }
    env.udContact = { nil }
    env.ctx.e2e!.getUdCertFromNdf.run = { "ndf-ud-cert".data(using: .utf8)! }
    env.ctx.e2e!.getUdContactFromNdf.run = { throw error }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testNewOrLoadUdFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.ctx.cMix = .unimplemented
    env.ctx.cMix!.networkFollowerStatus.run = { .running }
    env.ctx.cMix!.getReceptionRegistrationValidationSignature.run = {
      "registration-signature".data(using: .utf8)!
    }
    env.ctx.e2e = .unimplemented
    env.ctx.e2e!.getId.run = { 1234 }
    env.udCert = { "ud-cert".data(using: .utf8)! }
    env.udContact = { "ud-contact".data(using: .utf8)! }
    env.udAddress = { "ud-address" }
    env.newOrLoadUd.run = { _, _ in throw error }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
