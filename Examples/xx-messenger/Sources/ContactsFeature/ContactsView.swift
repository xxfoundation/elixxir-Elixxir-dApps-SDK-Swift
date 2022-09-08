import ComposableArchitecture
import SwiftUI

public struct ContactsView: View {
  public init(store: Store<ContactsState, ContactsAction>) {
    self.store = store
  }

  let store: Store<ContactsState, ContactsAction>

  struct ViewState: Equatable {
    init(state: ContactsState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {

      }
      .navigationTitle("Contacts")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct ContactsView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ContactsView(store: Store(
        initialState: ContactsState(),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
