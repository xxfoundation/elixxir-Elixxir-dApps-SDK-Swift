import ComposableArchitecture
import LandingFeature
import SessionFeature
import SwiftUI

struct AppView: View {
  let store: Store<AppState, AppAction>

  struct ViewState: Equatable {
    enum Scene: Equatable {
      case landing
      case session
    }

    let scene: Scene

    init(state: AppState) {
      switch state.scene {
      case .landing(_):
        self.scene = .landing

      case .session(_):
        self.scene = .session
      }
    }
  }

  var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      ZStack {
        SwitchStore(store.scope(state: \.scene)) {
          CaseLet(
            state: /AppState.Scene.landing,
            action: AppAction.landing,
            then: { store in
              NavigationView {
                LandingView(store: store)
              }
              .navigationViewStyle(.stack)
              .transition(.asymmetric(
                insertion: .move(edge: .leading),
                removal: .opacity
              ))
            }
          )

          CaseLet(
            state: /AppState.Scene.session,
            action: AppAction.session,
            then: { store in
              NavigationView {
                SessionView(store: store)
              }
              .navigationViewStyle(.stack)
              .transition(.asymmetric(
                insertion: .move(edge: .trailing),
                removal: .opacity
              ))
            }
          )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .animation(.default, value: viewStore.scene)
      .task {
        viewStore.send(.viewDidLoad)
      }
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
