import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerRestoreBackupTests: XCTestCase {
  func testRestore() throws {
    let backupData = "backup-data".data(using: .utf8)!
    let backupPassphrase = "backup-passphrase"
    let ndfData = "ndf-data".data(using: .utf8)!
    let password = "password".data(using: .utf8)!
    let backupParams = BackupParams(
      username: "backup-username",
      email: "backup-email",
      phone: "backup-phone"
    )
    let backupReport = BackupReport(
      restoredContacts: [],
      params: String(data: try! JSONEncoder().encode(backupParams), encoding: .utf8)!
    )
    let cMixParams = "cmix-params".data(using: .utf8)!
    let e2eParams = "e2e-params".data(using: .utf8)!
    let cMixId = 123
    let e2eId = 456
    let receptionIdentity = ReceptionIdentity(
      id: "reception-id".data(using: .utf8)!,
      rsaPrivatePem: "reception-rsaPrivatePem".data(using: .utf8)!,
      salt: "reception-salt".data(using: .utf8)!,
      dhKeyPrivate: "reception-dhKeyPrivate".data(using: .utf8)!,
      e2eGrp: "reception-e2eGrp".data(using: .utf8)!
    )
    let udContactFromNdf = "ud-contact".data(using: .utf8)!
    let udCertFromNdf = "ud-cert".data(using: .utf8)!
    let udAddressFromNdf = "ud-address"

    var caughtActions: [CaughtAction] = []

    var env: MessengerEnvironment = .unimplemented
    env.downloadNDF.run = { ndfEnvironment in
      caughtActions.append(.didDownloadNDF(environment: ndfEnvironment))
      return ndfData
    }
    env.generateSecret.run = { _ in password }
    env.passwordStorage.save = { caughtActions.append(.didSavePassword(password: $0)) }
    env.passwordStorage.load = { password }
    env.fileManager.removeDirectory = { caughtActions.append(.didRemoveDirectory(path: $0)) }
    env.fileManager.createDirectory = { caughtActions.append(.didCreateDirectory(path: $0)) }
    env.newCMixFromBackup.run = {
      ndfJSON, storageDir, backupPassphrase, sessionPassword, backupFileContents in
      caughtActions.append(.didNewCMixFromBackup(
        ndfJSON: ndfJSON,
        storageDir: storageDir,
        backupPassphrase: backupPassphrase,
        sessionPassword: sessionPassword,
        backupFileContents: backupFileContents
      ))
      return backupReport
    }
    env.getCMixParams.run = { cMixParams }
    env.getE2EParams.run = { e2eParams }
    env.loadCMix.run = { storageDir, password, cMixParams in
      caughtActions.append(.didLoadCMix(
        storageDir: storageDir,
        password: password,
        cMixParams: cMixParams
      ))
      var cMix: CMix = .unimplemented
      cMix.getId.run = { cMixId }
      cMix.makeReceptionIdentity.run = { legacy in
        caughtActions.append(.cMixDidMakeReceptionIdentity(legacy: legacy))
        return receptionIdentity
      }
      return cMix
    }
    env.login.run = { ephemeral, cMixId, _, identity, e2eParams in
      caughtActions.append(.didLogin(
        ephemeral: ephemeral,
        cMixId: cMixId,
        identity: identity,
        e2eParamsJSON: e2eParams
      ))
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      e2e.getUdCertFromNdf.run = { udCertFromNdf }
      e2e.getUdContactFromNdf.run = { udContactFromNdf }
      e2e.getUdAddressFromNdf.run = { udAddressFromNdf }
      return e2e
    }
    env.newUdManagerFromBackup.run = { params, _ in
      caughtActions.append(.didNewUdManagerFromBackup(params: params))
      return .unimplemented
    }
    env.authCallbacks.registered = {
      AuthCallbacks { _ in }
    }
    env.cMix.set = { _ in caughtActions.append(.didSetCMix) }
    env.e2e.set = { _ in caughtActions.append(.didSetE2E) }
    env.ud.set = { _ in caughtActions.append(.didSetUD) }

    let restore: MessengerRestoreBackup = .live(env)

    let result = try restore(
      backupData: backupData,
      backupPassphrase: backupPassphrase
    )

    XCTAssertNoDifference(caughtActions, [
      .didDownloadNDF(
        environment: env.ndfEnvironment
      ),
      .didSavePassword(
        password: password
      ),
      .didRemoveDirectory(
        path: env.storageDir
      ),
      .didCreateDirectory(
        path: env.storageDir
      ),
      .didNewCMixFromBackup(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: env.storageDir,
        backupPassphrase: backupPassphrase,
        sessionPassword: password,
        backupFileContents: backupData
      ),
      .didLoadCMix(
        storageDir: env.storageDir,
        password: password,
        cMixParams: cMixParams
      ),
      .cMixDidMakeReceptionIdentity(
        legacy: true
      ),
      .didLogin(
        ephemeral: false,
        cMixId: cMixId,
        identity: receptionIdentity,
        e2eParamsJSON: e2eParams
      ),
      .didNewUdManagerFromBackup(params: .init(
        e2eId: e2eId,
        username: Fact(type: .username, value: backupParams.username),
        email: Fact(type: .email, value: backupParams.email!),
        phone: Fact(type: .phone, value: backupParams.phone!),
        cert: udCertFromNdf,
        contact: udContactFromNdf,
        address: udAddressFromNdf
      )),
      .didSetCMix,
      .didSetE2E,
      .didSetUD,
    ])

    XCTAssertNoDifference(result, backupParams)
  }

  func testDownloadNdfFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var actions: [CaughtAction] = []

    var env: MessengerEnvironment = .unimplemented
    env.downloadNDF.run = { _ in throw failure }
    env.fileManager.removeDirectory = { actions.append(.didRemoveDirectory(path: $0)) }
    let restore: MessengerRestoreBackup = .live(env)

    XCTAssertThrowsError(try restore(backupData: Data(), backupPassphrase: "")) { error in
      XCTAssertNoDifference(error as? Failure, failure)
    }
    XCTAssertNoDifference(actions, [
      .didRemoveDirectory(path: env.storageDir)
    ])
  }
}

private enum CaughtAction: Equatable {
  case didDownloadNDF(
    environment: NDFEnvironment
  )
  case didSavePassword(
    password: Data
  )
  case didRemoveDirectory(
    path: String
  )
  case didCreateDirectory(
    path: String
  )
  case didNewCMixFromBackup(
    ndfJSON: String,
    storageDir: String,
    backupPassphrase: String,
    sessionPassword: Data,
    backupFileContents: Data
  )
  case didLoadCMix(
    storageDir: String,
    password: Data,
    cMixParams: Data
  )
  case didLogin(
    ephemeral: Bool,
    cMixId: Int,
    identity: ReceptionIdentity,
    e2eParamsJSON: Data
  )
  case cMixDidMakeReceptionIdentity(
    legacy: Bool
  )
  case didNewUdManagerFromBackup(
    params: NewUdManagerFromBackup.Params
  )
  case didSetCMix
  case didSetE2E
  case didSetUD
}
