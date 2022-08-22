import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class CreateTests: XCTestCase {
  func testCreate() throws {
    struct DidNewCMix: Equatable {
      var ndfJSON: String
      var storageDir: String
      var password: Data
      var registrationCode: String?
    }

    var didDownloadNDF: [NDFEnvironment] = []
    var didGenerateSecret: [Int] = []
    var didSavePassword: [Data] = []
    var didRemoveDirectory: [String] = []
    var didCreateDirectory: [String] = []
    var didNewCMix: [DidNewCMix] = []

    let ndf = "ndf".data(using: .utf8)!
    let password = "password".data(using: .utf8)!
    let storageDir = "storage-dir"

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { ndfEnvironment in
      didDownloadNDF.append(ndfEnvironment)
      return ndf
    }
    env.generateSecret.run = { numBytes in
      didGenerateSecret.append(numBytes)
      return password
    }
    env.passwordStorage.save = { password in
      didSavePassword.append(password)
    }
    env.storageDir = storageDir
    env.directoryManager.remove = { path in
      didRemoveDirectory.append(path)
    }
    env.directoryManager.create = { path in
      didCreateDirectory.append(path)
    }
    env.newCMix.run = { ndfJSON, storageDir, password, registrationCode in
      didNewCMix.append(.init(
        ndfJSON: ndfJSON,
        storageDir: storageDir,
        password: password,
        registrationCode: registrationCode
      ))
    }
    let create: Create = .live(env)

    try create()

    XCTAssertNoDifference(didDownloadNDF, [.unimplemented])
    XCTAssertNoDifference(didGenerateSecret, [32])
    XCTAssertNoDifference(didSavePassword, [password])
    XCTAssertNoDifference(didRemoveDirectory, [storageDir])
    XCTAssertNoDifference(didCreateDirectory, [storageDir])
    XCTAssertNoDifference(didNewCMix, [.init(
      ndfJSON: String(data: ndf, encoding: .utf8)!,
      storageDir: storageDir,
      password: password,
      registrationCode: nil
    )])
  }

  func testDownloadNDFFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { _ in throw error }
    let create: Create = .live(env)

    XCTAssertThrowsError(try create()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testSavePasswordFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { _ in "ndf".data(using: .utf8)! }
    env.generateSecret.run = { _ in "password".data(using: .utf8)! }
    env.passwordStorage.save = { _ in throw error }
    let create: Create = .live(env)

    XCTAssertThrowsError(try create()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testRemoveDirectoryFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { _ in "ndf".data(using: .utf8)! }
    env.generateSecret.run = { _ in "password".data(using: .utf8)! }
    env.passwordStorage.save = { _ in }
    env.storageDir = "storage-dir"
    env.directoryManager.remove = { _ in throw error }
    let create: Create = .live(env)

    XCTAssertThrowsError(try create()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testCreateDirectoryFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { _ in "ndf".data(using: .utf8)! }
    env.generateSecret.run = { _ in "password".data(using: .utf8)! }
    env.passwordStorage.save = { _ in }
    env.storageDir = "storage-dir"
    env.directoryManager.remove = { _ in }
    env.directoryManager.create = { _ in throw error }
    let create: Create = .live(env)

    XCTAssertThrowsError(try create()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }

  func testNewCMixFailure() {
    struct Error: Swift.Error, Equatable {}
    let error = Error()

    var env: Environment = .unimplemented
    env.ndfEnvironment = .unimplemented
    env.downloadNDF.run = { _ in "ndf".data(using: .utf8)! }
    env.generateSecret.run = { _ in "password".data(using: .utf8)! }
    env.passwordStorage.save = { _ in }
    env.storageDir = "storage-dir"
    env.directoryManager.remove = { _ in }
    env.directoryManager.create = { _ in }
    env.newCMix.run = { _, _, _, _ in throw error }
    let create: Create = .live(env)

    XCTAssertThrowsError(try create()) { err in
      XCTAssertEqual(err as? Error, error)
    }
  }
}
