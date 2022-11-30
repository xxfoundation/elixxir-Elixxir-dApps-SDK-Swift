import AppCore
import ComposableArchitecture
import ComposablePresentation
import NewGroupFeature
import SwiftUI
import XXModels

public struct GroupsView: View {
  public typealias Component = GroupsComponent

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  let store: StoreOf<Component>

  struct ViewState: Equatable {
    init(state: Component.State) {}

    var groups: IdentifiedArrayOf<XXModels.Group> = []
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        newGroupButton {
          viewStore.send(.newGroupButtonTapped)
        }

        ForEach(viewStore.groups) { group in
          groupView(group) {
            viewStore.send(.didSelectGroup(group))
          }
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
      .task { viewStore.send(.start) }
    }
  }

  func newGroupButton(action: @escaping () -> Void) -> some View {
    Section {
      Button {
        action()
      } label: {
        HStack {
          Text("New Group")
          Spacer()
          Image(systemName: "chevron.forward")
        }
      }
    }
  }

  func groupView(
    _ group: XXModels.Group,
    onSelect: @escaping () -> Void
  ) -> some View {
    Section {
      Button {
        onSelect()
      } label: {
        HStack {
          Label(group.name, systemImage: "person.3")
            .font(.callout)
            .tint(Color.primary)
          Spacer()
          Image(systemName: "chevron.forward")
        }
        GroupAuthStatusView(group.authStatus)
      }
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
