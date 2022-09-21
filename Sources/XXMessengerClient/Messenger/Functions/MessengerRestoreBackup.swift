import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerRestoreBackup {
  public var run: (Data, String) throws -> BackupParams

  public func callAsFunction(
    backupData: Data,
    backupPassphrase: String
  ) throws -> BackupParams {
    try run(backupData, backupPassphrase)
  }
}

extension MessengerRestoreBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerRestoreBackup {
    MessengerRestoreBackup { backupData, backupPassphrase in
      let storageDir = env.storageDir
      do {
        let ndfData = try env.downloadNDF(env.ndfEnvironment)
        let password = env.generateSecret()
        try env.passwordStorage.save(password)
        try env.fileManager.removeDirectory(storageDir)
        try env.fileManager.createDirectory(storageDir)
        let report = try env.newCMixFromBackup(
          ndfJSON: String(data: ndfData, encoding: .utf8)!,
          storageDir: storageDir,
          backupPassphrase: backupPassphrase,
          sessionPassword: password,
          backupFileContents: backupData
        )
        let cMix = try env.loadCMix(
          storageDir: storageDir,
          password: password,
          cMixParamsJSON: env.getCMixParams()
        )
        let e2e = try env.login(
          cMixId: cMix.getId(),
          authCallbacks: env.authCallbacks.registered(),
          identity: try cMix.makeReceptionIdentity(legacy: true),
          e2eParamsJSON: env.getE2EParams()
        )
        let decoder = JSONDecoder()
        let paramsData = report.params.data(using: .utf8)!
        let params = try decoder.decode(BackupParams.self, from: paramsData)
        let ud = try env.newUdManagerFromBackup(
          params: NewUdManagerFromBackup.Params(
            e2eId: e2e.getId(),
            username: Fact(type: .username, value: params.username),
            email: params.email.map { Fact(type: .email, value: $0) },
            phone: params.phone.map { Fact(type: .phone, value: $0) },
            cert: env.udCert ?? e2e.getUdCertFromNdf(),
            contact: env.udContact ?? (try e2e.getUdContactFromNdf()),
            address: env.udAddress ?? e2e.getUdAddressFromNdf()
          ),
          follower: UdNetworkStatus { cMix.networkFollowerStatus() }
        )
        env.cMix.set(cMix)
        env.e2e.set(e2e)
        env.ud.set(ud)
        return params
      } catch {
        try? env.fileManager.removeDirectory(storageDir)
        throw error
      }
    }
  }
}

extension MessengerRestoreBackup {
  public static let unimplemented = MessengerRestoreBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
