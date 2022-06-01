import ComposableArchitecture
import SwiftUI

public struct LandingView: View {
  public init(store: Store<LandingState, LandingAction>) {
    self.store = store
  }

  let store: Store<LandingState, LandingAction>

  struct ViewState: Equatable {
    init(state: LandingState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("LandingView")
        .task {
          viewStore.send(.viewDidLoad)
        }
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
