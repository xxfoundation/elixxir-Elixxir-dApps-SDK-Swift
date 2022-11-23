import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XXClient
import XXMessengerClient

public struct BackupComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case passphrase
    }

    public init(
      isRunning: Bool = false,
      isStarting: Bool = false,
      isResuming: Bool = false,
      isStopping: Bool = false,
      backup: BackupStorage.Backup? = nil,
      alert: AlertState<Action>? = nil,
      focusedField: Field? = nil,
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
      self.focusedField = focusedField
      self.passphrase = passphrase
      self.isExporting = isExporting
      self.exportData = exportData
    }

    public var isRunning: Bool
    public var isStarting: Bool
    public var isResuming: Bool
    public var isStopping: Bool
    public var backup: BackupStorage.Backup?
    public var alert: AlertState<Action>?
    @BindableState public var focusedField: Field?
    @BindableState public var passphrase: String
    @BindableState public var isExporting: Bool
    public var exportData: Data?
  }

  public enum Action: Equatable, BindableAction {
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
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.backupStorage) var backupStorage: BackupStorage
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      enum TaskEffectId {}

      switch action {
      case .task:
        state.isRunning = messenger.isBackupRunning()
        return Effect.run { subscriber in
          subscriber.send(.backupUpdated(backupStorage.stored()))
          let cancellable = backupStorage.observe { backup in
            subscriber.send(.backupUpdated(backup))
          }
          return AnyCancellable { cancellable.cancel() }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()
        .cancellable(id: TaskEffectId.self, cancelInFlight: true)

      case .cancelTask:
        return .cancel(id: TaskEffectId.self)

      case .startTapped:
        state.isStarting = true
        state.focusedField = nil
        return Effect.run { [state] subscriber in
          do {
            try messenger.startBackup(password: state.passphrase)
            subscriber.send(.didStart(failure: nil))
          } catch {
            subscriber.send(.didStart(failure: error as NSError))
          }
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .resumeTapped:
        state.isResuming = true
        return Effect.run { subscriber in
          do {
            try messenger.resumeBackup()
            subscriber.send(.didResume(failure: nil))
          } catch {
            subscriber.send(.didResume(failure: error as NSError))
          }
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .stopTapped:
        state.isStopping = true
        return Effect.run { subscriber in
          do {
            try messenger.stopBackup()
            try backupStorage.remove()
            subscriber.send(.didStop(failure: nil))
          } catch {
            subscriber.send(.didStop(failure: error as NSError))
          }
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
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
        state.isRunning = messenger.isBackupRunning()
        state.isStarting = false
        if let failure {
          state.alert = .error(failure)
        } else {
          state.passphrase = ""
        }
        return .none

      case .didResume(let failure):
        state.isRunning = messenger.isBackupRunning()
        state.isResuming = false
        if let failure {
          state.alert = .error(failure)
        }
        return .none

      case .didStop(let failure):
        state.isRunning = messenger.isBackupRunning()
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
  }
}
