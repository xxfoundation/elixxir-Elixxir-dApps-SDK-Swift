import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerReceiveFile {
  public struct Params: Equatable {
    public init(
      transferId: Data,
      callbackIntervalMS: Int = 250
    ) {
      self.transferId = transferId
      self.callbackIntervalMS = callbackIntervalMS
    }

    public var transferId: Data
    public var callbackIntervalMS: Int
  }

  public enum CallbackInfo: Equatable {
    public enum Failure: Equatable {
      case callbackError(NSError)
      case progressError(String)
      case receiveError(NSError)
    }

    case progress(transmitted: Int, total: Int)
    case finished(Data)
    case failed(Failure)
  }

  public typealias Callback = (CallbackInfo) -> Void

  public enum Error: Swift.Error, Equatable {
    case fileTransferNotStarted
  }

  public var run: (Params, @escaping Callback) throws -> Void

  public func callAsFunction(
    _ params: Params,
    callback: @escaping Callback
  ) throws -> Void {
    try run(params, callback)
  }
}

extension MessengerReceiveFile {
  public static func live(_ env: MessengerEnvironment) -> MessengerReceiveFile {
    MessengerReceiveFile { params, callback in
      guard let fileTransfer = env.fileTransfer() else {
        throw Error.fileTransferNotStarted
      }
      try fileTransfer.registerReceivedProgressCallback(
        transferId: params.transferId,
        period: params.callbackIntervalMS,
        callback: FileTransferProgressCallback { result in
          switch result {
          case .success(let info):
            if let error = info.progress.error {
              callback(.failed(.progressError(error)))
            } else if info.progress.completed {
              do {
                callback(.finished(try fileTransfer.receive(transferId: params.transferId)))
              } catch {
                callback(.failed(.receiveError(error as NSError)))
              }
            } else {
              callback(.progress(
                transmitted: info.progress.transmitted,
                total: info.progress.total
              ))
            }

          case .failure(let error):
            callback(.failed(.callbackError(error)))
          }
        }
      )
    }
  }
}

extension MessengerReceiveFile {
  public static let unimplemented = MessengerReceiveFile(
    run: XCTUnimplemented("\(Self.self)")
  )
}
