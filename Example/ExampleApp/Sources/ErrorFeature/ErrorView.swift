import ComposableArchitecture
import SwiftUI

public struct ErrorView: View {
  public init(store: Store<ErrorState, ErrorAction>) {
    self.store = store
  }

  let store: Store<ErrorState, ErrorAction>
  @Environment(\.dismiss) var dismiss

  struct ViewState: Equatable {
    let error: NSError

    init(state: ErrorState) {
      error = state.error
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {
          Text("\(viewStore.error)")
        }
        .navigationTitle("Error")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              dismiss()
            } label: {
              Image(systemName: "xmark")
            }
          }
        }
      }
    }
  }
}

#if DEBUG
public struct ErrorView_Previews: PreviewProvider {
  public static var previews: some View {
    ErrorView(store: .init(
      initialState: .init(
        error: NSError(domain: "preview", code: 1234)
      ),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
