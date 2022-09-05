import ComposableArchitecture
import ComposablePresentation
import RegisterFeature
import SwiftUI

public struct HomeView: View {
  public init(store: Store<HomeState, HomeAction>) {
    self.store = store
  }

  let store: Store<HomeState, HomeAction>

  struct ViewState: Equatable {
    var failure: String?
    var isDeletingAccount: Bool

    init(state: HomeState) {
      failure = state.failure
      isDeletingAccount = state.isDeletingAccount
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {
          if let failure = viewStore.failure {
            Section {
              Text(failure)
              Button {
                viewStore.send(.messenger(.start))
              } label: {
                Text("Retry")
              }
            } header: {
              Text("Error")
            }
          }

          Section {
            Button(role: .destructive) {
              viewStore.send(.deleteAccount(.buttonTapped))
            } label: {
              HStack {
                Text("Delete Account")
                Spacer()
                if viewStore.isDeletingAccount {
                  ProgressView()
                }
              }
            }
            .disabled(viewStore.isDeletingAccount)
          } header: {
            Text("Account")
          }
        }
        .navigationTitle("Home")
        .alert(
          store.scope(state: \.alert),
          dismiss: HomeAction.didDismissAlert
        )
      }
      .navigationViewStyle(.stack)
      .task { viewStore.send(.messenger(.start)) }
      .fullScreenCover(
        store.scope(
          state: \.register,
          action: HomeAction.register
        ),
        onDismiss: {
          viewStore.send(.didDismissRegister)
        },
        content: RegisterView.init(store:)
      )
    }
  }
}

#if DEBUG
public struct HomeView_Previews: PreviewProvider {
  public static var previews: some View {
    HomeView(store: Store(
      initialState: HomeState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
