import ComposableArchitecture
import SwiftUI

public struct ResetAuthView: View {
  public init(store: Store<ResetAuthState, ResetAuthAction>) {
    self.store = store
  }

  let store: Store<ResetAuthState, ResetAuthAction>

  struct ViewState: Equatable {
    init(state: ResetAuthState) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Text("Unimplemented")
      }
      .navigationTitle("Reset auth")
    }
  }
}

#if DEBUG
public struct ResetAuthView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ResetAuthView(store: Store(
        initialState: ResetAuthState(
          partner: .unimplemented(Data())
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
