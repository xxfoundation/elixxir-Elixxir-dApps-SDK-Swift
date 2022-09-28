import Bindings
import XCTestDynamicOverlay

public struct MessengerStopBackup {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerStopBackup {
  public static func live(_ env: MessengerEnvironment) -> MessengerStopBackup {
    MessengerStopBackup {
      guard let backup = env.backup() else { return }
      try backup.stop()
      env.backup.set(nil)
    }
  }
}

extension MessengerStopBackup {
  public static let unimplemented = MessengerStopBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
