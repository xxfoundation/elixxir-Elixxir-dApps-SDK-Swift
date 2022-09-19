import Bindings
import XCTestDynamicOverlay

public struct InitFileTransfer {
  public struct Params: Equatable {
    public init(
      e2eId: Int,
      e2eFileTransferParamsJSON: Data = GetE2EFileTransferParams.liveDefault(),
      fileTransferParamsJSON: Data = GetFileTransferParams.liveDefault()
    ) {
      self.e2eId = e2eId
      self.e2eFileTransferParamsJSON = e2eFileTransferParamsJSON
      self.fileTransferParamsJSON = fileTransferParamsJSON
    }

    public var e2eId: Int
    public var e2eFileTransferParamsJSON: Data = GetE2EFileTransferParams.liveDefault()
    public var fileTransferParamsJSON: Data = GetFileTransferParams.liveDefault()
  }

  public var run: (Params, ReceiveFileCallback) throws -> FileTransfer

  public func callAsFunction(
    params: Params,
    callback: ReceiveFileCallback
  ) throws -> FileTransfer {
    try run(params, callback)
  }
}

extension InitFileTransfer {
  public static let live = InitFileTransfer { params, callback in
    var error: NSError?
    let bindingsFileTransfer = BindingsInitFileTransfer(
      params.e2eId,
      callback.makeBindingsReceiveFileCallback(),
      params.e2eFileTransferParamsJSON,
      params.fileTransferParamsJSON,
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
