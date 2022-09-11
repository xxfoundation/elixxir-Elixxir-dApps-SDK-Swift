import AppCore
import ContactFeature
import ContactsFeature
import Foundation
import HomeFeature
import RegisterFeature
import RestoreFeature
import SendRequestFeature
import UserSearchFeature
import VerifyContactFeature
import WelcomeFeature
import XXMessengerClient
import XXModels

extension AppEnvironment {
  static func live() -> AppEnvironment {
    let dbManager = DBManager.live()
    let messengerEnv = MessengerEnvironment.live()
    let messenger = Messenger.live(messengerEnv)
    let authHandler = AuthCallbackHandler.live(
      messenger: messenger,
      handleRequest: .live(
        db: dbManager.getDB,
        messenger: messenger,
        now: Date.init
      ),
      handleConfirm: .live(db: dbManager.getDB),
      handleReset: .live(db: dbManager.getDB)
    )
    let mainQueue = DispatchQueue.main.eraseToAnyScheduler()
    let bgQueue = DispatchQueue.global(qos: .background).eraseToAnyScheduler()

    let contactEnvironment = ContactEnvironment(
      messenger: messenger,
      db: dbManager.getDB,
      mainQueue: mainQueue,
      bgQueue: bgQueue,
      sendRequest: {
        SendRequestEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      verifyContact: {
        VerifyContactEnvironment()
      }
    )

    return AppEnvironment(
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
      home: {
        HomeEnvironment(
          messenger: messenger,
          dbManager: dbManager,
          authHandler: authHandler,
          mainQueue: mainQueue,
          bgQueue: bgQueue,
          register: {
            RegisterEnvironment(
              messenger: messenger,
              db: dbManager.getDB,
              now: Date.init,
              mainQueue: mainQueue,
              bgQueue: bgQueue
            )
          },
          contacts: {
            ContactsEnvironment(
              messenger: messenger,
              db: dbManager.getDB,
              mainQueue: mainQueue,
              bgQueue: bgQueue,
              contact: { contactEnvironment }
            )
          },
          userSearch: {
            UserSearchEnvironment(
              messenger: messenger,
              mainQueue: mainQueue,
              bgQueue: bgQueue,
              contact: { contactEnvironment }
            )
          }
        )
      }
    )
  }
}
