import Bindings

public struct CmixManager {
  public var hasStorage: CmixManagerHasStorage
  public var create: CmixManagerCreate
  public var load: CmixManagerLoad
  public var remove: CmixManagerRemove
}

extension CmixManager {
  public static func live(
    directoryPath: String = FileManager.default
      .urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!
      .appendingPathComponent("xx.network.client")
      .path,
    fileManager: FileManager = .default,
    environment: Environment = .mainnet,
    downloadNDF: DownloadAndVerifySignedNdf = .live,
    generateSecret: GenerateSecret = .live,
    passwordStorage: PasswordStorage,
    newCmix: NewCmix = .live,
    getCmixParams: GetCmixParams = .liveDefault,
    loadCmix: LoadCmix = .live
  ) -> CmixManager {
    CmixManager(
      hasStorage: .live(
        directoryPath: directoryPath,
        fileManager: fileManager
      ),
      create: .live(
        environment: environment,
        downloadNDF: downloadNDF,
        generateSecret: generateSecret,
        passwordStorage: passwordStorage,
        directoryPath: directoryPath,
        fileManager: fileManager,
        newCmix: newCmix,
        getCmixParams: getCmixParams,
        loadCmix: loadCmix
      ),
      load: .live(
        directoryPath: directoryPath,
        passwordStorage: passwordStorage,
        getCmixParams: getCmixParams,
        loadCmix: loadCmix
      ),
      remove: .live(
        directoryPath: directoryPath,
        fileManager: fileManager
      )
    )
  }
}

extension CmixManager {
  public static let unimplemented = CmixManager(
    hasStorage: .unimplemented,
    create: .unimplemented,
    load: .unimplemented,
    remove: .unimplemented
  )
}
