import Bindings
import XCTestDynamicOverlay

public struct InitFileTransfer {
  public var run: (Int, Data, Data, ReceiveFileCallback) throws -> FileTransfer

  public func callAsFunction(
    e2eId: Int,
    e2eFileTransferParamsJSON: Data = GetE2EFileTransferParams.liveDefault(),
    fileTransferParamsJSON: Data = GetFileTransferParams.liveDefault(),
    callback: ReceiveFileCallback
  ) throws -> FileTransfer {
    try run(e2eId, e2eFileTransferParamsJSON, fileTransferParamsJSON, callback)
  }
}

extension InitFileTransfer {
  public static let live = InitFileTransfer {
    e2eId, e2eFileTransferParamsJSON, fileTransferParamsJSON, callback in

    var error: NSError?
    let bindingsFileTransfer = BindingsInitFileTransfer(
      e2eId,
      callback.makeBindingsReceiveFileCallback(),
      e2eFileTransferParamsJSON,
      fileTransferParamsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsFileTransfer = bindingsFileTransfer else {
      fatalError("BindingsInitFileTransfer returned `nil` without providing error")
    }
    return .live(bindingsFileTransfer)
  }
}

extension InitFileTransfer {
  public static let unimplemented = InitFileTransfer(
    run: XCTUnimplemented("\(Self.self)")
  )
}
