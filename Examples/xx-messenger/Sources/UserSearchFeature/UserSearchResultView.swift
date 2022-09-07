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

    init(state: UserSearchResultState) {
      username = state.username
      email = state.email
      phone = state.phone
    }

    var isEmpty: Bool {
      username == nil && email == nil && phone == nil
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Section {
        Button {
          viewStore.send(.tapped)
        } label: {
          HStack {
            VStack {
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
            }
            Spacer()
            Image(systemName: "chevron.forward")
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
