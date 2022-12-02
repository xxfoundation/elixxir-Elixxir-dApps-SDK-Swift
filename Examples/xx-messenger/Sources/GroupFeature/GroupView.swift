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
      info = state.groupInfo
    }

    var info: XXModels.GroupInfo?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        if let info = viewStore.info {
          Section("Name") {
            Text(info.group.name)
          }

          Section("Leader") {
            Label(info.leader.username ?? "", systemImage: "person.badge.shield.checkmark")
          }

          Section("Members") {
            ForEach(info.members.filter { $0 != info.leader }) { contact in
              Label(contact.username ?? "", systemImage: "person")
            }
          }

          Section("Status") {
            GroupAuthStatusView(info.group.authStatus)
          }
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
          groupId: "group-id".data(using: .utf8)!,
          groupInfo: .init(
            group: .init(
              id: "group-id".data(using: .utf8)!,
              name: "Preview group",
              leaderId: "group-leader-id".data(using: .utf8)!,
              createdAt: Date(timeIntervalSince1970: TimeInterval(86_400)),
              authStatus: .participating,
              serialized: "group-serialized".data(using: .utf8)!
            ),
            leader: .init(
              id: "group-leader-id".data(using: .utf8)!,
              username: "Group leader"
            ),
            members: [
              .init(
                id: "member-1-id".data(using: .utf8)!,
                username: "Member 1"
              ),
              .init(
                id: "member-2-id".data(using: .utf8)!,
                username: "Member 2"
              ),
            ]
          )
        ),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
