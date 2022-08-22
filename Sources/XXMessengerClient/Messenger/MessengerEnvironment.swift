import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerEnvironment {
  public var ctx: MessengerContext
  public var downloadNDF: DownloadAndVerifySignedNdf
  public var fileManager: MessengerFileManager
  public var generateSecret: GenerateSecret
  public var getCMixParams: GetCMixParams
  public var getE2EParams: GetE2EParams
  public var isRegisteredWithUD: IsRegisteredWithUD
  public var loadCMix: LoadCMix
  public var login: Login
  public var ndfEnvironment: NDFEnvironment
  public var newCMix: NewCMix
  public var newOrLoadUd: NewOrLoadUd
  public var passwordStorage: PasswordStorage
  public var storageDir: String
  public var udAddress: String?
  public var udCert: Data?
  public var udContact: Data?
}

extension MessengerEnvironment {
  public static let defaultStorageDir = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first!
    .appendingPathComponent("xx.network.client")
    .path

  public static func live() -> MessengerEnvironment {
    MessengerEnvironment(
      ctx: .live(),
      downloadNDF: .live,
      fileManager: .live(),
      generateSecret: .live,
      getCMixParams: .liveDefault,
      getE2EParams: .liveDefault,
      isRegisteredWithUD: .live,
      loadCMix: .live,
      login: .live,
      ndfEnvironment: .mainnet,
      newCMix: .live,
      newOrLoadUd: .live,
      passwordStorage: .keychain,
      storageDir: MessengerEnvironment.defaultStorageDir,
      udAddress: nil,
      udCert: nil,
      udContact: nil
    )
  }
}

extension MessengerEnvironment {
  public static let unimplemented = MessengerEnvironment(
    ctx: .unimplemented,
    downloadNDF: .unimplemented,
    fileManager: .unimplemented,
    generateSecret: .unimplemented,
    getCMixParams: .unimplemented,
    getE2EParams: .unimplemented,
    isRegisteredWithUD: .unimplemented,
    loadCMix: .unimplemented,
    login: .unimplemented,
    ndfEnvironment: .unimplemented,
    newCMix: .unimplemented,
    newOrLoadUd: .unimplemented,
    passwordStorage: .unimplemented,
    storageDir: "unimplemented",
    udAddress: nil,
    udCert: nil,
    udContact: nil
  )
}
