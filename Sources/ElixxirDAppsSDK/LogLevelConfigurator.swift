import Bindings

public struct LogLevelConfigurator {
  public var set: (LogLevel) throws -> Void

  public func callAsFunction(logLevel: LogLevel) throws {
    try set(logLevel)
  }
}

extension LogLevelConfigurator {
  public static func live() -> LogLevelConfigurator {
    LogLevelConfigurator { logLevel in
      var error: NSError?
      let result = BindingsLogLevel(logLevel.rawValue, &error)
      if let error = error {
        throw error
      }
      if !result {
        fatalError("BindingsLogLevel returned `false` without providing error")
      }
    }
  }
}

#if DEBUG
extension LogLevelConfigurator {
  public static let failing = LogLevelConfigurator { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
