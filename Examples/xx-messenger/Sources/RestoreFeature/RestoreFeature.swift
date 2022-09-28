import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXMessengerClient
import XXModels

public struct RestoreState: Equatable {
  public enum Field: String, Hashable {
    case passphrase
  }

  public struct File: Equatable {
    public init(name: String, data: Data) {
      self.name = name
      self.data = data
    }

    public var name: String
    public var data: Data
  }

  public init(
    file: File? = nil,
    fileImportFailure: String? = nil,
    restoreFailure: String? = nil,
    focusedField: Field? = nil,
    isImportingFile: Bool = false,
    passphrase: String = "",
    isRestoring: Bool = false
  ) {
    self.file = file
    self.fileImportFailure = fileImportFailure
    self.restoreFailure = restoreFailure
    self.focusedField = focusedField
    self.isImportingFile = isImportingFile
    self.passphrase = passphrase
    self.isRestoring = isRestoring
  }

  public var file: File?
  public var fileImportFailure: String?
  public var restoreFailure: String?
  @BindableState public var focusedField: Field?
  @BindableState public var isImportingFile: Bool
  @BindableState public var passphrase: String
  @BindableState public var isRestoring: Bool
}

public enum RestoreAction: Equatable, BindableAction {
  case importFileTapped
  case fileImport(Result<URL, NSError>)
  case restoreTapped
  case finished
  case failed(NSError)
  case binding(BindingAction<RestoreState>)
}

public struct RestoreEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    loadData: URLDataLoader,
    now: @escaping () -> Date,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.loadData = loadData
    self.now = now
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var loadData: URLDataLoader
  public var now: () -> Date
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

extension RestoreEnvironment {
  public static let unimplemented = RestoreEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    loadData: .unimplemented,
    now: XCTUnimplemented("\(Self.self).now"),
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}

public let restoreReducer = Reducer<RestoreState, RestoreAction, RestoreEnvironment>
{ state, action, env in
  switch action {
  case .importFileTapped:
    state.isImportingFile = true
    state.fileImportFailure = nil
    return .none

  case .fileImport(.success(let url)):
    state.isImportingFile = false
    do {
      state.file = .init(
        name: url.lastPathComponent,
        data: try env.loadData(url)
      )
      state.fileImportFailure = nil
    } catch {
      state.file = nil
      state.fileImportFailure = error.localizedDescription
    }
    return .none

  case .fileImport(.failure(let error)):
    state.isImportingFile = false
    state.file = nil
    state.fileImportFailure = error.localizedDescription
    return .none

  case .restoreTapped:
    guard let backupData = state.file?.data, backupData.count > 0 else { return .none }
    let backupPassphrase = state.passphrase
    state.isRestoring = true
    state.restoreFailure = nil
    return Effect.result {
      do {
        let result = try env.messenger.restoreBackup(
          backupData: backupData,
          backupPassphrase: backupPassphrase
        )
        let facts = try env.messenger.ud.tryGet().getFacts()
        try env.db().saveContact(Contact(
          id: try env.messenger.e2e.tryGet().getContact().getId(),
          username: result.restoredParams.username,
          email: facts.get(.email)?.value,
          phone: facts.get(.phone)?.value,
          createdAt: env.now()
        ))
        return .success(.finished)
      } catch {
        try? env.messenger.destroy()
        return .success(.failed(error as NSError))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .finished:
    state.isRestoring = false
    return .none

  case .failed(let error):
    state.isRestoring = false
    state.restoreFailure = error.localizedDescription
    return .none

  case .binding(_):
    return .none
  }
}
.binding()
