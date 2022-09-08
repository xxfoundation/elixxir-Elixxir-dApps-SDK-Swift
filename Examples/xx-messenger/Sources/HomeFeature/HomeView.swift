import ComposableArchitecture
import ComposablePresentation
import ContactsFeature
import RegisterFeature
import SwiftUI
import UserSearchFeature
import XXClient

public struct HomeView: View {
  public init(store: Store<HomeState, HomeAction>) {
    self.store = store
  }

  let store: Store<HomeState, HomeAction>

  struct ViewState: Equatable {
    var failure: String?
    var isNetworkHealthy: Bool?
    var networkNodesReport: NodeRegistrationReport?
    var isDeletingAccount: Bool

    init(state: HomeState) {
      failure = state.failure
      isNetworkHealthy = state.isNetworkHealthy
      isDeletingAccount = state.isDeletingAccount
      networkNodesReport = state.networkNodesReport
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {
          Section {
            if let failure = viewStore.failure {
              Text(failure)
              Button {
                viewStore.send(.messenger(.start))
              } label: {
                Text("Retry")
              }
            }
          } header: {
            if viewStore.failure != nil {
              Text("Error")
            }
          }

          Section {
            HStack {
              Text("Health")
              Spacer()
              switch viewStore.isNetworkHealthy {
              case .some(true):
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)

              case .some(false):
                Image(systemName: "xmark.diamond.fill")
                  .foregroundColor(.red)

              case .none:
                Image(systemName: "questionmark.circle")
                  .foregroundColor(.gray)
              }
            }

            ProgressView(
              value: viewStore.networkNodesReport?.ratio ?? 0,
              label: {
                Text("Node registration")
              },
              currentValueLabel: {
                if let report = viewStore.networkNodesReport {
                  HStack {
                    Text("\(Int((report.ratio * 100).rounded(.down)))%")
                    Spacer()
                    Text("\(report.registered) / \(report.total)")
                  }
                } else {
                  Text("Unknown")
                }
              }
            )
            .tint((viewStore.networkNodesReport?.ratio ?? 0) >= 0.8 ? .green : .orange)
            .animation(.default, value: viewStore.networkNodesReport?.ratio)
          } header: {
            Text("Network")
          }

          Section {
            Button {
              viewStore.send(.contactsButtonTapped)
            } label: {
              HStack {
                Text("Contacts")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }

            Button {
              viewStore.send(.userSearchButtonTapped)
            } label: {
              HStack {
                Text("Search users")
                Spacer()
                Image(systemName: "chevron.forward")
              }
            }
          } header: {
            Text("Contacts")
          }

          Section {
            Button(role: .destructive) {
              viewStore.send(.deleteAccount(.buttonTapped))
            } label: {
              HStack {
                Text("Delete Account")
                Spacer()
                if viewStore.isDeletingAccount {
                  ProgressView()
                }
              }
            }
            .disabled(viewStore.isDeletingAccount)
          } header: {
            Text("Account")
          }
        }
        .navigationTitle("Home")
        .alert(
          store.scope(state: \.alert),
          dismiss: HomeAction.didDismissAlert
        )
        .background(NavigationLinkWithStore(
          store.scope(
            state: \.contacts,
            action: HomeAction.contacts
          ),
          onDeactivate: {
            viewStore.send(.didDismissContacts)
          },
          destination: ContactsView.init(store:)
        ))
        .background(NavigationLinkWithStore(
          store.scope(
            state: \.userSearch,
            action: HomeAction.userSearch
          ),
          onDeactivate: {
            viewStore.send(.didDismissUserSearch)
          },
          destination: UserSearchView.init(store:)
        ))
      }
      .navigationViewStyle(.stack)
      .task { viewStore.send(.messenger(.start)) }
      .fullScreenCover(
        store.scope(
          state: \.register,
          action: HomeAction.register
        ),
        onDismiss: {
          viewStore.send(.didDismissRegister)
        },
        content: RegisterView.init(store:)
      )
    }
  }
}

#if DEBUG
public struct HomeView_Previews: PreviewProvider {
  public static var previews: some View {
    HomeView(store: Store(
      initialState: HomeState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
