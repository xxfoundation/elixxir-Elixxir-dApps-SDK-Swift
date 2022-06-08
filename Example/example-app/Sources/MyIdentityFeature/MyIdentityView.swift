import ComposableArchitecture
import ComposablePresentation
import ElixxirDAppsSDK
import ErrorFeature
import SwiftUI

public struct MyIdentityView: View {
  public init(store: Store<MyIdentityState, MyIdentityAction>) {
    self.store = store
  }

  let store: Store<MyIdentityState, MyIdentityAction>

  struct ViewState: Equatable {
    let identity: Identity?
    let isMakingIdentity: Bool

    init(state: MyIdentityState) {
      identity = state.identity
      isMakingIdentity = state.isMakingIdentity
    }

    var isLoading: Bool {
      isMakingIdentity
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Section {
          Text(string(for: viewStore.identity))
            .textSelection(.enabled)
        }

        Section {
          Button {
            viewStore.send(.makeIdentity)
          } label: {
            HStack {
              Text("Make new identity")
              Spacer()
              if viewStore.isMakingIdentity {
                ProgressView()
              }
            }
          }
        }
        .disabled(viewStore.isLoading)
      }
      .navigationTitle("My identity")
      .navigationBarBackButtonHidden(viewStore.isLoading)
      .task {
        viewStore.send(.viewDidLoad)
      }
      .sheet(
        store.scope(
          state: \.error,
          action: MyIdentityAction.error
        ),
        onDismiss: {
          viewStore.send(.didDismissError)
        },
        content: ErrorView.init(store:)
      )
    }
  }

  func string(for identity: Identity?) -> String {
    guard let identity = identity else {
      return "No identity"
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    do {
      let data = try encoder.encode(identity)
      return String(data: data, encoding: .utf8) ?? "Decoding error"
    } catch {
      return "Decoding error: \(error)"
    }
  }
}

#if DEBUG
public struct MyIdentityView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      MyIdentityView(store: .init(
        initialState: .init(id: UUID()),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(.stack)
  }
}
#endif
