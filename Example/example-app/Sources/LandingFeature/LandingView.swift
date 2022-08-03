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
    let hasStoredCmix: Bool
    let isMakingCmix: Bool
    let isRemovingCmix: Bool

    init(state: LandingState) {
      hasStoredCmix = state.hasStoredCmix
      isMakingCmix = state.isMakingCmix
      isRemovingCmix = state.isRemovingCmix
    }

    var isLoading: Bool {
      isMakingCmix ||
      isRemovingCmix
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Button {
          viewStore.send(.makeCmix)
        } label: {
          HStack {
            Text(viewStore.hasStoredCmix ? "Load stored cMix" : "Create new cMix")
            Spacer()
            if viewStore.isMakingCmix {
              ProgressView()
            }
          }
        }

        if viewStore.hasStoredCmix {
          Button(role: .destructive) {
            viewStore.send(.removeStoredCmix)
          } label: {
            HStack {
              Text("Remove stored cMix")
              Spacer()
              if viewStore.isRemovingCmix {
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
        initialState: .init(id: UUID()),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(.stack)
  }
}
#endif
