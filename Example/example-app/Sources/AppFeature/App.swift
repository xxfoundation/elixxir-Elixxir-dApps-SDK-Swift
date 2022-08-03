import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
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
    let cmixSubject = CurrentValueSubject<Cmix?, Never>(nil)
    let mainScheduler = DispatchQueue.main.eraseToAnyScheduler()
    let bgScheduler = DispatchQueue(
      label: "xx.network.dApps.ExampleApp.bg",
      qos: .background
    ).eraseToAnyScheduler()

    return AppEnvironment(
      makeId: UUID.init,
      hasCmix: { cmixSubject.map { $0 != nil }.eraseToAnyPublisher() },
      mainScheduler: mainScheduler,
      landing: LandingEnvironment(
        cmixManager: .live(
          passwordStorage: .keychain
        ),
        setCmix: { cmixSubject.value = $0 },
        bgScheduler: bgScheduler,
        mainScheduler: mainScheduler,
        error: ErrorEnvironment()
      ),
      session: SessionEnvironment(
        getCmix: { cmixSubject.value },
        bgScheduler: bgScheduler,
        mainScheduler: mainScheduler,
        error: ErrorEnvironment()
      )
    )
  }
}
