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
    var restoreFailure: String?

    init(state: RestoreState) {
      file = state.file.map { .init(name: $0.name, size: $0.data.count) }
      isImportingFile = state.isImportingFile
      passphrase = state.passphrase
      isRestoring = state.isRestoring
      focusedField = state.focusedField
      fileImportFailure = state.fileImportFailure
      restoreFailure = state.restoreFailure
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      NavigationView {
        Form {
          Section {
            if let file = viewStore.file {
              HStack(alignment: .bottom) {
                Text(file.name)
                Spacer()
                Text(format(byteCount: file.size))
              }
            }

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

            if let failure = viewStore.fileImportFailure {
              Text("Error: \(failure)")
            }
          } header: {
            Text("File")
          }
          .disabled(viewStore.isRestoring)

          if viewStore.file != nil {
            Section {
              SecureField("Passphrase", text: viewStore.binding(
                get: \.passphrase,
                send: { .set(\.$passphrase, $0) }
              ))
              .textContentType(.password)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              .focused($focusedField, equals: .passphrase)

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

              if let failure = viewStore.restoreFailure {
                Text("Error: \(failure)")
              }
            } header: {
              Text("Backup")
            }
            .disabled(viewStore.isRestoring)
          }
        }
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              viewStore.send(.finished)
            } label: {
              Text("Cancel")
            }
            .disabled(viewStore.isRestoring)
          }
        }
        .navigationTitle("Restore")
        .onChange(of: viewStore.focusedField) { focusedField = $0 }
        .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
      }
      .navigationViewStyle(.stack)
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
      initialState: RestoreState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
