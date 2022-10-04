import AppCore
import ComposableArchitecture
import SwiftUI

public struct ResetAuthView: View {
  public init(store: Store<ResetAuthState, ResetAuthAction>) {
    self.store = store
  }

  let store: Store<ResetAuthState, ResetAuthAction>

  struct ViewState: Equatable {
    init(state: ResetAuthState) {
      contactID = try? state.partner.getId()
      isResetting = state.isResetting
      failure = state.failure
      didReset = state.didReset
    }

    var contactID: Data?
    var isResetting: Bool
    var failure: String?
    var didReset: Bool
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Text(viewStore.contactID?.hexString() ?? "")
            .font(.footnote.monospaced())
            .textSelection(.enabled)
        } header: {
          Label("ID", systemImage: "number")
        }

        Button {
          viewStore.send(.resetTapped)
        } label: {
          HStack {
            Text("Reset authenticated channel")
            Spacer()
            if viewStore.isResetting {
              ProgressView()
            } else if viewStore.didReset {
              Image(systemName: "checkmark")
                .foregroundColor(.green)
            }
          }
        }
        .disabled(viewStore.isResetting)

        if let failure = viewStore.failure {
          Section {
            Text(failure)
          } header: {
            Text("Error")
          }
        }
      }
      .navigationTitle("Reset auth")
    }
  }
}

#if DEBUG
public struct ResetAuthView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ResetAuthView(store: Store(
        initialState: ResetAuthState(
          partner: .unimplemented(Data())
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
