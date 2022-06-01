import ComposableArchitecture
import ComposablePresentation
import ErrorFeature
import SwiftUI

public struct LandingView: View {
  public init(store: Store<LandingState, LandingAction>) {
    self.store = store
  }

  let store: Store<LandingState, LandingAction>

  struct ViewState: Equatable {
    let hasStoredClient: Bool
    let isMakingClient: Bool
    let isRemovingClient: Bool

    init(state: LandingState) {
      hasStoredClient = state.hasStoredClient
      isMakingClient = state.isMakingClient
      isRemovingClient = state.isRemovingClient
    }

    var isLoading: Bool {
      isMakingClient ||
      isRemovingClient
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Button {
          viewStore.send(.makeClient)
        } label: {
          HStack {
            Text(viewStore.hasStoredClient ? "Load stored client" : "Create new client")
            Spacer()
            if viewStore.isMakingClient {
              ProgressView()
            }
          }
        }

        if viewStore.hasStoredClient {
          Button(role: .destructive) {
            viewStore.send(.removeStoredClient)
          } label: {
            HStack {
              Text("Remove stored client")
              Spacer()
              if viewStore.isRemovingClient {
                ProgressView()
              }
            }
          }
        }
      }
      .navigationTitle("Landing")
      .disabled(viewStore.isLoading)
      .task {
        viewStore.send(.viewDidLoad)
      }
      .sheet(
        store.scope(
          state: \.error,
          action: LandingAction.error
        ),
        onDismiss: {
          viewStore.send(.didDismissError)
        },
        content: ErrorView.init(store:)
      )
    }
  }
}

#if DEBUG
public struct LandingView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      LandingView(store: .init(
        initialState: .init(),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(.stack)
  }
}
#endif
