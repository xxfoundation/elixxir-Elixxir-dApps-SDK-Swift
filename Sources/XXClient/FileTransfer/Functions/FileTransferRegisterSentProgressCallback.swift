import Bindings
import XCTestDynamicOverlay

public struct FileTransferRegisterSentProgressCallback {
  public var run: (Data, Int, FileTransferProgressCallback) throws -> Void

  public func callAsFunction(
    transferId: Data,
    period: Int,
    callback: FileTransferProgressCallback
  ) throws {
    try run(transferId, period, callback)
  }
}

extension FileTransferRegisterSentProgressCallback {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer)
  -> FileTransferRegisterSentProgressCallback {
    FileTransferRegisterSentProgressCallback { transferId, period, callback in
      try bindingsFileTransfer.registerSentProgressCallback(
        transferId,
        callback: callback.makeBindingsFileTransferSentProgressCallback(),
        period: period
      )
    }
  }
}

extension FileTransferRegisterSentProgressCallback {
  public static let unimplemented = FileTransferRegisterSentProgressCallback(
    run: XCTUnimplemented("\(Self.self)")
  )
}
