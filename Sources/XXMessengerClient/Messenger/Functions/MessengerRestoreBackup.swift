import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerRestoreBackup {
  public struct Result: Equatable {
    public init(
      restoredParams: BackupParams,
      restoredContacts: [Data]
    ) {
      self.restoredParams = restoredParams
      self.restoredContacts = restoredContacts
    }

    public var restoredParams: BackupParams
    public var restoredContacts: [Data]
  }

  public var run: (Data, String) throws -> Result

  public func callAsFunction(
    backupData: Data,
    backupPassphrase: String
  ) throws -> Result {
    try run(backupData, backupPassphrase)
  }
}

extension MessengerRestoreBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerRestoreBackup {
    MessengerRestoreBackup { backupData, backupPassphrase in
      let storageDir = env.storageDir
      let ndfData = try env.downloadNDF(env.ndfEnvironment)
      let password = env.generateSecret()
      try env.passwordStorage.save(password)
      try env.fileManager.removeItem(storageDir)
      try env.fileManager.createDirectory(storageDir)
      let report = try env.newCMixFromBackup(
        ndfJSON: String(data: ndfData, encoding: .utf8)!,
        storageDir: storageDir,
        backupPassphrase: backupPassphrase,
        sessionPassword: password,
        backupFileContents: backupData
      )
      let paramsData = report.params.data(using: .utf8)!
      let params = try BackupParams.decode(paramsData)
      let cMix = try env.loadCMix(
        storageDir: storageDir,
        password: password,
        cMixParamsJSON: env.getCMixParams()
      )
      env.cMix.set(cMix)
      try cMix.startNetworkFollower(timeoutMS: 30_000)
      let e2e = try env.login(
        cMixId: cMix.getId(),
        authCallbacks: env.authCallbacks.registered(),
        identity: try cMix.makeReceptionIdentity(legacy: true),
        e2eParamsJSON: env.getE2EParams()
      )
      env.e2e.set(e2e)
      env.isListeningForMessages.set(false)
      let ud = try env.newUdManagerFromBackup(
        params: NewUdManagerFromBackup.Params(
          e2eId: e2e.getId(),
          environment: env.udEnvironment ?? (try e2e.getUdEnvironmentFromNdf())
        ),
        follower: UdNetworkStatus { cMix.networkFollowerStatus() }
      )
      env.ud.set(ud)
      return Result(
        restoredParams: params,
        restoredContacts: report.restoredContacts
      )
    }
  }
}

extension MessengerRestoreBackup {
  public static let unimplemented = MessengerRestoreBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
