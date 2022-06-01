import ComposableArchitecture
import SwiftUI

public struct ErrorView: View {
  public init(store: Store<ErrorState, ErrorAction>) {
    self.store = store
  }

  let store: Store<ErrorState, ErrorAction>

  struct ViewState: Equatable {
    init(state: ErrorState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("ErrorView")
    }
  }
}

#if DEBUG
public struct ErrorView_Previews: PreviewProvider {
  public static var previews: some View {
    ErrorView(store: .init(
      initialState: .init(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
