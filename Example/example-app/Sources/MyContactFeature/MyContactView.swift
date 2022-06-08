import ComposableArchitecture
import ComposablePresentation
import ElixxirDAppsSDK
import ErrorFeature
import SwiftUI

public struct MyContactView: View {
  public init(store: Store<MyContactState, MyContactAction>) {
    self.store = store
  }

  let store: Store<MyContactState, MyContactAction>

  struct ViewState: Equatable {
    let contact: Data?
    let isMakingContact: Bool

    init(state: MyContactState) {
      contact = state.contact
      isMakingContact = state.isMakingContact
    }

    var isLoading: Bool {
      isMakingContact
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Section {
          Text(string(for: viewStore.contact))
            .textSelection(.enabled)
        }

        Section {
          Button {
            viewStore.send(.makeContact)
          } label: {
            HStack {
              Text("Make contact from identity")
              Spacer()
              if viewStore.isMakingContact {
                ProgressView()
              }
            }
          }
        }
        .disabled(viewStore.isLoading)
      }
      .navigationTitle("My contact")
      .navigationBarBackButtonHidden(viewStore.isLoading)
      .task {
        viewStore.send(.viewDidLoad)
      }
      .sheet(
        store.scope(
          state: \.error,
          action: MyContactAction.error
        ),
        onDismiss: {
          viewStore.send(.didDismissError)
        },
        content: ErrorView.init(store:)
      )
    }
  }

  func string(for contact: Data?) -> String {
    guard let contact = contact else {
      return "No contact"
    }
    return String(data: contact, encoding: .utf8) ?? "Decoding error"
  }
}

#if DEBUG
public struct MyContactView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      MyContactView(store: .init(
        initialState: .init(id: UUID()),
        reducer: .empty,
        environment: ()
      ))
    }
    .navigationViewStyle(.stack)
  }
}
#endif
