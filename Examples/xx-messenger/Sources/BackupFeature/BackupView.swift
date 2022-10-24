import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

public struct BackupView: View {
  public init(store: StoreOf<BackupComponent>) {
    self.store = store
  }

  let store: StoreOf<BackupComponent>
  @FocusState var focusedField: BackupComponent.State.Field?

  struct ViewState: Equatable {
    struct Backup: Equatable {
      var date: Date
      var size: Int
    }

    init(state: BackupComponent.State) {
      isRunning = state.isRunning
      isStarting = state.isStarting
      isResuming = state.isResuming
      isStopping = state.isStopping
      backup = state.backup.map { backup in
        Backup(date: backup.date, size: backup.data.count)
      }
      focusedField = state.focusedField
      passphrase = state.passphrase
      isExporting = state.isExporting
      exportData = state.exportData
    }

    var isRunning: Bool
    var isStarting: Bool
    var isResuming: Bool
    var isStopping: Bool
    var isLoading: Bool { isStarting || isResuming || isStopping }
    var backup: Backup?
    var focusedField: BackupComponent.State.Field?
    var passphrase: String
    var isExporting: Bool
    var exportData: Data?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Group {
          if viewStore.isRunning || viewStore.backup != nil {
            backupSection(viewStore)
          }
          if !viewStore.isRunning {
            newBackupSection(viewStore)
          }
        }
        .disabled(viewStore.isLoading)
        .alert(
          store.scope(state: \.alert),
          dismiss: .alertDismissed
        )
      }
      .navigationTitle("Backup")
      .task { await viewStore.send(.task).finish() }
      .onChange(of: viewStore.focusedField) { focusedField = $0 }
      .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
    }
  }

  @ViewBuilder func newBackupSection(
    _ viewStore: ViewStore<ViewState, BackupComponent.Action>
  ) -> some View {
    Section {
      SecureField(
        text: viewStore.binding(
          get: \.passphrase,
          send: { .set(\.$passphrase, $0) }
        ),
        prompt: Text("Backup passphrase"),
        label: { Text("Backup passphrase") }
      )
      .textContentType(.password)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .focused($focusedField, equals: .passphrase)

      Button {
        viewStore.send(.startTapped)
      } label: {
        HStack {
          Text("Start")
          Spacer()
          if viewStore.isStarting {
            ProgressView()
          } else {
            Image(systemName: "play.fill")
          }
        }
      }
    } header: {
      Text("New backup")
    }
    .disabled(viewStore.isStarting)
  }

  @ViewBuilder func backupSection(
    _ viewStore: ViewStore<ViewState, BackupComponent.Action>
  ) -> some View {
    Section {
      backupView(viewStore)
      stopView(viewStore)
      resumeView(viewStore)
    } header: {
      Text("Backup")
    }
  }

  @ViewBuilder func backupView(
    _ viewStore: ViewStore<ViewState, BackupComponent.Action>
  ) -> some View {
    if let backup = viewStore.backup {
      HStack {
        Text("Date")
        Spacer()
        Text(backup.date.formatted())
      }
      HStack {
        Text("Size")
        Spacer()
        Text(format(bytesCount: backup.size))
      }
      Button {
        viewStore.send(.exportTapped)
      } label: {
        HStack {
          Text("Export")
          Spacer()
          if viewStore.isExporting {
            ProgressView()
          } else {
            Image(systemName: "square.and.arrow.up")
          }
        }
      }
      .disabled(viewStore.isExporting)
      .fileExporter(
        isPresented: viewStore.binding(
          get: \.isExporting,
          send: { .set(\.$isExporting, $0) }
        ),
        document: viewStore.exportData.map(ExportedDocument.init(data:)),
        contentType: .data,
        defaultFilename: "backup.xxm",
        onCompletion: { result in
          switch result {
          case .success(_):
            viewStore.send(.didExport(failure: nil))
          case .failure(let error):
            viewStore.send(.didExport(failure: error as NSError?))
          }
        }
      )
    } else {
      Text("No backup")
    }
  }

  @ViewBuilder func stopView(
    _ viewStore: ViewStore<ViewState, BackupComponent.Action>
  ) -> some View {
    if viewStore.isRunning {
      Button {
        viewStore.send(.stopTapped)
      } label: {
        HStack {
          Text("Stop")
          Spacer()
          if viewStore.isStopping {
            ProgressView()
          } else {
            Image(systemName: "stop.fill")
          }
        }
      }
    }
  }

  @ViewBuilder func resumeView(
    _ viewStore: ViewStore<ViewState, BackupComponent.Action>
  ) -> some View {
    if !viewStore.isRunning, viewStore.backup != nil {
      Button {
        viewStore.send(.resumeTapped)
      } label: {
        HStack {
          Text("Resume")
          Spacer()
          if viewStore.isResuming {
            ProgressView()
          } else {
            Image(systemName: "playpause.fill")
          }
        }
      }
    }
  }

  func format(bytesCount bytes: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useKB]
    formatter.countStyle = .binary
    return formatter.string(fromByteCount: Int64(bytes))
  }
}

private struct ExportedDocument: FileDocument {
  enum Error: Swift.Error {
    case notAvailable
  }

  static var readableContentTypes: [UTType] = []
  static var writableContentTypes: [UTType] = [.data]

  var data: Data

  init(data: Data) {
    self.data = data
  }

  init(configuration: ReadConfiguration) throws {
    throw Error.notAvailable
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    FileWrapper(regularFileWithContents: data)
  }
}

#if DEBUG
public struct BackupView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      BackupView(store: Store(
        initialState: BackupComponent.State(),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
