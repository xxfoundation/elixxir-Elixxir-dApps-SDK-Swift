import Bindings
import XCTestDynamicOverlay

public struct MessengerBackupParams {
  public enum Error: Swift.Error, Equatable {
    case notRunning
  }

  public var run: (String) throws -> Void

  public func callAsFunction(_ params: String) throws {
    try run(params)
  }
}

extension MessengerBackupParams {
  public static func live(_ env: MessengerEnvironment) -> MessengerBackupParams {
    MessengerBackupParams { params in
      guard let backup = env.backup(), backup.isRunning() else {
        throw Error.notRunning
      }
      backup.addJSON(params)
    }
  }
}

extension MessengerBackupParams {
  public static let unimplemented = MessengerBackupParams(
    run: XCTUnimplemented("\(Self.self)")
  )
}
