import AppCore
import BackupFeature
import ChatFeature
import CheckContactAuthFeature
import ConfirmRequestFeature
import ContactFeature
import ContactLookupFeature
import ContactsFeature
import Foundation
import HomeFeature
import MyContactFeature
import RegisterFeature
import ResetAuthFeature
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
      handleRequest: .live(db: dbManager.getDB, now: Date.init),
      handleConfirm: .live(db: dbManager.getDB),
      handleReset: .live(db: dbManager.getDB)
    )
    let backupStorage = BackupStorage.onDisk()
    let mainQueue = DispatchQueue.main.eraseToAnyScheduler()
    let bgQueue = DispatchQueue.global(qos: .background).eraseToAnyScheduler()

    defer {
      _ = try! messenger.setLogLevel(.debug)
      messenger.startLogging()
    }

    let contactEnvironment = ContactEnvironment(
      messenger: messenger,
      db: dbManager.getDB,
      mainQueue: mainQueue,
      bgQueue: bgQueue,
      lookup: {
        ContactLookupEnvironment(
          messenger: messenger,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      sendRequest: {
        SendRequestEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      verifyContact: {
        VerifyContactEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      confirmRequest: {
        ConfirmRequestEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      checkAuth: {
        CheckContactAuthEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      resetAuth: {
        ResetAuthEnvironment(
          messenger: messenger,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      chat: {
        ChatEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          sendMessage: .live(
            messenger: messenger,
            db: dbManager.getDB,
            now: Date.init
          ),
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      }
    )

    return AppEnvironment(
      dbManager: dbManager,
      messenger: messenger,
      authHandler: authHandler,
      messageListener: .live(
        messenger: messenger,
        db: dbManager.getDB
      ),
      receiveFileHandler: .live(
        messenger: messenger,
        db: dbManager.getDB,
        now: Date.init
      ),
      backupStorage: backupStorage,
      log: .live(),
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
        RestoreEnvironment(
          messenger: messenger,
          db: dbManager.getDB,
          loadData: .live,
          now: Date.init,
          mainQueue: mainQueue,
          bgQueue: bgQueue
        )
      },
      home: {
        HomeEnvironment(
          messenger: messenger,
          dbManager: dbManager,
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
              contact: { contactEnvironment },
              myContact: {
                MyContactEnvironment(
                  messenger: messenger,
                  db: dbManager.getDB,
                  mainQueue: mainQueue,
                  bgQueue: bgQueue
                )
              }
            )
          },
          userSearch: {
            UserSearchEnvironment(
              messenger: messenger,
              mainQueue: mainQueue,
              bgQueue: bgQueue,
              contact: { contactEnvironment }
            )
          },
          backup: {
            BackupEnvironment(
              messenger: messenger,
              backupStorage: backupStorage,
              mainQueue: mainQueue,
              bgQueue: bgQueue
            )
          }
        )
      }
    )
  }
}
