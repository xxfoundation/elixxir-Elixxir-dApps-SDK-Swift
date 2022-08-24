import ComposableArchitecture
import RegisterFeature
import RestoreFeature
import SwiftUI
import WelcomeFeature

public struct LaunchView: View {
  public init(store: Store<LaunchState, LaunchAction>) {
    self.store = store
  }

  struct ViewState: Equatable {
    enum Screen: Equatable {
      case loading
      case welcome
      case restore
      case register
      case failure(String)
    }

    init(_ state: LaunchState) {
      switch state.screen {
      case .loading: screen = .loading
      case .welcome(_): screen = .welcome
      case .restore(_): screen = .restore
      case .register(_): screen = .register
      case .failure(let failure): screen = .failure(failure)
      }
    }

    var screen: Screen
  }

  let store: Store<LaunchState, LaunchAction>

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      ZStack {
        switch viewStore.screen {
        case .loading:
          ProgressView {
            Text("Loading")
          }
          .controlSize(.large)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.opacity)

        case .welcome:
          IfLetStore(
            store.scope(
              state: { (/LaunchState.Screen.welcome).extract(from: $0.screen) },
              action: LaunchAction.welcome
            ),
            then: WelcomeView.init(store:)
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .opacity
          ))

        case .restore:
          IfLetStore(
            store.scope(
              state: { (/LaunchState.Screen.restore).extract(from: $0.screen) },
              action: LaunchAction.restore
            ),
            then: RestoreView.init(store:)
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .opacity
          ))

        case .register:
          IfLetStore(
            store.scope(
              state: { (/LaunchState.Screen.register).extract(from: $0.screen) },
              action: LaunchAction.register
            ),
            then: RegisterView.init(store:)
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .opacity
          ))

        case .failure(let failure):
          LaunchErrorView(
            failure: failure,
            onRetry: { viewStore.send(.start) }
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .opacity
          ))
        }
      }
      .animation(.default, value: viewStore.screen)
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct LaunchView_Previews: PreviewProvider {
  public static var previews: some View {
    LaunchView(store: Store(
      initialState: LaunchState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
