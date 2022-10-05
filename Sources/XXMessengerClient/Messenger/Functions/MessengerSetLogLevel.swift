import XCTestDynamicOverlay
import XXClient

public struct MessengerSetLogLevel {
  public var run: (LogLevel) throws -> Bool

  public func callAsFunction(_ logLevel: LogLevel) throws -> Bool {
    try run(logLevel)
  }
}

extension MessengerSetLogLevel {
  public static func live(_ env: MessengerEnvironment) -> MessengerSetLogLevel {
    MessengerSetLogLevel(run: env.setLogLevel.run)
  }
}

extension MessengerSetLogLevel {
  public static let unimplemented = MessengerSetLogLevel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
