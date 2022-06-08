import ComposableArchitecture
import ComposablePresentation
import ElixxirDAppsSDK
import ErrorFeature
import MyIdentityFeature
import SwiftUI

public struct SessionView: View {
  public init(store: Store<SessionState, SessionAction>) {
    self.store = store
  }

  let store: Store<SessionState, SessionAction>

  struct ViewState: Equatable {
    let networkFollowerStatus: NetworkFollowerStatus?
    let isNetworkHealthy: Bool?

    init(state: SessionState) {
      networkFollowerStatus = state.networkFollowerStatus
      isNetworkHealthy = state.isNetworkHealthy
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Section {
          NetworkFollowerStatusView(status: viewStore.networkFollowerStatus)

          Button {
            viewStore.send(.runNetworkFollower(true))
          } label: {
            Text("Start")
          }
          .disabled(viewStore.networkFollowerStatus != .stopped)

          Button {
            viewStore.send(.runNetworkFollower(false))
          } label: {
            Text("Stop")
          }
          .disabled(viewStore.networkFollowerStatus != .running)
        } header: {
          Text("Network follower")
        }

        Section {
          NetworkHealthStatusView(status: viewStore.isNetworkHealthy)
        } header: {
          Text("Network health")
        }

        Section {
          Button {
            viewStore.send(.presentMyIdentity)
          } label: {
            HStack {
              Text("My identity")
              Spacer()
              Image(systemName: "chevron.forward")
            }
          }
        }
      }
      .navigationTitle("Session")
      .task {
        viewStore.send(.viewDidLoad)
      }
      .sheet(
        store.scope(
          state: \.error,
          action: SessionAction.error
        ),
        onDismiss: {
          viewStore.send(.didDismissError)
        },
        content: ErrorView.init(store:)
      )
      .background(
        NavigationLinkWithStore(
          store.scope(
            state: \.myIdentity,
            action: SessionAction.myIdentity
          ),
          onDeactivate: {
            viewStore.send(.didDismissMyIdentity)
          },
          destination: MyIdentityView.init(store:)
        )
      )
    }
  }
}

#if DEBUG
public struct SessionView_Previews: PreviewProvider {
  public static var previews: some View {
    SessionView(store: .init(
      initialState: .init(id: UUID()),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
