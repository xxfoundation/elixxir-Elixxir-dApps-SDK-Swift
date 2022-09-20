import AppCore
import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import MyContactFeature
import SwiftUI
import XXModels

public struct ContactsView: View {
  public init(store: Store<ContactsState, ContactsAction>) {
    self.store = store
  }

  let store: Store<ContactsState, ContactsAction>

  struct ViewState: Equatable {
    var myId: Data?
    var contacts: IdentifiedArrayOf<XXModels.Contact>

    init(state: ContactsState) {
      myId = state.myId
      contacts = state.contacts
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        ForEach(viewStore.contacts) { contact in
          if contact.id == viewStore.myId {
            Section {
              Button {
                viewStore.send(.myContactSelected)
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
            } header: {
              Text("My contact")
            }
          } else {
            Section {
              Button {
                viewStore.send(.contactSelected(contact))
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
      }
      .navigationTitle("Contacts")
      .task { viewStore.send(.start) }
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.contact,
          action: ContactsAction.contact
        ),
        onDeactivate: { viewStore.send(.contactDismissed) },
        destination: ContactView.init(store:)
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.myContact,
          action: ContactsAction.myContact
        ),
        onDeactivate: { viewStore.send(.myContactDismissed) },
        destination: MyContactView.init(store:)
      ))
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
