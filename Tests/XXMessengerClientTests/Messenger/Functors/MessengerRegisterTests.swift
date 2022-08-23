import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRegisterTests: XCTestCase {
  func testRegister() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didNewOrLoadUDWithFollower: [UdNetworkStatus] = []
    var didSetUD: [UserDiscovery?] = []

    let e2eId = 1234
    let networkFollowerStatus: NetworkFollowerStatus = .stopped
    let registrationSignature = "registration-signature".data(using: .utf8)!
    let udCertFromNDF = "ndf-ud-cert".data(using: .utf8)!
    let udContactFromNDF = "ndf-ud-contact".data(using: .utf8)!
    let udAddressFromNDF = "ndf-ud-address"
    let username = "new-user-name"

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { networkFollowerStatus }
      cMix.getReceptionRegistrationValidationSignature.run = {
        registrationSignature
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      e2e.getUdCertFromNdf.run = { udCertFromNDF }
      e2e.getUdContactFromNdf.run = { udContactFromNDF }
      e2e.getUdAddressFromNdf.run = { udAddressFromNDF }
      return e2e
    }
    env.ud.set = { didSetUD.append($0) }
    env.udCert = nil
    env.udContact = nil
    env.udAddress = nil
    env.newOrLoadUd.run = { params, follower in
      didNewOrLoadUDWithParams.append(params)
      didNewOrLoadUDWithFollower.append(follower)
      return .unimplemented
    }
    let register: MessengerRegister = .live(env)
    try register(username: username)

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
      networkFollowerStatus
    )
    XCTAssertEqual(didSetUD.compactMap { $0 }.count, 1)
  }

  func testRegisterWithAlternativeUD() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didSetUD: [UserDiscovery?] = []

    let e2eId = 1234
    let registrationSignature = "registration-signature".data(using: .utf8)!
    let altUdCert = "alt-ud-cert".data(using: .utf8)!
    let altUdContact = "alt-ud-contact".data(using: .utf8)!
    let altUdAddress = "alt-ud-address"
    let username = "new-user-name"

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.getReceptionRegistrationValidationSignature.run = {
        registrationSignature
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.ud.set = { didSetUD.append($0) }
    env.udCert = altUdCert
    env.udContact = altUdContact
    env.udAddress = altUdAddress
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
    XCTAssertEqual(didSetUD.compactMap { $0 }.count, 1)
  }

  func testRegisterWithoutCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { error in
      XCTAssertEqual(
        error as? MessengerRegister.Error,
        MessengerRegister.Error.notLoaded
      )
    }
  }

  func testRegisterWithoutE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { .unimplemented }
    env.e2e.get = { nil }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { error in
      XCTAssertEqual(
        error as? MessengerRegister.Error,
        MessengerRegister.Error.notConnected
      )
    }
  }

  func testGetUdContactFromNdfFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.getReceptionRegistrationValidationSignature.run = {
        "registration-signature".data(using: .utf8)!
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      e2e.getUdCertFromNdf.run = { "ndf-ud-cert".data(using: .utf8)! }
      e2e.getUdContactFromNdf.run = { throw error }
      return e2e
    }
    env.udCert = nil
    env.udContact = nil
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testNewOrLoadUdFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
      cMix.getReceptionRegistrationValidationSignature.run = {
        "registration-signature".data(using: .utf8)!
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 1234 }
      return e2e
    }
    env.udCert = "ud-cert".data(using: .utf8)!
    env.udContact = "ud-contact".data(using: .utf8)!
    env.udAddress = "ud-address"
    env.newOrLoadUd.run = { _, _ in throw error }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
