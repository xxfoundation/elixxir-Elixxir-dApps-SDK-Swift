import ComposableArchitecture
import SwiftUI

public struct RegisterView: View {
  public init(store: StoreOf<RegisterComponent>) {
    self.store = store
  }

  let store: StoreOf<RegisterComponent>
  @FocusState var focusedField: RegisterComponent.State.Field?

  struct ViewState: Equatable {
    init(_ state: RegisterComponent.State) {
      focusedField = state.focusedField
      username = state.username
      isRegistering = state.isRegistering
      failure = state.failure
    }

    var focusedField: RegisterComponent.State.Field?
    var username: String
    var isRegistering: Bool
    var failure: String?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      NavigationView {
        Form {
          Section {
            TextField(
              text: viewStore.binding(
                get: \.username,
                send: { RegisterComponent.Action.set(\.$username, $0) }
              ),
              prompt: Text("Enter username"),
              label: { Text("Username") }
            )
            .focused($focusedField, equals: .username)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
          } header: {
            Text("Username")
          }

          Section {
            Button {
              viewStore.send(.registerTapped)
            } label: {
              HStack {
                Text("Register")
                Spacer()
                if viewStore.isRegistering {
                  ProgressView()
                }
              }
            }
          }

          if let failure = viewStore.failure {
            Section {
              Text(failure)
            } header: {
              Text("Error").foregroundColor(.red)
            }
          }
        }
        .disabled(viewStore.isRegistering)
        .navigationTitle("Register")
        .onChange(of: viewStore.focusedField) { focusedField = $0 }
        .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
      }
    }
  }
}

#if DEBUG
public struct RegisterView_Previews: PreviewProvider {
  public static var previews: some View {
    RegisterView(store: Store(
      initialState: RegisterComponent.State(),
      reducer: EmptyReducer()
    ))
  }
}
#endif
