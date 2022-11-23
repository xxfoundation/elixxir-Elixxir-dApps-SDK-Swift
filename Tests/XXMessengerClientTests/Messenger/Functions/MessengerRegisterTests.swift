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
    let udEnvironmentFromNDF = UDEnvironment(
      address: "ndf-ud-address",
      cert: "ndf-ud-cert".data(using: .utf8)!,
      contact: "ndf-ud-contact".data(using: .utf8)!
    )
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
      e2e.getUdEnvironmentFromNdf.run = { udEnvironmentFromNDF }
      return e2e
    }
    env.ud.set = { didSetUD.append($0) }
    env.udEnvironment = nil
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
      environment: udEnvironmentFromNDF
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
    let udEnvironment = UDEnvironment(
      address: "alt-ud-address",
      cert: "alt-ud-cert".data(using: .utf8)!,
      contact: "alt-ud-contact".data(using: .utf8)!
    )
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
    env.udEnvironment = udEnvironment
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
      environment: udEnvironment
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
      e2e.getUdEnvironmentFromNdf.run = { throw error }
      return e2e
    }
    env.udEnvironment = nil
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
    env.udEnvironment = UDEnvironment(
      address: "ud-address",
      cert: "ud-cert".data(using: .utf8)!,
      contact: "ud-contact".data(using: .utf8)!
    )
    env.newOrLoadUd.run = { _, _ in throw error }
    let register: MessengerRegister = .live(env)

    XCTAssertThrowsError(try register(username: "new-user-name")) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
