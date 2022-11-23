import ComposableArchitecture
import SwiftUI

public struct VerifyContactView: View {
  public init(store: StoreOf<VerifyContactComponent>) {
    self.store = store
  }

  let store: StoreOf<VerifyContactComponent>

  struct ViewState: Equatable {
    var username: String?
    var email: String?
    var phone: String?
    var isVerifying: Bool
    var result: VerifyContactComponent.State.Result?

    init(state: VerifyContactComponent.State) {
      username = try? state.contact.getFact(.username)?.value
      email = try? state.contact.getFact(.email)?.value
      phone = try? state.contact.getFact(.phone)?.value
      isVerifying = state.isVerifying
      result = state.result
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
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
            viewStore.send(.verifyTapped)
          } label: {
            HStack {
              Text("Verify")
              Spacer()
              if viewStore.isVerifying {
                ProgressView()
              } else {
                Image(systemName: "play")
              }
            }
          }
          .disabled(viewStore.isVerifying)
        }

        if let result = viewStore.result {
          Section {
            HStack {
              switch result {
              case .success(true):
                Text("Contact verified")
                Spacer()
                Image(systemName: "person.fill.checkmark")

              case .success(false):
                Text("Contact not verified")
                Spacer()
                Image(systemName: "person.fill.xmark")

              case .failure(_):
                Text("Verification failed")
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
      .navigationTitle("Verify Contact")
    }
  }
}

#if DEBUG
public struct VerifyContactView_Previews: PreviewProvider {
  public static var previews: some View {
    VerifyContactView(store: Store(
      initialState: VerifyContactComponent.State(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: EmptyReducer()
    ))
  }
}
#endif
