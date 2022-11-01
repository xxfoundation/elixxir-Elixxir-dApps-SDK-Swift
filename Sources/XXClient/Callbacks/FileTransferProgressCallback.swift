import Bindings
import XCTestDynamicOverlay

public struct FileTransferProgressCallback {
  public struct Callback {
    public init(
      progress: Progress,
      partTracker: FilePartTracker,
      error: Error?
    ) {
      self.progress = progress
      self.partTracker = partTracker
      self.error = error
    }

    public var progress: Progress
    public var partTracker: FilePartTracker
    public var error: Error?
  }

  public init(handle: @escaping (Callback) -> Void) {
    self.handle = handle
  }

  public var handle: (Callback) -> Void
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
        guard let payload = payload else {
          fatalError("\(debugName) received `nil` payload without providing error")
        }
        let progress: Progress
        do {
          progress = try Progress.decode(payload)
        } catch {
          fatalError("\(debugName) payload decoding failed with error: \(error)")
        }
        guard let tracker = t else {
          fatalError("\(debugName) received `nil` tracker without providing error")
        }
        callback.handle(.init(
          progress: progress,
          partTracker: .live(tracker),
          error: err
        ))
      }
    }

    return CallbackObject(self, debugName)
  }
}
