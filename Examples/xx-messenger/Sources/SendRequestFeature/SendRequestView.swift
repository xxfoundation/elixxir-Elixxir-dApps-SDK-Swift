import ComposableArchitecture
import SwiftUI

public struct SendRequestView: View {
  public init(store: Store<SendRequestState, SendRequestAction>) {
    self.store = store
  }

  let store: Store<SendRequestState, SendRequestAction>

  struct ViewState: Equatable {
    init(state: SendRequestState) {}
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
public struct SendRequestView_Previews: PreviewProvider {
  public static var previews: some View {
    SendRequestView(store: Store(
      initialState: SendRequestState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
