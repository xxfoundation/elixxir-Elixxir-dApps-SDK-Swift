import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerEnvironment {
  public var authCallbacks: AuthCallbacksRegistry
  public var backup: Stored<Backup?>
  public var backupCallbacks: BackupCallbacksRegistry
  public var cMix: Stored<CMix?>
  public var downloadNDF: DownloadAndVerifySignedNdf
  public var e2e: Stored<E2E?>
  public var fileManager: MessengerFileManager
  public var fileTransfer: Stored<FileTransfer?>
  public var generateSecret: GenerateSecret
  public var getCMixParams: GetCMixParams
  public var getE2EFileTransferParams: GetE2EFileTransferParams
  public var getE2EParams: GetE2EParams
  public var getFileTransferParams: GetFileTransferParams
  public var getNotificationsReport: GetNotificationsReport
  public var getSingleUseParams: GetSingleUseParams
  public var groupChatProcessors: GroupChatProcessorRegistry
  public var groupRequests: GroupRequestCallbacksRegistry
  public var initFileTransfer: InitFileTransfer
  public var initializeBackup: InitializeBackup
  public var isListeningForMessages: Stored<Bool>
  public var isRegisteredWithUD: IsRegisteredWithUD
  public var loadCMix: LoadCMix
  public var logger: MessengerLogger
  public var login: Login
  public var lookupUD: LookupUD
  public var messageListeners: ListenersRegistry
  public var multiLookupUD: MultiLookupUD
  public var ndfEnvironment: NDFEnvironment
  public var newCMix: NewCMix
  public var newCMixFromBackup: NewCMixFromBackup
  public var newOrLoadUd: NewOrLoadUd
  public var newUdManagerFromBackup: NewUdManagerFromBackup
  public var passwordStorage: PasswordStorage
  public var receiveFileCallbacks: ReceiveFileCallbacksRegistry
  public var registerForNotifications: RegisterForNotifications
  public var registerLogWriter: RegisterLogWriter
  public var resumeBackup: ResumeBackup
  public var searchUD: SearchUD
  public var serviceList: Stored<MessageServiceList?>
  public var setLogLevel: SetLogLevel
  public var sleep: (TimeInterval) -> Void
  public var storageDir: String
  public var ud: Stored<UserDiscovery?>
  public var udEnvironment: UDEnvironment?
}

extension MessengerEnvironment {
  public static let defaultStorageDir = FileManager.default
    .urls(for: .applicationSupportDirectory, in: .userDomainMask)
    .first!
    .appendingPathComponent("xx.network.client")
    .path

  public static func live() -> MessengerEnvironment {
    MessengerEnvironment(
      authCallbacks: .live(),
      backup: .inMemory(),
      backupCallbacks: .live(),
      cMix: .inMemory(),
      downloadNDF: .live,
      e2e: .inMemory(),
      fileManager: .live(),
      fileTransfer: .inMemory(),
      generateSecret: .live,
      getCMixParams: .liveDefault,
      getE2EFileTransferParams: .liveDefault,
      getE2EParams: .liveDefault,
      getFileTransferParams: .liveDefault,
      getNotificationsReport: .live,
      getSingleUseParams: .liveDefault,
      groupChatProcessors: .live(),
      groupRequests: .live(),
      initFileTransfer: .live,
      initializeBackup: .live,
      isListeningForMessages: .inMemory(false),
      isRegisteredWithUD: .live,
      loadCMix: .live,
      logger: .live(),
      login: .live,
      lookupUD: .live,
      messageListeners: .live(),
      multiLookupUD: .live(),
      ndfEnvironment: .mainnet,
      newCMix: .live,
      newCMixFromBackup: .live,
      newOrLoadUd: .live,
      newUdManagerFromBackup: .live,
      passwordStorage: .keychain,
      receiveFileCallbacks: .live(),
      registerForNotifications: .live,
      registerLogWriter: .live,
      resumeBackup: .live,
      searchUD: .live,
      serviceList: .inMemory(),
      setLogLevel: .live,
      sleep: { Thread.sleep(forTimeInterval: $0) },
      storageDir: MessengerEnvironment.defaultStorageDir,
      ud: .inMemory(),
      udEnvironment: nil
    )
  }
}

extension MessengerEnvironment {
  public static let unimplemented = MessengerEnvironment(
    authCallbacks: .unimplemented,
    backup: .unimplemented(),
    backupCallbacks: .unimplemented,
    cMix: .unimplemented(),
    downloadNDF: .unimplemented,
    e2e: .unimplemented(),
    fileManager: .unimplemented,
    fileTransfer: .unimplemented(),
    generateSecret: .unimplemented,
    getCMixParams: .unimplemented,
    getE2EFileTransferParams: .unimplemented,
    getE2EParams: .unimplemented,
    getFileTransferParams: .unimplemented,
    getNotificationsReport: .unimplemented,
    getSingleUseParams: .unimplemented,
    groupChatProcessors: .unimplemented,
    groupRequests: .unimplemented,
    initFileTransfer: .unimplemented,
    initializeBackup: .unimplemented,
    isListeningForMessages: .unimplemented(placeholder: false),
    isRegisteredWithUD: .unimplemented,
    loadCMix: .unimplemented,
    logger: .unimplemented,
    login: .unimplemented,
    lookupUD: .unimplemented,
    messageListeners: .unimplemented,
    multiLookupUD: .unimplemented,
    ndfEnvironment: .unimplemented,
    newCMix: .unimplemented,
    newCMixFromBackup: .unimplemented,
    newOrLoadUd: .unimplemented,
    newUdManagerFromBackup: .unimplemented,
    passwordStorage: .unimplemented,
    receiveFileCallbacks: .unimplemented,
    registerForNotifications: .unimplemented,
    registerLogWriter: .unimplemented,
    resumeBackup: .unimplemented,
    searchUD: .unimplemented,
    serviceList: .unimplemented(),
    setLogLevel: .unimplemented,
    sleep: XCTUnimplemented("\(Self.self).sleep"),
    storageDir: "unimplemented",
    ud: .unimplemented(),
    udEnvironment: nil
  )
}
