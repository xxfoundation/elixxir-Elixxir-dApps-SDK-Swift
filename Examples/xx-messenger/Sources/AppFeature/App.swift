import ComposableArchitecture
import Logging
import PulseLogHandler
import SwiftUI

@main
struct App: SwiftUI.App {
  init() {
    LoggingSystem.bootstrap(PersistentLogHandler.init)
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: .live()
      ))
    }
  }
}
