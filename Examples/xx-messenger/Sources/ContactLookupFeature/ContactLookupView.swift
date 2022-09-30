import AppCore
import ComposableArchitecture
import SwiftUI

public struct ContactLookupView: View {
  public init(store: Store<ContactLookupState, ContactLookupAction>) {
    self.store = store
  }

  let store: Store<ContactLookupState, ContactLookupAction>

  struct ViewState: Equatable {
    init(state: ContactLookupState) {
      id = state.id
      isLookingUp = state.isLookingUp
    }

    var id: Data
    var isLookingUp: Bool
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Label(viewStore.id.hexString, systemImage: "number")
            .font(.footnote.monospaced())

          Button {
            viewStore.send(.lookupTapped)
          } label: {
            HStack {
              Text("Lookup")
              Spacer()
              if viewStore.isLookingUp {
                ProgressView()
              } else {
                Image(systemName: "magnifyingglass")
              }
            }
          }
          .disabled(viewStore.isLookingUp)
        } header: {
          Text("Contact ID")
        }
      }
      .navigationTitle("Lookup")
    }
  }
}

#if DEBUG
public struct ContactLookupView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ContactLookupView(store: Store(
        initialState: ContactLookupState(
          id: "1234".data(using: .utf8)!
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
