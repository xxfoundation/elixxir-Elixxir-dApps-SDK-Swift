import AppCore
import ComposableArchitecture
import SwiftUI

public struct WelcomeView: View {
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }

  let store: Store<WelcomeState, WelcomeAction>

  struct ViewState: Equatable {
    init(_ state: WelcomeState) {
      isCreatingAccount = state.isCreatingAccount
      failure = state.failure
    }

    var isCreatingAccount: Bool
    var failure: String?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      NavigationView {
        Form {
          Section {
            AppVersionText()
          } header: {
            Text("App version")
          }

          if let failure = viewStore.failure {
            Section {
              Text(failure)
            } header: {
              Text("Error")
            }
          }

          Section {
            Button {
              viewStore.send(.newAccountTapped)
            } label: {
              HStack {
                Text("New Account")
                Spacer()
                if viewStore.isCreatingAccount {
                  ProgressView()
                }
              }
            }

            Button {
              viewStore.send(.restoreTapped)
            } label: {
              Text("Restore from Backup")
            }
          }
        }
        .disabled(viewStore.isCreatingAccount)
        .navigationTitle("Welcome")
      }
      .navigationViewStyle(.stack)
    }
  }
}

#if DEBUG
public struct WelcomeView_Previews: PreviewProvider {
  public static var previews: some View {
    WelcomeView(store: Store(
      initialState: WelcomeState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
