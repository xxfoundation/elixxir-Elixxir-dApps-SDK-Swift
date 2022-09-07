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
        Section {
          if let dbContact = viewStore.dbContact {
            Label(dbContact.username ?? "", systemImage: "person")
            Label(dbContact.email ?? "", systemImage: "envelope")
            Label(dbContact.phone ?? "", systemImage: "phone")
          } else {
            Text("Contact not saved locally")
          }
        } header: {
          Text("Local data")
        }

        Section {
          Label(viewStore.xxContact?.username ?? "", systemImage: "person")
          Label(viewStore.xxContact?.email ?? "", systemImage: "envelope")
          Label(viewStore.xxContact?.phone ?? "", systemImage: "phone")
        } header: {
          Text("Facts")
        }

        Section {
          switch viewStore.dbContact?.authStatus {
          case .none, .stranger:
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
        } header: {
          Text("Auth status")
        }
      }
      .navigationTitle("Contact")
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
