import Bindings
import XCTestDynamicOverlay

public struct LogWriter {
  public init(handle: @escaping (String) -> Void) {
    self.handle = handle
  }

  public var handle: (String) -> Void
}

extension LogWriter {
  public static let unimplemented = LogWriter(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension LogWriter {
  func makeBindingsLogWriter() -> BindingsLogWriterProtocol {
    class CallbackObject: NSObject, BindingsLogWriterProtocol {
      init(_ callback: LogWriter) {
        self.callback = callback
      }

      let callback: LogWriter

      func log(_ p0: String?) {
        guard let p0 = p0 else {
          fatalError("BindingsLogWriter.log received `nil`")
        }
        callback.handle(p0)
      }
    }

    return CallbackObject(self)
  }
}
