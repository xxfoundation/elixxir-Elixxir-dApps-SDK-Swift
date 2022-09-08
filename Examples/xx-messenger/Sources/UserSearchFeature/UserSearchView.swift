import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import SwiftUI
import XXMessengerClient

public struct UserSearchView: View {
  public init(store: Store<UserSearchState, UserSearchAction>) {
    self.store = store
  }

  let store: Store<UserSearchState, UserSearchAction>
  @FocusState var focusedField: UserSearchState.Field?

  struct ViewState: Equatable {
    var focusedField: UserSearchState.Field?
    var query: MessengerSearchUsers.Query
    var isSearching: Bool
    var failure: String?
    var results: IdentifiedArrayOf<UserSearchState.Result>

    init(state: UserSearchState) {
      focusedField = state.focusedField
      query = state.query
      isSearching = state.isSearching
      failure = state.failure
      results = state.results
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          TextField(
            text: viewStore.binding(
              get: { $0.query.username ?? "" },
              send: { UserSearchAction.set(\.$query.username, $0.isEmpty ? nil : $0) }
            ),
            prompt: Text("Enter username"),
            label: { Text("Username") }
          )
          .focused($focusedField, equals: .username)

          TextField(
            text: viewStore.binding(
              get: { $0.query.email ?? "" },
              send: { UserSearchAction.set(\.$query.email, $0.isEmpty ? nil : $0) }
            ),
            prompt: Text("Enter email"),
            label: { Text("Email") }
          )
          .focused($focusedField, equals: .email)

          TextField(
            text: viewStore.binding(
              get: { $0.query.phone ?? "" },
              send: { UserSearchAction.set(\.$query.phone, $0.isEmpty ? nil : $0) }
            ),
            prompt: Text("Enter phone"),
            label: { Text("Phone") }
          )
          .focused($focusedField, equals: .phone)

          Button {
            viewStore.send(.searchTapped)
          } label: {
            HStack {
              Text("Search")
              Spacer()
              if viewStore.isSearching {
                ProgressView()
              } else {
                Image(systemName: "magnifyingglass")
              }
            }
          }
          .disabled(viewStore.query.isEmpty)
        }
        .disabled(viewStore.isSearching)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)

        if let failure = viewStore.failure {
          Section {
            Text(failure)
          } header: {
            Text("Error")
          }
        }

        ForEach(viewStore.results) { result in
          Section {
            Button {
              viewStore.send(.resultTapped(id: result.id))
            } label: {
              HStack {
                VStack {
                  if result.hasFacts {
                    if let username = result.username {
                      Label(username, systemImage: "person")
                    }
                    if let email = result.email {
                      Label(email, systemImage: "envelope")
                    }
                    if let phone = result.phone {
                      Label(phone, systemImage: "phone")
                    }
                  } else {
                    Label("No facts", systemImage: "questionmark")
                  }
                }
                .tint(Color.primary)
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
          }
        }
      }
      .onChange(of: viewStore.focusedField) { focusedField = $0 }
      .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
      .navigationTitle("User Search")
      .background(NavigationLinkWithStore(
        store.scope(
          state: \.contact,
          action: UserSearchAction.contact
        ),
        onDeactivate: { viewStore.send(.didDismissContact) },
        destination: ContactView.init(store:)
      ))
    }
  }
}

#if DEBUG
public struct UserSearchView_Previews: PreviewProvider {
  public static var previews: some View {
    UserSearchView(store: Store(
      initialState: UserSearchState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
