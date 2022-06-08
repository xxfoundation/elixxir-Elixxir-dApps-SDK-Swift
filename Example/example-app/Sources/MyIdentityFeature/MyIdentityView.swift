import ComposableArchitecture
import SwiftUI

public struct MyIdentityView: View {
  public init(store: Store<MyIdentityState, MyIdentityAction>) {
    self.store = store
  }

  let store: Store<MyIdentityState, MyIdentityAction>

  struct ViewState: Equatable {
    init(state: MyIdentityState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("MyIdentityView")
    }
  }
}

#if DEBUG
public struct MyIdentityView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      MyIdentityView(store: .init(
        initialState: .init(),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(.stack)
  }
}
#endif
