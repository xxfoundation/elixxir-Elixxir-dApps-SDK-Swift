import ComposableArchitecture
import SwiftUI

public struct MyContactView: View {
  public init(store: Store<MyContactState, MyContactAction>) {
    self.store = store
  }

  let store: Store<MyContactState, MyContactAction>

  struct ViewState: Equatable {
    init(state: MyContactState) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {

      }
      .navigationTitle("My Contact")
    }
  }
}

#if DEBUG
public struct MyContactView_Previews: PreviewProvider {
  public static var previews: some View {
    MyContactView(store: Store(
      initialState: MyContactState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
