import ComposableArchitecture
import SwiftUI
import HomeFeature
import LaunchFeature

struct AppView: View {
  let store: Store<AppState, AppAction>

  enum ViewState: Equatable {
    case launch
    case home

    init(_ state: AppState) {
      switch state.screen {
      case .launch(_): self = .launch
      case .home(_): self = .home
      }
    }
  }

  var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      ZStack {
        SwitchStore(store.scope(state: \.screen)) {
          CaseLet(
            state: /AppState.Screen.launch,
            action: AppAction.launch,
            then: { store in
              LaunchView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
          )

          CaseLet(
            state: /AppState.Screen.home,
            action: AppAction.home,
            then: { store in
              HomeView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .opacity
                ))
            }
          )
        }
      }
      .animation(.default, value: viewStore.state)
    }
  }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
