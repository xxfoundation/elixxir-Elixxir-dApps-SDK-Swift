import Bindings
import XCTestDynamicOverlay

public struct EnableGrpcLogs {
  public var run: (LogWriter) -> Void

  public func callAsFunction(_ writer: LogWriter) {
    run(writer)
  }
}

extension EnableGrpcLogs {
  public static let live = EnableGrpcLogs { writer in
    BindingsEnableGrpcLogs(writer.makeBindingsLogWriter())
  }
}

extension EnableGrpcLogs {
  public static let unimplemented = EnableGrpcLogs(
    run: XCTUnimplemented("\(Self.self)")
  )
}
