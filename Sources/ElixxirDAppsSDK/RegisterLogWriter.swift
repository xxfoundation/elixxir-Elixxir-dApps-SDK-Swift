import Bindings
import XCTestDynamicOverlay

public struct RegisterLogWriter {
  public var run: (LogWriter) -> Void

  public func callAsFunction(_ writer: LogWriter) {
    run(writer)
  }
}

extension RegisterLogWriter {
  public static let live = RegisterLogWriter { writer in
    BindingsRegisterLogWriter(writer.makeBindingsLogWriter())
  }
}

extension RegisterLogWriter {
  public static let unimplemented = RegisterLogWriter(
    run: XCTUnimplemented("\(Self.self)")
  )
}
