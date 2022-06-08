import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import LandingFeature
import MyIdentityFeature
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
    let clientSubject = CurrentValueSubject<Client?, Never>(nil)
    let mainScheduler = DispatchQueue.main.eraseToAnyScheduler()
    let bgScheduler = DispatchQueue(
      label: "xx.network.dApps.ExampleApp.bg",
      qos: .background
    ).eraseToAnyScheduler()

    return AppEnvironment(
      makeId: UUID.init,
      hasClient: clientSubject.map { $0 != nil }.eraseToAnyPublisher(),
      mainScheduler: mainScheduler,
      landing: LandingEnvironment(
        clientStorage: .live(
          passwordStorage: .keychain
        ),
        setClient: { clientSubject.send($0) },
        bgScheduler: bgScheduler,
        mainScheduler: mainScheduler,
        error: ErrorEnvironment()
      ),
      session: SessionEnvironment(
        getClient: { clientSubject.value },
        bgScheduler: bgScheduler,
        mainScheduler: mainScheduler,
        makeId: UUID.init,
        error: ErrorEnvironment(),
        myIdentity: MyIdentityEnvironment()
      )
    )
  }
}
