import ComposableArchitecture
import LandingFeature
import SessionFeature
import SwiftUI

@main
struct App: SwiftUI.App {
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

extension AppEnvironment {
  static func live() -> AppEnvironment {
    AppEnvironment(
      landing: LandingEnvironment(),
      session: SessionEnvironment()
    )
  }
}
