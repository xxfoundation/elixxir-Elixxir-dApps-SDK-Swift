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
    class Writer: NSObject, BindingsLogWriterProtocol {
      init(_ writer: LogWriter) {
        self.writer = writer
      }

      let writer: LogWriter

      func log(_ p0: String?) {
        guard let p0 = p0 else {
          fatalError("BindingsLogWriter.log received `nil`")
        }
        writer.handle(p0)
      }
    }

    return Writer(self)
  }
}
