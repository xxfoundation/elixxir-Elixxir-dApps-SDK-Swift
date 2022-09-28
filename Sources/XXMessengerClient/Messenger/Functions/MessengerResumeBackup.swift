import Bindings
import XCTestDynamicOverlay

public struct MessengerResumeBackup {
  public enum Error: Swift.Error, Equatable {
    case isRunning
    case notConnected
    case notLoggedIn
  }

  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerResumeBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerResumeBackup {
    MessengerResumeBackup {
      guard env.backup()?.isRunning() != true else {
        throw Error.isRunning
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      let backup = try env.resumeBackup(
        e2eId: e2e.getId(),
        udId: ud.getId(),
        callback: env.backupCallbacks.registered()
      )
      env.backup.set(backup)
    }
  }
}

extension MessengerResumeBackup {
  public static let unimplemented = MessengerResumeBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
