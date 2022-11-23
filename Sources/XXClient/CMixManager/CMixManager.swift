import Bindings

public struct CMixManager {
  public var hasStorage: CMixManagerHasStorage
  public var create: CMixManagerCreate
  public var restore: CMixManagerRestore
  public var load: CMixManagerLoad
  public var remove: CMixManagerRemove
}

extension CMixManager {
  public static func live(
    directoryPath: String = FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!
      .appendingPathComponent("xx.network.client")
      .path,
    fileManager: FileManager = .default,
    ndfEnvironment: NDFEnvironment = .mainnet,
    downloadNDF: DownloadAndVerifySignedNdf = .live,
    generateSecret: GenerateSecret = .live,
    passwordStorage: PasswordStorage,
    newCMix: NewCMix = .live,
    getCMixParams: GetCMixParams = .liveDefault,
    loadCMix: LoadCMix = .live,
    newCMixFromBackup: NewCMixFromBackup = .live
  ) -> CMixManager {
    CMixManager(
      hasStorage: .live(
        directoryPath: directoryPath,
        fileManager: fileManager
      ),
      create: .live(
        ndfEnvironment: ndfEnvironment,
        downloadNDF: downloadNDF,
        generateSecret: generateSecret,
        passwordStorage: passwordStorage,
        directoryPath: directoryPath,
        fileManager: fileManager,
        newCMix: newCMix,
        getCMixParams: getCMixParams,
        loadCMix: loadCMix
      ),
      restore: .live(
        ndfEnvironment: ndfEnvironment,
        downloadNDF: downloadNDF,
        generateSecret: generateSecret,
        passwordStorage: passwordStorage,
        directoryPath: directoryPath,
        fileManager: fileManager,
        newCMixFromBackup: newCMixFromBackup
      ),
      load: .live(
        directoryPath: directoryPath,
        passwordStorage: passwordStorage,
        getCMixParams: getCMixParams,
        loadCMix: loadCMix
      ),
      remove: .live(
        directoryPath: directoryPath,
        fileManager: fileManager
      )
    )
  }
}

extension CMixManager {
  public static let unimplemented = CMixManager(
    hasStorage: .unimplemented,
    create: .unimplemented,
    restore: .unimplemented,
    load: .unimplemented,
    remove: .unimplemented
  )
}
