import ComposableArchitecture
import SwiftUI

public struct RestoreView: View {
  public init(store: Store<RestoreState, RestoreAction>) {
    self.store = store
  }

  let store: Store<RestoreState, RestoreAction>

  struct ViewState: Equatable {
    init(state: RestoreState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      NavigationView {
        Form {
          Section {
            Text("Not implemented")
          }

          Section {
            Button {
              viewStore.send(.finished)
            } label: {
              Text("OK")
                .frame(maxWidth: .infinity)
            }
          }
        }
        .navigationTitle("Restore")
      }
      .navigationViewStyle(.stack)
    }
  }
}

#if DEBUG
public struct RestoreView_Previews: PreviewProvider {
  public static var previews: some View {
    RestoreView(store: Store(
      initialState: RestoreState(),
      reducer: .empty,
      environment: ()
    ))
  }
}
#endif
