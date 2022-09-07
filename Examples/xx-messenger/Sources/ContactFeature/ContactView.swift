import ComposableArchitecture
import SwiftUI

public struct ContactView: View {
  public init(store: Store<ContactState, ContactAction>) {
    self.store = store
  }

  let store: Store<ContactState, ContactAction>

  struct ViewState: Equatable {
    init(state: ContactState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {

      }
      .navigationTitle("Contact")
    }
  }
}

#if DEBUG
public struct ContactView_Previews: PreviewProvider {
  public static var previews: some View {
    ContactView(store: Store(
      initialState: ContactState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
