import ComposableArchitecture
import SwiftUI

public struct ChatView: View {
  public init(store: Store<ChatState, ChatAction>) {
    self.store = store
  }

  let store: Store<ChatState, ChatAction>

  struct ViewState: Equatable {
    init(state: ChatState) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Text("ChatView")
        .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct ChatView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ChatView(store: Store(
        initialState: ChatState(
          id: .contact("contact-id".data(using: .utf8)!)
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
