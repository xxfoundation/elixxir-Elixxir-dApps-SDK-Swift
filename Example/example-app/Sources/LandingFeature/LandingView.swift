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
    let hasStoredCMix: Bool
    let isMakingCMix: Bool
    let isRemovingCMix: Bool

    init(state: LandingState) {
      hasStoredCMix = state.hasStoredCMix
      isMakingCMix = state.isMakingCMix
      isRemovingCMix = state.isRemovingCMix
    }

    var isLoading: Bool {
      isMakingCMix ||
      isRemovingCMix
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Button {
          viewStore.send(.makeCMix)
        } label: {
          HStack {
            Text(viewStore.hasStoredCMix ? "Load stored cMix" : "Create new cMix")
            Spacer()
            if viewStore.isMakingCMix {
              ProgressView()
            }
          }
        }

        if viewStore.hasStoredCMix {
          Button(role: .destructive) {
            viewStore.send(.removeStoredCMix)
          } label: {
            HStack {
              Text("Remove stored cMix")
              Spacer()
              if viewStore.isRemovingCMix {
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
