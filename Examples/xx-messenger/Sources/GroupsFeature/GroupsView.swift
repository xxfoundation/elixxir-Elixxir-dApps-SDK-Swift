import ComposableArchitecture
import SwiftUI

public struct GroupsView: View {
  public typealias Component = GroupsComponent

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  let store: StoreOf<Component>

  struct ViewState: Equatable {
    init(state: Component.State) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {

      }
      .navigationTitle("Groups")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct GroupsView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      GroupsView(store: Store(
        initialState: GroupsComponent.State(),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
