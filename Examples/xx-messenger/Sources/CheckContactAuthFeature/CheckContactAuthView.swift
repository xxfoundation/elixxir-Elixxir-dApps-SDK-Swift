import ComposableArchitecture
import SwiftUI
import XXClient

public struct CheckContactAuthView: View {
  public init(store: Store<CheckContactAuthState, CheckContactAuthAction>) {
    self.store = store
  }

  let store: Store<CheckContactAuthState, CheckContactAuthAction>

  struct ViewState: Equatable {
    var username: String?
    var email: String?
    var phone: String?
    var isChecking: Bool
    var result: CheckContactAuthState.Result?

    init(state: CheckContactAuthState) {
      username = try? state.contact.getFact(.username)?.value
      email = try? state.contact.getFact(.email)?.value
      phone = try? state.contact.getFact(.phone)?.value
      isChecking = state.isChecking
      result = state.result
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Section {
          Label(viewStore.username ?? "", systemImage: "person")
          Label(viewStore.email ?? "", systemImage: "envelope")
          Label(viewStore.phone ?? "", systemImage: "phone")
        } header: {
          Text("Facts")
        }

        Section {
          Button {
            viewStore.send(.checkTapped)
          } label: {
            HStack {
              Text("Check")
              Spacer()
              if viewStore.isChecking {
                ProgressView()
              } else {
                Image(systemName: "play")
              }
            }
          }
          .disabled(viewStore.isChecking)
        }

        if let result = viewStore.result {
          Section {
            HStack {
              switch result {
              case .success(true):
                Text("Authorized")
                Spacer()
                Image(systemName: "person.fill.checkmark")

              case .success(false):
                Text("Not authorized")
                Spacer()
                Image(systemName: "person.fill.xmark")

              case .failure(_):
                Text("Checking status failed")
                Spacer()
                Image(systemName: "xmark")
              }
            }
            if case .failure(let failure) = result {
              Text(failure)
            }
          } header: {
            Text("Result")
          }
        }
      }
      .navigationTitle("Check connection")
    }
  }
}

#if DEBUG
public struct CheckContactAuthView_Previews: PreviewProvider {
  public static var previews: some View {
    CheckContactAuthView(store: Store(
      initialState: CheckContactAuthState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
