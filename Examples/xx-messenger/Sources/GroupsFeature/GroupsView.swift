import AppCore
import ComposableArchitecture
import ComposablePresentation
import GroupFeature
import NewGroupFeature
import SwiftUI
import XXModels

public struct GroupsView: View {
  public typealias Component = GroupsComponent
  typealias ViewStore = ComposableArchitecture.ViewStore<ViewState, Component.Action>

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  let store: StoreOf<Component>

  struct ViewState: Equatable {
    init(state: Component.State) {
      groups = state.groups
    }

    var groups: IdentifiedArrayOf<XXModels.Group>
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        newGroupButton(viewStore)

        ForEach(viewStore.groups) { group in
          groupView(group, viewStore)
        }
      }
      .navigationTitle("Groups")
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.newGroup,
          action: Component.Action.newGroup
        ),
        onDeactivate: { viewStore.send(.newGroupDismissed) },
        destination: NewGroupView.init
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.group,
          action: Component.Action.group
        ),
        onDeactivate: { viewStore.send(.didDismissGroup) },
        destination: GroupView.init
      ))
      .task { viewStore.send(.start) }
    }
  }

  func newGroupButton(_ viewStore: ViewStore) -> some View {
    Section {
      Button {
        viewStore.send(.newGroupButtonTapped)
      } label: {
        HStack {
          Text("New Group")
          Spacer()
          Image(systemName: "chevron.forward")
        }
      }
    }
  }

  func groupView(_ group: XXModels.Group, _ viewStore: ViewStore) -> some View {
    Section {
      Button {
        viewStore.send(.didSelectGroup(group))
      } label: {
        HStack {
          Label(group.name, systemImage: "person.3")
            .font(.callout)
            .tint(Color.primary)
          Spacer()
          Image(systemName: "chevron.forward")
        }
      }
      GroupAuthStatusView(group.authStatus)
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
