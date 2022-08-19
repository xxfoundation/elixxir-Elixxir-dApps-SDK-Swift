import Bindings
import XCTestDynamicOverlay

public struct FileTransferProgressCallback {
  public struct Callback {
    public var progress: Progress
    public var partTracker: FilePartTracker
  }

  public init(handle: @escaping (Result<Callback, NSError>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<Callback, NSError>) -> Void
}

extension FileTransferProgressCallback {
  public static let unimplemented = FileTransferProgressCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension FileTransferProgressCallback {
  func makeBindingsFileTransferReceiveProgressCallback() -> BindingsFileTransferReceiveProgressCallbackProtocol {
    makeBindingsFileTransferProgressCallback(debugName: "BindingsFileTransferReceiveProgressCallback")
  }

  func makeBindingsFileTransferSentProgressCallback() -> BindingsFileTransferSentProgressCallbackProtocol {
    makeBindingsFileTransferProgressCallback(debugName: "BindingsFileTransferSentProgressCallback")
  }

  private func makeBindingsFileTransferProgressCallback(debugName: String)
  -> BindingsFileTransferReceiveProgressCallbackProtocol & BindingsFileTransferSentProgressCallbackProtocol {
    class CallbackObject: NSObject,
                          BindingsFileTransferReceiveProgressCallbackProtocol,
                          BindingsFileTransferSentProgressCallbackProtocol {
      init(_ callback: FileTransferProgressCallback, _ debugName: String) {
        self.callback = callback
        self.debugName = debugName
      }

      let callback: FileTransferProgressCallback
      let debugName: String

      func callback(_ payload: Data?, t: BindingsFilePartTracker?, err: Error?) {
        if let error = err {
          callback.handle(.failure(error as NSError))
          return
        }
        guard let payload = payload else {
          fatalError("\(debugName) received `nil` payload without providing error")
        }
        guard let tracker = t else {
          fatalError("\(debugName) received `nil` tracker without providing error")
        }
        do {
          callback.handle(.success(.init(
            progress: try Progress.decode(payload),
            partTracker: .live(tracker)
          )))
        } catch {
          callback.handle(.failure(error as NSError))
        }
      }
    }

    return CallbackObject(self, debugName)
  }
}
