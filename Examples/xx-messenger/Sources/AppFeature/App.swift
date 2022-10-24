import ComposableArchitecture
import Logging
import PulseLogHandler
import SwiftUI

@main
struct App: SwiftUI.App {
  init() {
    LoggingSystem.bootstrap(PersistentLogHandler.init)
    ViewStore(store.stateless).send(.setupLogging)
  }

  let store = Store(
    initialState: AppComponent.State(),
    reducer: AppComponent()
  )

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
