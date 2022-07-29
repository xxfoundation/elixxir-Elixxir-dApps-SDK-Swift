import Bindings
import XCTestDynamicOverlay

public struct SetLogLevel {
  public var run: (LogLevel) throws -> Bool

  public func callAsFunction(_ logLevel: LogLevel) throws -> Bool {
    try run(logLevel)
  }
}

extension SetLogLevel {
  public static let live = SetLogLevel { logLevel in
    var error: NSError?
    let result = BindingsLogLevel(logLevel.rawValue, &error)
    if let error = error {
      throw error
    }
    return result
  }
}

extension SetLogLevel {
  public static let unimplemented = SetLogLevel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
