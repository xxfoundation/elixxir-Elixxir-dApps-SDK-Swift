import AppCore
import ComposableArchitecture
import SwiftUI
import XXModels

public struct NewGroupView: View {
  public typealias Component = NewGroupComponent

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
      .navigationTitle("New Group")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct NewGroupView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      NewGroupView(store: Store(
        initialState: NewGroupComponent.State(),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
