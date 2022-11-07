import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerStartBackup {
  public enum Error: Swift.Error, Equatable {
    case isRunning
    case notConnected
    case notLoggedIn
  }

  public var run: (String, String?) throws -> Void

  public func callAsFunction(
    password: String,
    params: String? = nil
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
      var didAddParams = false
      var semaphore: DispatchSemaphore? = .init(value: 0)
      let backup = try env.initializeBackup(
        e2eId: e2e.getId(),
        udId: ud.getId(),
        password: password,
        callback: .init { data in
          semaphore?.wait()
          if let params, !didAddParams {
            if let backup = env.backup() {
              backup.addJSON(params)
              didAddParams = true
            }
          } else {
            env.backupCallbacks.registered().handle(data)
          }
        }
      )
      env.backup.set(backup)
      semaphore?.signal()
      semaphore = nil
    }
  }
}

extension MessengerStartBackup {
  public static let unimplemented = MessengerStartBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
