import AppCore
import ComposableArchitecture
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

    init(state: ContactState) {
      dbContact = state.dbContact
      xxContact = state.xxContact
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        if let xxContact = viewStore.xxContact {
          Section {
            Label(xxContact.username ?? "", systemImage: "person")
            Label(xxContact.email ?? "", systemImage: "envelope")
            Label(xxContact.phone ?? "", systemImage: "phone")
            Button {
              viewStore.send(.saveFactsTapped)
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
              Button {
                viewStore.send(.sendRequestTapped)
              } label: {
                HStack {
                  Text("Send request")
                  Spacer()
                  Image(systemName: "chevron.forward")
                }
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
                Image(systemName: "chevron.forward")
              }

            case .requestFailed:
              HStack {
                Text("Sending request failed")
                Spacer()
                Image(systemName: "xmark.diamond.fill")
                  .foregroundColor(.red)
              }
              Button {
                viewStore.send(.sendRequestTapped)
              } label: {
                HStack {
                  Text("Resend request")
                  Spacer()
                  Image(systemName: "paperplane")
                }
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
          } header: {
            Text("Auth status")
          }
          .animation(.default, value: viewStore.dbContact?.authStatus)
        }
      }
      .navigationTitle("Contact")
      .task { viewStore.send(.start) }
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
