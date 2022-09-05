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
    }

    var isCreatingAccount: Bool
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {
          Section {
            Text("xx messenger")
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
