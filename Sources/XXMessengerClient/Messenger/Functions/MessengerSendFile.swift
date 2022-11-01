import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerSendFile {
  public struct Params: Equatable {
    public init(
      file: FileSend,
      recipientId: Data,
      retry: Int = 3,
      callbackIntervalMS: Int = 250
    ) {
      self.file = file
      self.recipientId = recipientId
      self.retry = retry
      self.callbackIntervalMS = callbackIntervalMS
    }

    public var file: FileSend
    public var recipientId: Data
    public var retry: Int
    public var callbackIntervalMS: Int
  }

  public enum CallbackInfo: Equatable {
    public enum Failure: Equatable {
      case callback(NSError)
      case close(NSError)
    }

    case progress(id: Data, transmitted: Int, total: Int)
    case finished(id: Data)
    case failed(id: Data, Failure)
  }

  public typealias Callback = (CallbackInfo) -> Void

  public enum Error: Swift.Error, Equatable {
    case fileTransferNotStarted
  }

  public var run: (Params, @escaping Callback) throws -> Data

  public func callAsFunction(
    _ params: Params,
    callback: @escaping Callback
  ) throws -> Data {
    try run(params, callback)
  }
}

extension MessengerSendFile {
  public static func live(_ env: MessengerEnvironment) -> MessengerSendFile {
    MessengerSendFile { params, callback in
      guard let fileTransfer = env.fileTransfer() else {
        throw Error.fileTransferNotStarted
      }
      func close(id: Data) {
        do {
          try fileTransfer.closeSend(transferId: id)
        } catch {
          callback(.failed(id: id, .close(error as NSError)))
        }
      }
      let transferId = try fileTransfer.send(
        params: FileTransferSend.Params(
          payload: params.file,
          recipientId: params.recipientId,
          retry: Float(params.retry),
          period: params.callbackIntervalMS
        ),
        callback: FileTransferProgressCallback { result in
          if let error = result.error {
            callback(.failed(id: result.progress.transferId, .callback(error as NSError)))
            close(id: result.progress.transferId)
            return
          }
          if result.progress.completed {
            callback(.finished(id: result.progress.transferId))
            close(id: result.progress.transferId)
            return
          }
          callback(.progress(
            id: result.progress.transferId,
            transmitted: result.progress.transmitted,
            total: result.progress.total
          ))
        }
      )
      return transferId
    }
  }
}

extension MessengerSendFile {
  public static let unimplemented = MessengerSendFile(
    run: XCTUnimplemented("\(Self.self)")
  )
}
