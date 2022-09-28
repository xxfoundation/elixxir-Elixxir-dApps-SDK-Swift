import XCTestDynamicOverlay
import XXClient

public struct MessengerStartBackup {
  public enum Error: Swift.Error, Equatable {
    case isRunning
    case notConnected
    case notLoggedIn
  }

  public var run: (String) throws -> Void

  public func callAsFunction(password: String) throws {
    try run(password)
  }
}

extension MessengerStartBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerStartBackup {
    MessengerStartBackup { password in
      guard env.backup()?.isRunning() != true else {
        throw Error.isRunning
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      let backup = try env.initializeBackup(
        e2eId: e2e.getId(),
        udId: ud.getId(),
        password: password,
        callback: env.backupCallbacks.registered()
      )
      env.backup.set(backup)
    }
  }
}

extension MessengerStartBackup {
  public static let unimplemented = MessengerStartBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
