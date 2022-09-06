import ComposableArchitecture
import SwiftUI
import XXModels

public struct UserSearchResultView: View {
  public init(store: Store<UserSearchResultState, UserSearchResultAction>) {
    self.store = store
  }

  let store: Store<UserSearchResultState, UserSearchResultAction>

  struct ViewState: Equatable {
    var username: String?
    var email: String?
    var phone: String?
    var dbContactAuth: XXModels.Contact.AuthStatus?

    init(state: UserSearchResultState) {
      username = state.username
      email = state.email
      phone = state.phone
      dbContactAuth = state.dbContact?.authStatus
    }

    var isEmpty: Bool {
      username == nil && email == nil && phone == nil
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Section {
        if viewStore.isEmpty {
          Image(systemName: "questionmark")
            .frame(maxWidth: .infinity)
        } else {
          if let username = viewStore.username {
            Text(username)
          }
          if let email = viewStore.email {
            Text(email)
          }
          if let phone = viewStore.phone {
            Text(phone)
          }
        }
        switch viewStore.dbContactAuth {
        case .none, .stranger:
          Button {
            viewStore.send(.sendRequestButtonTapped)
          } label: {
            HStack {
              Text("Send request")
              Spacer()
              Image(systemName: "person.badge.plus")
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
      }
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct UserSearchResultView_Previews: PreviewProvider {
  public static var previews: some View {
    UserSearchResultView(store: Store(
      initialState: UserSearchResultState(
        id: "contact-id".data(using: .utf8)!,
        xxContact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
