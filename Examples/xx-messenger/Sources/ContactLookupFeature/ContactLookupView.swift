import AppCore
import ComposableArchitecture
import SwiftUI

public struct ContactLookupView: View {
  public init(store: StoreOf<ContactLookupComponent>) {
    self.store = store
  }

  let store: StoreOf<ContactLookupComponent>

  struct ViewState: Equatable {
    init(state: ContactLookupComponent.State) {
      id = state.id
      isLookingUp = state.isLookingUp
      failure = state.failure
    }

    var id: Data
    var isLookingUp: Bool
    var failure: String?
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Label(viewStore.id.hexString(), systemImage: "number")
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

        if let failure = viewStore.failure {
          Section {
            Text(failure)
          } header: {
            Text("Error")
          }
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
        initialState: ContactLookupComponent.State(
          id: "1234".data(using: .utf8)!
        ),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
