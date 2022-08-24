import ComposableArchitecture
import SwiftUI

public struct HomeView: View {
  public init(store: Store<HomeState, HomeAction>) {
    self.store = store
  }

  let store: Store<HomeState, HomeAction>

  struct ViewState: Equatable {
    init(state: HomeState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {

        }
        .navigationTitle("Home")
      }
      .navigationViewStyle(.stack)
      .task { viewStore.send(.start) }
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
