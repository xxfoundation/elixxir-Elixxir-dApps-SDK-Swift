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
      message = state.message
      focusedField = state.focusedField
      isCreating = state.isCreating
      failure = state.failure
    }

    var contacts: IdentifiedArrayOf<XXModels.Contact>
    var members: IdentifiedArrayOf<XXModels.Contact>
    var name: String
    var message: String
    var focusedField: Component.State.Field?
    var isCreating: Bool
    var failure: String?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          membersView(viewStore)
          nameView(viewStore)
          messageView(viewStore)
        }
        Section {
          createButton(viewStore)
          if let failure = viewStore.failure {
            Text(failure)
          }
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
    .disabled(viewStore.isCreating)
  }

  func nameView(_ viewStore: ViewStore) -> some View {
    TextField("Group name", text: viewStore.binding(
      get: \.name,
      send: { .set(\.$name, $0) }
    ))
    .focused($focusedField, equals: .name)
    .disabled(viewStore.isCreating)
  }

  func messageView(_ viewStore: ViewStore) -> some View {
    TextField("Initial message", text: viewStore.binding(
      get: \.message,
      send: { .set(\.$message, $0) }
    ))
    .focused($focusedField, equals: .message)
    .disabled(viewStore.isCreating)
  }

  func createButton(_ viewStore: ViewStore) -> some View {
    Button {
      viewStore.send(.createButtonTapped)
    } label: {
      HStack {
        Text("Create group")
        Spacer()
        if viewStore.isCreating {
          ProgressView()
        } else {
          Image(systemName: "play.fill")
        }
      }
    }
    .disabled(viewStore.isCreating)
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
