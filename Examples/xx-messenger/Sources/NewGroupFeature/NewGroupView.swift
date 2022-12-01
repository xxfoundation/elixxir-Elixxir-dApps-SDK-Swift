import AppCore
import ComposableArchitecture
import SwiftUI
import XXModels

public struct NewGroupView: View {
  public typealias Component = NewGroupComponent
  typealias ViewStore = ComposableArchitecture.ViewStore<ViewState, Component.Action>

  public init(store: StoreOf<Component>) {
    self.store = store
  }

  let store: StoreOf<Component>

  struct ViewState: Equatable {
    init(state: Component.State) {
      contacts = state.contacts
      members = state.members
    }

    var contacts: IdentifiedArrayOf<XXModels.Contact>
    var members: IdentifiedArrayOf<XXModels.Contact>
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          membersView(viewStore)
        }
      }
      .navigationTitle("New Group")
      .task { viewStore.send(.start) }
    }
  }

  func membersView(_ viewStore: ViewStore) -> some View {
    NavigationLink("Members (\(viewStore.members.count))") {
      Form {
        ForEach(viewStore.contacts) { contact in
          Button {
            viewStore.send(.didSelectContact(contact))
          } label: {
            HStack {
              Text(contact.username ?? "")
              Spacer()
              if viewStore.members.contains(contact) {
                Image(systemName: "checkmark")
              }
            }
          }
        }
      }
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
