import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerLogInTests: XCTestCase {
  func testLogin() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didNewOrLoadUDWithFollower: [UdNetworkStatus] = []
    var didSetUD: [UserDiscovery?] = []

    let e2eId = 1234
    let networkFollowerStatus: NetworkFollowerStatus = .stopped
    let udCertFromNDF = "ndf-ud-cert".data(using: .utf8)!
    let udContactFromNDF = "ndf-ud-contact".data(using: .utf8)!
    let udAddressFromNDF = "ndf-ud-address"

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { networkFollowerStatus }
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
    let logIn: MessengerLogIn = .live(env)
    try logIn()

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
    XCTAssertEqual(didSetUD.compactMap { $0 }.count, 1)
  }

  func testLoginWithAlternativeUD() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didSetUD: [UserDiscovery?] = []

    let e2eId = 1234
    let altUdCert = "alt-ud-cert".data(using: .utf8)!
    let altUdContact = "alt-ud-contact".data(using: .utf8)!
    let altUdAddress = "alt-ud-address"

    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { .running }
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
    XCTAssertEqual(didSetUD.compactMap { $0 }.count, 1)
  }

  func testLoginWithoutCMix() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { error in
      XCTAssertEqual(
        error as? MessengerLogIn.Error,
        MessengerLogIn.Error.notLoaded
      )
    }
  }

  func testLoginWithoutE2E() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { .unimplemented }
    env.e2e.get = { nil }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { error in
      XCTAssertEqual(
        error as? MessengerLogIn.Error,
        MessengerLogIn.Error.notConnected
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
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
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
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
