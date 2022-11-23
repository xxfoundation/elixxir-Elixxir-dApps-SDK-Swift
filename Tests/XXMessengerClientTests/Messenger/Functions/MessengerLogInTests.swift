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
    let udEnvironmentFromNDF = UDEnvironment(
      address: "ndf-ud-address",
      cert: "ndf-ud-cert".data(using: .utf8)!,
      contact: "ndf-ud-contact".data(using: .utf8)!
    )
    
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.networkFollowerStatus.run = { networkFollowerStatus }
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
    let logIn: MessengerLogIn = .live(env)
    try logIn()

    XCTAssertNoDifference(didNewOrLoadUDWithParams, [.init(
      e2eId: e2eId,
      username: nil,
      registrationValidationSignature: nil,
      environment: udEnvironmentFromNDF
    )])
    XCTAssertEqual(didNewOrLoadUDWithFollower.count, 1)
    XCTAssertEqual(
      didNewOrLoadUDWithFollower.first?.handle(),
      networkFollowerStatus
    )
    XCTAssertEqual(didSetUD.compactMap { $0 }.count, 1)
  }

  func testLoginWithAlternativeUD() throws {
    var didNewOrLoadUDWithParams: [NewOrLoadUd.Params] = []
    var didSetUD: [UserDiscovery?] = []

    let e2eId = 1234
    let udEnvironment = UDEnvironment(
      address: "alt-ud-address",
      cert: "alt-ud-cert".data(using: .utf8)!,
      contact: "alt-ud-contact".data(using: .utf8)!
    )

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
    env.udEnvironment = udEnvironment
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
      environment: udEnvironment
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
      e2e.getUdEnvironmentFromNdf.run = { throw error }
      return e2e
    }
    env.udEnvironment = nil
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
    env.udEnvironment = UDEnvironment(
      address: "ud-address",
      cert: "ud-cert".data(using: .utf8)!,
      contact: "ud-contact".data(using: .utf8)!
    )
    env.newOrLoadUd.run = { _, _ in throw error }
    let logIn: MessengerLogIn = .live(env)

    XCTAssertThrowsError(try logIn()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
