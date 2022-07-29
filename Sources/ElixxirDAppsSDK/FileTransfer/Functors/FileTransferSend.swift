import Bindings
import XCTestDynamicOverlay

public struct FileTransferSend {
  public struct Params: Equatable {
    public init(
      payload: FileSend,
      recipientId: Data,
      paramsJSON: Data,
      retry: Float,
      period: String
    ) {
      self.payload = payload
      self.recipientId = recipientId
      self.paramsJSON = paramsJSON
      self.retry = retry
      self.period = period
    }

    public var payload: FileSend
    public var recipientId: Data
    public var paramsJSON: Data
    public var retry: Float
    public var period: String
  }

  public var run: (Params, FileTransferProgressCallback) throws -> Data

  public func callAsFunction(
    params: Params,
    callback: FileTransferProgressCallback
  ) throws -> Data {
    try run(params, callback)
  }
}

extension FileTransferSend {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferSend {
    FileTransferSend { params, callback in
      try bindingsFileTransfer.send(
        params.payload.encode(),
        recipientID: params.recipientId,
        retry: params.retry,
        callback: callback.makeBindingsFileTransferSentProgressCallback(),
        period: params.period
      )
    }
  }
}

extension FileTransferSend {
  public static let unimplemented = FileTransferSend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
