import AppCore
import ChatFeature
import CheckContactAuthFeature
import ComposableArchitecture
import ComposablePresentation
import ConfirmRequestFeature
import SendRequestFeature
import SwiftUI
import VerifyContactFeature
import XXClient
import XXModels

public struct ContactView: View {
  public init(store: Store<ContactState, ContactAction>) {
    self.store = store
  }

  let store: Store<ContactState, ContactAction>

  struct ViewState: Equatable {
    var dbContact: XXModels.Contact?
    var xxContactIsSet: Bool
    var xxContactUsername: String?
    var xxContactEmail: String?
    var xxContactPhone: String?
    var importUsername: Bool
    var importEmail: Bool
    var importPhone: Bool
    var canSendRequest: Bool
    var canVerifyContact: Bool
    var canConfirmRequest: Bool
    var canCheckAuthorization: Bool

    init(state: ContactState) {
      dbContact = state.dbContact
      xxContactIsSet = state.xxContact != nil
      xxContactUsername = try? state.xxContact?.getFact(.username)?.value
      xxContactEmail = try? state.xxContact?.getFact(.email)?.value
      xxContactPhone = try? state.xxContact?.getFact(.phone)?.value
      importUsername = state.importUsername
      importEmail = state.importEmail
      importPhone = state.importPhone
      canSendRequest = state.xxContact != nil || state.dbContact?.marshaled != nil
      canVerifyContact = state.dbContact?.marshaled != nil
      canConfirmRequest = state.dbContact?.marshaled != nil
      canCheckAuthorization = state.dbContact?.marshaled != nil
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        if viewStore.xxContactIsSet {
          Section {
            Button {
              viewStore.send(.set(\.$importUsername, !viewStore.importUsername))
            } label: {
              HStack {
                Label(viewStore.xxContactUsername ?? "", systemImage: "person")
                  .tint(Color.primary)
                Spacer()
                Image(systemName: viewStore.importUsername ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(.accentColor)
              }
            }

            Button {
              viewStore.send(.set(\.$importEmail, !viewStore.importEmail))
            } label: {
              HStack {
                Label(viewStore.xxContactEmail ?? "", systemImage: "envelope")
                  .tint(Color.primary)
                Spacer()
                Image(systemName: viewStore.importEmail ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(.accentColor)
              }
            }

            Button {
              viewStore.send(.set(\.$importPhone, !viewStore.importPhone))
            } label: {
              HStack {
                Label(viewStore.xxContactPhone ?? "", systemImage: "phone")
                  .tint(Color.primary)
                Spacer()
                Image(systemName: viewStore.importPhone ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(.accentColor)
              }
            }

            Button {
              viewStore.send(.importFactsTapped)
            } label: {
              HStack {
                if viewStore.dbContact == nil {
                  Text("Save contact")
                } else {
                  Text("Update contact")
                }
                Spacer()
                Image(systemName: "arrow.down")
              }
            }
          } header: {
            Text("Facts")
          }
        }

        if let dbContact = viewStore.dbContact {
          Section {
            Label(dbContact.id.hexString, systemImage: "number")
              .font(.footnote.monospaced())
            Label(dbContact.username ?? "", systemImage: "person")
            Label(dbContact.email ?? "", systemImage: "envelope")
            Label(dbContact.phone ?? "", systemImage: "phone")
          } header: {
            Text("Contact")
          }
          .textSelection(.enabled)

          Section {
            ContactAuthStatusView(dbContact.authStatus)

            Button {
              viewStore.send(.sendRequestTapped)
            } label: {
              HStack {
                Text("Send request")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
            .disabled(!viewStore.canSendRequest)

            Button {
              viewStore.send(.verifyContactTapped)
            } label: {
              HStack {
                Text("Verify contact")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
            .disabled(!viewStore.canVerifyContact)

            Button {
              viewStore.send(.confirmRequestTapped)
            } label: {
              HStack {
                Text("Confirm request")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
            .disabled(!viewStore.canConfirmRequest)

            Button {
              viewStore.send(.checkAuthTapped)
            } label: {
              HStack {
                Text("Check authorization")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
            .disabled(!viewStore.canCheckAuthorization)
          } header: {
            Text("Auth")
          }
          .animation(.default, value: viewStore.dbContact?.authStatus)

          Section {
            Button {
              viewStore.send(.chatTapped)
            } label: {
              HStack {
                Text("Chat")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
          } header: {
            Text("Chat")
          }
        }
      }
      .navigationTitle("Contact")
      .task { viewStore.send(.start) }
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.sendRequest,
          action: ContactAction.sendRequest
        ),
        mapState: replayNonNil(),
        onDeactivate: { viewStore.send(.sendRequestDismissed) },
        destination: SendRequestView.init(store:)
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.verifyContact,
          action: ContactAction.verifyContact
        ),
        onDeactivate: { viewStore.send(.verifyContactDismissed) },
        destination: VerifyContactView.init(store:)
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.confirmRequest,
          action: ContactAction.confirmRequest
        ),
        onDeactivate: { viewStore.send(.confirmRequestDismissed) },
        destination: ConfirmRequestView.init(store:)
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.checkAuth,
          action: ContactAction.checkAuth
        ),
        onDeactivate: { viewStore.send(.checkAuthDismissed) },
        destination: CheckContactAuthView.init(store:)
      ))
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.chat,
          action: ContactAction.chat
        ),
        onDeactivate: { viewStore.send(.chatDismissed) },
        destination: ChatView.init(store:)
      ))
    }
  }
}

#if DEBUG
public struct ContactView_Previews: PreviewProvider {
  public static var previews: some View {
    ContactView(store: Store(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
