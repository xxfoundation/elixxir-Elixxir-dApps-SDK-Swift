import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXMessengerClient
import XXModels

public struct RestoreComponent: ReducerProtocol {
  public struct State: Equatable {
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
      restoreFailures: [String] = [],
      focusedField: Field? = nil,
      isImportingFile: Bool = false,
      passphrase: String = "",
      isRestoring: Bool = false
    ) {
      self.file = file
      self.fileImportFailure = fileImportFailure
      self.restoreFailures = restoreFailures
      self.focusedField = focusedField
      self.isImportingFile = isImportingFile
      self.passphrase = passphrase
      self.isRestoring = isRestoring
    }

    public var file: File?
    public var fileImportFailure: String?
    public var restoreFailures: [String]
    @BindableState public var focusedField: Field?
    @BindableState public var isImportingFile: Bool
    @BindableState public var passphrase: String
    @BindableState public var isRestoring: Bool
  }

  public enum Action: Equatable, BindableAction {
    case importFileTapped
    case fileImport(Result<URL, NSError>)
    case restoreTapped
    case finished
    case failed([NSError])
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.loadData) var loadData: URLDataLoader
  @Dependency(\.app.now) var now: () -> Date
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
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
            data: try loadData(url)
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
        state.restoreFailures = []
        return Effect.result {
          do {
            let result = try messenger.restoreBackup(
              backupData: backupData,
              backupPassphrase: backupPassphrase
            )
            let facts = try messenger.ud.tryGet().getFacts()
            try db().saveContact(Contact(
              id: try messenger.e2e.tryGet().getContact().getId(),
              username: facts.get(.username)?.value,
              email: facts.get(.email)?.value,
              phone: facts.get(.phone)?.value,
              createdAt: now()
            ))
            try result.restoredContacts.forEach { contactId in
              if try db().fetchContacts(.init(id: [contactId])).isEmpty {
                try db().saveContact(Contact(
                  id: contactId,
                  createdAt: now()
                ))
              }
            }
            return .success(.finished)
          } catch {
            var errors = [error as NSError]
            do {
              try messenger.destroy()
            } catch {
              errors.append(error as NSError)
            }
            return .success(.failed(errors))
          }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .finished:
        state.isRestoring = false
        return .none

      case .failed(let errors):
        state.isRestoring = false
        state.restoreFailures = errors.map(\.localizedDescription)
        return .none

      case .binding(_):
        return .none
      }
    }
  }
}
