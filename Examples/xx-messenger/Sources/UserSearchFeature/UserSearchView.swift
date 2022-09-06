import ComposableArchitecture
import SwiftUI

public struct UserSearchView: View {
  public init(store: Store<UserSearchState, UserSearchAction>) {
    self.store = store
  }

  let store: Store<UserSearchState, UserSearchAction>

  struct ViewState: Equatable {
    init(state: UserSearchState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("UserSearchView")
    }
  }
}

#if DEBUG
public struct UserSearchView_Previews: PreviewProvider {
  public static var previews: some View {
    UserSearchView(store: Store(
      initialState: UserSearchState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
