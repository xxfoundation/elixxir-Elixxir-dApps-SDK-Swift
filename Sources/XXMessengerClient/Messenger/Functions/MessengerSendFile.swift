import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerSendFile {
  public struct CallbackData {
    public init(
      transferId: Data,
      result: Result<FileTransferProgressCallback.Callback, NSError>
    ) {
      self.transferId = transferId
      self.result = result
    }

    public var transferId: Data
    public var result: Result<FileTransferProgressCallback.Callback, NSError>
  }

  public typealias Callback = (CallbackData) -> Void

  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: (FileTransferSend.Params, @escaping Callback) throws -> Void

  public func callAsFunction(
    params: FileTransferSend.Params,
    callback: @escaping Callback
  ) throws -> Void {
    try run(params, callback)
  }
}

extension MessengerSendFile {
  public static func live(_ env: MessengerEnvironment) -> MessengerSendFile {
    MessengerSendFile { params, callback in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      let fileTransfer = try env.initFileTransfer(
        params: InitFileTransfer.Params(
          e2eId: e2e.getId(),
          e2eFileTransferParamsJSON: env.getE2EFileTransferParams(),
          fileTransferParamsJSON: env.getFileTransferParams()
        ),
        callback: .unimplemented
      )
      let semaphore = DispatchSemaphore(value: 0)
      var transferId: Data! = nil
      transferId = try fileTransfer.send(
        params: params,
        callback: FileTransferProgressCallback { result in
          callback(CallbackData(
            transferId: transferId,
            result: result
          ))
          switch result {
          case .failure(_):

            semaphore.signal()
          case .success(let callback):
            if callback.progress.error != nil {

            }
            if callback.progress.completed {
              semaphore.signal()
            }
          }
        }
      )
      semaphore.wait()
      try? fileTransfer.closeSend(transferId: transferId)
    }
  }
}

extension MessengerSendFile {
  public static let unimplemented = MessengerSendFile(
    run: XCTUnimplemented("\(Self.self)")
  )
}
