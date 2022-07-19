import Bindings

public struct LogsListener {
  public var listen: (@escaping (String) -> Void) -> Void

  public func callAsFunction(callback: @escaping (String) -> Void) {
    listen(callback)
  }
}

extension LogsListener {
  public static let live = LogsListener { callback in
    let listener = Listener(onLog: callback)
    BindingsRegisterLogWriter(listener)
  }
}

private final class Listener: NSObject, BindingsLogWriterProtocol {
  init(onLog: @escaping (String) -> Void) {
    self.onLog = onLog
    super.init()
  }

  let onLog: (String) -> Void

  func log(_ p0: String?) {
    guard let p0 = p0 else {
      fatalError("BindingsLogWriter.log received `nil`")
    }
    onLog(p0)
  }
}

#if DEBUG
extension LogsListener {
  public static let failing = LogsListener { _ in
    fatalError("Not implemented")
  }
}
#endif
