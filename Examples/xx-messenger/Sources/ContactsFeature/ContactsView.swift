import AppCore
import ComposableArchitecture
import SwiftUI
import XXModels

public struct ContactsView: View {
  public init(store: Store<ContactsState, ContactsAction>) {
    self.store = store
  }

  let store: Store<ContactsState, ContactsAction>

  struct ViewState: Equatable {
    var contacts: IdentifiedArrayOf<XXModels.Contact>

    init(state: ContactsState) {
      contacts = state.contacts
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        ForEach(viewStore.contacts) { contact in
          Section {
            Button {
              // TODO:
            } label: {
              HStack {
                VStack(alignment: .leading, spacing: 8) {
                  Label(contact.username ?? "", systemImage: "person")
                  Label(contact.email ?? "", systemImage: "envelope")
                  Label(contact.phone ?? "", systemImage: "phone")
                }
                .font(.callout)
                .tint(Color.primary)
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
            ContactAuthStatusView(contact.authStatus)
          }
        }
      }
      .navigationTitle("Contacts")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct ContactsView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ContactsView(store: Store(
        initialState: ContactsState(
          contacts: [
            .init(
              id: "1".data(using: .utf8)!,
              username: "John Doe",
              email: "john@doe.com",
              phone: "+1234567890",
              authStatus: .friend
            ),
            .init(
              id: "2".data(using: .utf8)!,
              username: "Alice Unknown",
              authStatus: .requested
            ),
            .init(
              id: "3".data(using: .utf8)!
            ),
          ]
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
