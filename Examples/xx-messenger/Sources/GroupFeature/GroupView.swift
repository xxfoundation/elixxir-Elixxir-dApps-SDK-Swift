import AppCore
import ComposableArchitecture
import SwiftUI
import XXModels

public struct GroupView: View {
  public typealias Component = GroupComponent
  typealias ViewStore = ComposableArchitecture.ViewStore<ViewState, Component.Action>

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  let store: StoreOf<Component>

  struct ViewState: Equatable {
    init(state: Component.State) {
      group = state.group
    }

    var group: XXModels.Group
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section("Group name") {
          Text(viewStore.group.name)
        }
      }
      .navigationTitle("Group")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct GroupView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      GroupView(store: Store(
        initialState: GroupComponent.State(
          group: .init(
            id: "group-id".data(using: .utf8)!,
            name: "Preview group",
            leaderId: "group-leader-id".data(using: .utf8)!,
            createdAt: Date(timeIntervalSince1970: TimeInterval(86_400)),
            authStatus: .participating,
            serialized: "group-serialized".data(using: .utf8)!
          )
        ),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
