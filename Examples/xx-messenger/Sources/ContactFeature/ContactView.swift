import AppCore
import ComposableArchitecture
import ComposablePresentation
import SendRequestFeature
import SwiftUI
import XXClient
import XXModels

public struct ContactView: View {
  public init(store: Store<ContactState, ContactAction>) {
    self.store = store
  }

  let store: Store<ContactState, ContactAction>

  struct ViewState: Equatable {
    var dbContact: XXModels.Contact?
    var xxContact: XXClient.Contact?
    var importUsername: Bool
    var importEmail: Bool
    var importPhone: Bool

    init(state: ContactState) {
      dbContact = state.dbContact
      xxContact = state.xxContact
      importUsername = state.importUsername
      importEmail = state.importEmail
      importPhone = state.importPhone
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        if let xxContact = viewStore.xxContact {
          Section {
            Button {
              viewStore.send(.set(\.$importUsername, !viewStore.importUsername))
            } label: {
              HStack {
                Label(xxContact.username ?? "", systemImage: "person")
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
                Label(xxContact.email ?? "", systemImage: "envelope")
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
                Label(xxContact.phone ?? "", systemImage: "phone")
                  .tint(Color.primary)
                Spacer()
                Image(systemName: viewStore.importPhone ? "checkmark.circle.fill" : "circle")
                  .foregroundColor(.accentColor)
              }
            }

            Button {
              viewStore.send(.importFactsTapped)
            } label: {
              if viewStore.dbContact == nil {
                Text("Save contact")
              } else {
                Text("Update contact")
              }
            }
          } header: {
            Text("Facts")
          }
        }

        if let dbContact = viewStore.dbContact {
          Section {
            Label(dbContact.username ?? "", systemImage: "person")
            Label(dbContact.email ?? "", systemImage: "envelope")
            Label(dbContact.phone ?? "", systemImage: "phone")
          } header: {
            Text("Contact")
          }

          Section {
            switch dbContact.authStatus {
            case .stranger:
              HStack {
                Text("Stranger")
                Spacer()
                Image(systemName: "person.fill.questionmark")
              }

            case .requesting:
              HStack {
                Text("Sending auth request")
                Spacer()
                ProgressView()
              }

            case .requested:
              HStack {
                Text("Request sent")
                Spacer()
                Image(systemName: "paperplane")
              }

            case .requestFailed:
              HStack {
                Text("Sending request failed")
                Spacer()
                Image(systemName: "xmark.diamond.fill")
                  .foregroundColor(.red)
              }

            case .verificationInProgress:
              HStack {
                Text("Verification is progress")
                Spacer()
                ProgressView()
              }

            case .verified:
              HStack {
                Text("Verified")
                Spacer()
                Image(systemName: "person.fill.checkmark")
              }

            case .verificationFailed:
              HStack {
                Text("Verification failed")
                Spacer()
                Image(systemName: "xmark.diamond.fill")
                  .foregroundColor(.red)
              }

            case .confirming:
              HStack {
                Text("Confirming auth request")
                Spacer()
                ProgressView()
              }

            case .confirmationFailed:
              HStack {
                Text("Confirmation failed")
                Spacer()
                Image(systemName: "xmark.diamond.fill")
                  .foregroundColor(.red)
              }

            case .friend:
              HStack {
                Text("Friend")
                Spacer()
                Image(systemName: "person.fill.checkmark")
              }

            case .hidden:
              HStack {
                Text("Hidden")
                Spacer()
                Image(systemName: "eye.slash")
              }
            }
            Button {
              viewStore.send(.sendRequestTapped)
            } label: {
              HStack {
                Text("Send request")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
          } header: {
            Text("Auth")
          }
          .animation(.default, value: viewStore.dbContact?.authStatus)
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
