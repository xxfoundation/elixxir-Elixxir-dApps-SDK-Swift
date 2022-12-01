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
  @FocusState var focusedField: Component.State.Field?

  struct ViewState: Equatable {
    init(state: Component.State) {
      contacts = state.contacts
      members = state.members
      name = state.name
      focusedField = state.focusedField
    }

    var contacts: IdentifiedArrayOf<XXModels.Contact>
    var members: IdentifiedArrayOf<XXModels.Contact>
    var name: String
    var focusedField: Component.State.Field?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          membersView(viewStore)
          nameView(viewStore)
        }
      }
      .navigationTitle("New Group")
      .task { viewStore.send(.start) }
      .onChange(of: viewStore.focusedField) { focusedField = $0 }
      .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
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

  func nameView(_ viewStore: ViewStore) -> some View {
    TextField("Group name", text: viewStore.binding(
      get: \.name,
      send: { .set(\.$name, $0) }
    ))
    .focused($focusedField, equals: .name)
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
