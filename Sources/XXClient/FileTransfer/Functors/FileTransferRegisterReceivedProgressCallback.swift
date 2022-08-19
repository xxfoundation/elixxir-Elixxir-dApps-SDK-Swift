import Bindings
import XCTestDynamicOverlay

public struct FileTransferRegisterReceivedProgressCallback {
  public var run: (Data, String, FileTransferProgressCallback) throws -> Void

  public func callAsFunction(
    transferId: Data,
    period: String,
    callback: FileTransferProgressCallback
  ) throws {
    try run(transferId, period, callback)
  }
}

extension FileTransferRegisterReceivedProgressCallback {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer)
  -> FileTransferRegisterReceivedProgressCallback {
    FileTransferRegisterReceivedProgressCallback { transferId, period, callback in
      try bindingsFileTransfer.registerReceivedProgressCallback(
        transferId,
        callback: callback.makeBindingsFileTransferReceiveProgressCallback(),
        period: period
      )
    }
  }
}

extension FileTransferRegisterReceivedProgressCallback {
  public static let unimplemented = FileTransferRegisterReceivedProgressCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
