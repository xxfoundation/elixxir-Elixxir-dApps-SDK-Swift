import XCTestDynamicOverlay
import XXClient

public struct MessengerStartBackup {
  public enum Error: Swift.Error, Equatable {
    case isRunning
    case notConnected
    case notLoggedIn
  }

  public var run: (String, BackupParams) throws -> Void

  public func callAsFunction(
    password: String,
    params: BackupParams
  ) throws {
    try run(password, params)
  }
}

extension MessengerStartBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerStartBackup {
    MessengerStartBackup { password, params in
      guard env.backup()?.isRunning() != true else {
        throw Error.isRunning
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      guard let ud = env.ud() else {
        throw Error.notLoggedIn
      }
      let paramsData = try params.encode()
      let paramsString = String(data: paramsData, encoding: .utf8)!
      var didAddParams = false
      func addParams() {
        guard let backup = env.backup() else { return }
        backup.addJSON(paramsString)
        didAddParams = true
      }
      let backup = try env.initializeBackup(
        e2eId: e2e.getId(),
        udId: ud.getId(),
        password: password,
        callback: .init { data in
          if !didAddParams {
            addParams()
          } else {
            env.backupCallbacks.registered().handle(data)
          }
        }
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
