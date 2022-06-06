import ComposableArchitecture
import SwiftUI

public struct SessionView: View {
  public init(store: Store<SessionState, SessionAction>) {
    self.store = store
  }

  let store: Store<SessionState, SessionAction>

  struct ViewState: Equatable {
    init(state: SessionState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("SessionView")
        .navigationTitle("Session")
        .task {
          viewStore.send(.viewDidLoad)
        }
    }
  }
}

#if DEBUG
public struct SessionView_Previews: PreviewProvider {
  public static var previews: some View {
    SessionView(store: .init(
      initialState: .init(id: UUID()),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
