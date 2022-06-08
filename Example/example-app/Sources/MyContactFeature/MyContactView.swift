import ComposableArchitecture
import SwiftUI

public struct MyContactView: View {
  public init(store: Store<MyContactState, MyContactAction>) {
    self.store = store
  }

  let store: Store<MyContactState, MyContactAction>

  struct ViewState: Equatable {
    init(state: MyContactState) {}
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Text("MyContactView")
        .navigationTitle("My contact")
        .task {
          viewStore.send(.viewDidLoad)
        }
    }
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
