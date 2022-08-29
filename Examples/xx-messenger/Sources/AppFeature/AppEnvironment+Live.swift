import AppCore
import Foundation
import HomeFeature
import LaunchFeature
import RegisterFeature
import RestoreFeature
import WelcomeFeature
import XXMessengerClient
import XXModels

extension AppEnvironment {
  static func live() -> AppEnvironment {
    let dbManager = DBManager.live()
    let messengerEnv = MessengerEnvironment.live()
    let messenger = Messenger.live(messengerEnv)
    let mainQueue = DispatchQueue.main.eraseToAnyScheduler()
    let bgQueue = DispatchQueue.global(qos: .background).eraseToAnyScheduler()

    return AppEnvironment(
      launch: {
        LaunchEnvironment(
          dbManager: dbManager,
          messenger: messenger,
          mainQueue: mainQueue,
          bgQueue: bgQueue,
          welcome: {
            WelcomeEnvironment(
              messenger: messenger,
              mainQueue: mainQueue,
              bgQueue: bgQueue
            )
          },
          restore: {
            RestoreEnvironment()
          },
          register: {
            RegisterEnvironment(
              messenger: messenger,
              mainQueue: mainQueue,
              bgQueue: bgQueue
            )
          }
        )
      },
      home: {
        HomeEnvironment(
          messenger: messenger,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      }
    )
  }
}
