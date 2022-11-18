import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXMessengerClient

public struct AppDependencies {
  public var dbManager: DBManager
  public var messenger: Messenger
  public var authHandler: AuthCallbackHandler
  public var backupStorage: BackupStorage
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var now: () -> Date
  public var sendMessage: SendMessage
  public var sendImage: SendImage
  public var messageListener: MessageListenerHandler
  public var receiveFileHandler: ReceiveFileHandler
  public var log: Logger
  public var loadData: URLDataLoader
}

extension AppDependencies {
  public static func live() -> AppDependencies {
    let dbManager = DBManager.live()
    let messengerEnv = MessengerEnvironment.live()
    let messenger = Messenger.live(messengerEnv)
    let now: () -> Date = Date.init

    return AppDependencies(
      dbManager: dbManager,
      messenger: messenger,
      authHandler: .live(
        messenger: messenger,
        handleRequest: .live(db: dbManager.getDB, now: now),
        handleConfirm: .live(db: dbManager.getDB),
        handleReset: .live(db: dbManager.getDB)
      ),
      backupStorage: .onDisk(),
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      bgQueue: DispatchQueue(label: "xx-messenger", qos: .userInitiated).eraseToAnyScheduler(),
      now: now,
      sendMessage: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      sendImage: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      messageListener: .live(
        messenger: messenger,
        db: dbManager.getDB
      ),
      receiveFileHandler: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: now
      ),
      log: .live(),
      loadData: .live
    )
  }

  public static let unimplemented = AppDependencies(
    dbManager: .unimplemented,
    messenger: .unimplemented,
    authHandler: .unimplemented,
    backupStorage: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    now: XCTestDynamicOverlay.unimplemented(
      "\(Self.self)",
      placeholder: Date(timeIntervalSince1970: 0)
    ),
    sendMessage: .unimplemented,
    sendImage: .unimplemented,
    messageListener: .unimplemented,
    receiveFileHandler: .unimplemented,
    log: .unimplemented,
    loadData: .unimplemented
  )
}

private enum AppDependenciesKey: DependencyKey {
  static let liveValue: AppDependencies = .live()
  static let testValue: AppDependencies = .unimplemented
}

extension DependencyValues {
  public var app: AppDependencies {
    get { self[AppDependenciesKey.self] }
    set { self[AppDependenciesKey.self] = newValue }
  }
}
