import Bindings
import XCTestDynamicOverlay

public struct MessengerBackupParams {
  public enum Error: Swift.Error, Equatable {
    case notRunning
  }

  public var run: (BackupParams) throws -> Void

  public func callAsFunction(_ params: BackupParams) throws {
    try run(params)
  }
}

extension MessengerBackupParams {
  public static func live(_ env: MessengerEnvironment) -> MessengerBackupParams {
    MessengerBackupParams { params in
      guard let backup = env.backup(), backup.isRunning() else {
        throw Error.notRunning
      }
      let paramsData = try params.encode()
      let paramsString = String(data: paramsData, encoding: .utf8)!
      backup.addJSON(paramsString)
    }
  }
}

extension MessengerBackupParams {
  public static let unimplemented = MessengerBackupParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}
