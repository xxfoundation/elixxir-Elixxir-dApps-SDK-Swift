import ComposableArchitecture
import SwiftUI

public struct BackupView: View {
  public init(store: Store<BackupState, BackupAction>) {
    self.store = store
  }

  let store: Store<BackupState, BackupAction>

  struct ViewState: Equatable {
    init(state: BackupState) {}
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {

      }
      .navigationTitle("Backup")
      .task {
        viewStore.send(.start)
      }
    }
  }
}

#if DEBUG
public struct BackupView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      BackupView(store: Store(
        initialState: BackupState(),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
