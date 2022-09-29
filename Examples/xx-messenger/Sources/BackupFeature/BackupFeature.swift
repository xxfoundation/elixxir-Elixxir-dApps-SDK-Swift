import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XXClient
import XXMessengerClient
import XXModels

public struct BackupState: Equatable {
  public enum Error: String, Swift.Error, Equatable {
    case dbContactNotFound
    case dbContactUsernameMissing
  }

  public init(
    isRunning: Bool = false,
    isStarting: Bool = false,
    isResuming: Bool = false,
    isStopping: Bool = false,
    backup: BackupStorage.Backup? = nil,
    alert: AlertState<BackupAction>? = nil,
    passphrase: String = "",
    isExporting: Bool = false,
    exportData: Data? = nil
  ) {
    self.isRunning = isRunning
    self.isStarting = isStarting
    self.isResuming = isResuming
    self.isStopping = isStopping
    self.backup = backup
    self.alert = alert
    self.passphrase = passphrase
    self.isExporting = isExporting
    self.exportData = exportData
  }

  public var isRunning: Bool
  public var isStarting: Bool
  public var isResuming: Bool
  public var isStopping: Bool
  public var backup: BackupStorage.Backup?
  public var alert: AlertState<BackupAction>?
  @BindableState public var passphrase: String
  @BindableState public var isExporting: Bool
  public var exportData: Data?
}

public enum BackupAction: Equatable, BindableAction {
  case task
  case cancelTask
  case startTapped
  case resumeTapped
  case stopTapped
  case exportTapped
  case alertDismissed
  case backupUpdated(BackupStorage.Backup?)
  case didStart(failure: NSError?)
  case didResume(failure: NSError?)
  case didStop(failure: NSError?)
  case didExport(failure: NSError?)
  case binding(BindingAction<BackupState>)
}

public struct BackupEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    backupStorage: BackupStorage,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.backupStorage = backupStorage
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var backupStorage: BackupStorage
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension BackupEnvironment {
  public static let unimplemented = BackupEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    backupStorage: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let backupReducer = Reducer<BackupState, BackupAction, BackupEnvironment>
{ state, action, env in
  enum TaskEffectId {}

  switch action {
  case .task:
    state.isRunning = env.messenger.isBackupRunning()
    return Effect.run { subscriber in
      subscriber.send(.backupUpdated(env.backupStorage.stored()))
      let cancellable = env.backupStorage.observe { backup in
        subscriber.send(.backupUpdated(backup))
      }
      return AnyCancellable { cancellable.cancel() }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()
    .cancellable(id: TaskEffectId.self, cancelInFlight: true)

  case .cancelTask:
    return .cancel(id: TaskEffectId.self)

  case .startTapped:
    state.isStarting = true
    return Effect.run { [state] subscriber in
      do {
        let e2e: E2E = try env.messenger.e2e.tryGet()
        let contactID = try e2e.getContact().getId()
        let db = try env.db()
        let query = XXModels.Contact.Query(id: [contactID])
        guard let contact = try db.fetchContacts(query).first else {
          throw BackupState.Error.dbContactNotFound
        }
        guard let username = contact.username else {
          throw BackupState.Error.dbContactUsernameMissing
        }
        try env.messenger.startBackup(
          password: state.passphrase,
          params: BackupParams(username: username)
        )
        subscriber.send(.didStart(failure: nil))
      } catch {
        subscriber.send(.didStart(failure: error as NSError))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .resumeTapped:
    state.isResuming = true
    return Effect.run { subscriber in
      do {
        try env.messenger.resumeBackup()
        subscriber.send(.didResume(failure: nil))
      } catch {
        subscriber.send(.didResume(failure: error as NSError))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .stopTapped:
    state.isStopping = true
    return Effect.run { subscriber in
      do {
        try env.messenger.stopBackup()
        try env.backupStorage.remove()
        subscriber.send(.didStop(failure: nil))
      } catch {
        subscriber.send(.didStop(failure: error as NSError))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .exportTapped:
    state.isExporting = true
    state.exportData = state.backup?.data
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none

  case .backupUpdated(let backup):
    state.backup = backup
    return .none

  case .didStart(let failure):
    state.isRunning = env.messenger.isBackupRunning()
    state.isStarting = false
    if let failure {
      state.alert = .error(failure)
    } else {
      state.passphrase = ""
    }
    return .none

  case .didResume(let failure):
    state.isRunning = env.messenger.isBackupRunning()
    state.isResuming = false
    if let failure {
      state.alert = .error(failure)
    }
    return .none

  case .didStop(let failure):
    state.isRunning = env.messenger.isBackupRunning()
    state.isStopping = false
    if let failure {
      state.alert = .error(failure)
    }
    return .none

  case .didExport(let failure):
    state.isExporting = false
    state.exportData = nil
    if let failure {
      state.alert = .error(failure)
    }
    return .none

  case .binding(_):
    return .none
  }
}
.binding()
