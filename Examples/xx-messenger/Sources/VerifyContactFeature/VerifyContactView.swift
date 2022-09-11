import ComposableArchitecture
import SwiftUI

public struct VerifyContactView: View {
  public init(store: Store<VerifyContactState, VerifyContactAction>) {
    self.store = store
  }

  let store: Store<VerifyContactState, VerifyContactAction>

  struct ViewState: Equatable {
    init(state: VerifyContactState) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {

      }
      .navigationTitle("Verify Contact")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct VerifyContactView_Previews: PreviewProvider {
  public static var previews: some View {
    VerifyContactView(store: Store(
      initialState: VerifyContactState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
