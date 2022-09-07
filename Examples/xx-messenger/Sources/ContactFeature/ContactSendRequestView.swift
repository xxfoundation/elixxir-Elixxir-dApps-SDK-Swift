import ComposableArchitecture
import SwiftUI

public struct ContactSendRequestView: View {
  public init(store: Store<ContactSendRequestState, ContactSendRequestAction>) {
    self.store = store
  }

  let store: Store<ContactSendRequestState, ContactSendRequestAction>

  struct ViewState: Equatable {
    init(state: ContactSendRequestState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {

      }
      .navigationTitle("Send Request")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct ContactSendRequestView_Previews: PreviewProvider {
  public static var previews: some View {
    ContactSendRequestView(store: Store(
      initialState: ContactSendRequestState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
