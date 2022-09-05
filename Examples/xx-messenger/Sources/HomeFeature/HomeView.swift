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

    init(state: HomeState) {
      failure = state.failure
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
                viewStore.send(.start)
              } label: {
                Text("Retry")
              }
            } header: {
              Text("Error")
            }
          }
        }
        .navigationTitle("Home")
      }
      .navigationViewStyle(.stack)
      .task { viewStore.send(.start) }
      .fullScreenCover(
        store.scope(
          state: \.register,
          action: HomeAction.register
        ),
        onDismiss: {
          viewStore.send(.set(\.$register, nil))
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
