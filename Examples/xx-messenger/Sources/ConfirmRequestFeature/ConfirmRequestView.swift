import ComposableArchitecture
import SwiftUI

public struct ConfirmRequestView: View {
  public init(store: StoreOf<ConfirmRequestComponent>) {
    self.store = store
  }

  let store: StoreOf<ConfirmRequestComponent>

  struct ViewState: Equatable {
    var username: String?
    var email: String?
    var phone: String?
    var isConfirming: Bool
    var result: ConfirmRequestComponent.State.Result?

    init(state: ConfirmRequestComponent.State) {
      username = try? state.contact.getFact(.username)?.value
      email = try? state.contact.getFact(.email)?.value
      phone = try? state.contact.getFact(.phone)?.value
      isConfirming = state.isConfirming
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
            viewStore.send(.confirmTapped)
          } label: {
            HStack {
              Text("Confirm")
              Spacer()
              if viewStore.isConfirming {
                ProgressView()
              } else {
                Image(systemName: "checkmark")
              }
            }
          }
          .disabled(viewStore.isConfirming)
        }

        if let result = viewStore.result {
          Section {
            HStack {
              switch result {
              case .success:
                Text("Request confirmed")
                Spacer()
                Image(systemName: "person.fill.checkmark")

              case .failure(_):
                Text("Confirming request failed")
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
      .navigationTitle("Confirm request")
    }
  }
}

#if DEBUG
public struct ConfirmRequestView_Previews: PreviewProvider {
  public static var previews: some View {
    ConfirmRequestView(store: Store(
      initialState: ConfirmRequestComponent.State(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: EmptyReducer()
    ))
  }
}
#endif
