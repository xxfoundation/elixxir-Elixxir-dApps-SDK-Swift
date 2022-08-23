import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerLoadTests: XCTestCase {
  func testLoad() throws {
    struct DidLoadCMix: Equatable {
      var storageDir: String
      var password: Data
      var cMixParamsJSON: Data
    }
    var didLoadCMix: [DidLoadCMix] = []
    var didSetCMix: [CMix?] = []

    let storageDir = "test-storage-dir"
    let password = "password".data(using: .utf8)!
    let cMixParams = "cmix-params".data(using: .utf8)!

    var env: MessengerEnvironment = .unimplemented
    env.cMix.set = { didSetCMix.append($0) }
    env.storageDir = storageDir
    env.passwordStorage.load = { password }
    env.getCMixParams.run = { cMixParams }
    env.loadCMix.run = { storageDir, password, cMixParamsJSON in
      didLoadCMix.append(.init(
        storageDir: storageDir,
        password: password,
        cMixParamsJSON: cMixParamsJSON
      ))
      return .unimplemented
    }
    let load: MessengerLoad = .live(env)

    try load()

    XCTAssertNoDifference(didLoadCMix, [
      DidLoadCMix(
        storageDir: storageDir,
        password: password,
        cMixParamsJSON: cMixParams
      )
    ])
    XCTAssertEqual(didSetCMix.compactMap{ $0 }.count, 1)
  }

  func testMissingPassword() {
    var env: MessengerEnvironment = .unimplemented
    env.storageDir = "storage-dir"
    env.passwordStorage.load = { throw PasswordStorage.MissingPasswordError() }
    let load: MessengerLoad = .live(env)

    XCTAssertThrowsError(try load()) { err in
      XCTAssertEqual(
        err as? PasswordStorage.MissingPasswordError,
        PasswordStorage.MissingPasswordError()
      )
    }
  }

  func testLoadCMixFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: MessengerEnvironment = .unimplemented
    env.storageDir = "storage-dir"
    env.passwordStorage.load = { "password".data(using: .utf8)! }
    env.getCMixParams.run = { "cmix-params".data(using: .utf8)! }
    env.loadCMix.run = { _, _, _ in throw error }
    let load: MessengerLoad = .live(env)

    XCTAssertThrowsError(try load()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
