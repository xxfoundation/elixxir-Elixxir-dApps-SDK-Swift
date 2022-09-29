import ComposableArchitecture
import SwiftUI

public struct RestoreView: View {
  public init(store: Store<RestoreState, RestoreAction>) {
    self.store = store
  }

  let store: Store<RestoreState, RestoreAction>
  @FocusState var focusedField: RestoreState.Field?

  struct ViewState: Equatable {
    struct File: Equatable {
      var name: String
      var size: Int
    }

    var file: File?
    var isImportingFile: Bool
    var passphrase: String
    var isRestoring: Bool
    var focusedField: RestoreState.Field?
    var fileImportFailure: String?
    var restoreFailures: [String]

    init(state: RestoreState) {
      file = state.file.map { .init(name: $0.name, size: $0.data.count) }
      isImportingFile = state.isImportingFile
      passphrase = state.passphrase
      isRestoring = state.isRestoring
      focusedField = state.focusedField
      fileImportFailure = state.fileImportFailure
      restoreFailures = state.restoreFailures
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      NavigationView {
        Form {
          fileSection(viewStore)
          if viewStore.file != nil {
            restoreSection(viewStore)
          }
        }
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              viewStore.send(.finished)
            } label: {
              Text("Cancel")
            }
            .disabled(viewStore.isImportingFile || viewStore.isRestoring)
          }
        }
        .navigationTitle("Restore")
        .onChange(of: viewStore.focusedField) { focusedField = $0 }
        .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
      }
      .navigationViewStyle(.stack)
    }
  }

  @ViewBuilder func fileSection(_ viewStore: ViewStore<ViewState, RestoreAction>) -> some View {
    Section {
      if let file = viewStore.file {
        HStack(alignment: .bottom) {
          Text(file.name)
          Spacer()
          Text(format(byteCount: file.size))
        }
      } else {
        Button {
          viewStore.send(.importFileTapped)
        } label: {
          Text("Import backup file")
        }
        .fileImporter(
          isPresented: viewStore.binding(
            get: \.isImportingFile,
            send: { .set(\.$isImportingFile, $0) }
          ),
          allowedContentTypes: [.data],
          onCompletion: { result in
            viewStore.send(.fileImport(result.mapError { $0 as NSError }))
          }
        )
        .disabled(viewStore.isRestoring)
      }
    } header: {
      Text("File")
    }

    if let failure = viewStore.fileImportFailure {
      Section {
        Text(failure)
      } header: {
        Text("Error")
      }
    }
  }

  @ViewBuilder func restoreSection(_ viewStore: ViewStore<ViewState, RestoreAction>) -> some View {
    Section {
      SecureField("Passphrase", text: viewStore.binding(
        get: \.passphrase,
        send: { .set(\.$passphrase, $0) }
      ))
      .textContentType(.password)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .focused($focusedField, equals: .passphrase)
      .disabled(viewStore.isRestoring)

      Button {
        viewStore.send(.restoreTapped)
      } label: {
        HStack {
          Text("Restore")
          Spacer()
          if viewStore.isRestoring {
            ProgressView()
          }
        }
      }
    } header: {
      Text("Restore")
    }

    if !viewStore.restoreFailures.isEmpty {
      Section {
        ForEach(Array(viewStore.restoreFailures.enumerated()), id: \.offset) { _, failure in
          Text(failure)
        }
        .font(.footnote)
      } header: {
        Text("Error")
      }
    }
  }

  func format(byteCount: Int) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useMB, .useKB, .useBytes]
    formatter.countStyle = .binary
    return formatter.string(fromByteCount: Int64(byteCount))
  }
}

#if DEBUG
public struct RestoreView_Previews: PreviewProvider {
  public static var previews: some View {
    RestoreView(store: Store(
      initialState: RestoreState(
        file: .init(name: "preview", data: Data()),
        fileImportFailure: nil,
        restoreFailures: [
          "Preview failure 1",
          "Preview failure 2",
          "Preview failure 3",
        ],
        focusedField: nil,
        isImportingFile: false,
        passphrase: "",
        isRestoring: false
      ),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
