import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerSendFile {
  public typealias Callback = (Data, XXClient.Progress) -> Void

  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: (FileTransferSend.Params, @escaping Callback) throws -> Void

  public func callAsFunction(
    _ params: FileTransferSend.Params,
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
        callback: ReceiveFileCallback { _ in
          fatalError("Bindings issue: ReceiveFileCallback called when sending file.")
        }
      )
      let semaphore = DispatchSemaphore(value: 0)
      var transferId: Data!
      var error: Swift.Error?
      transferId = try fileTransfer.send(
        params: params,
        callback: FileTransferProgressCallback { result in
          guard let transferId else {
            fatalError("Bindings issue: file transfer progress callback was called before send function returned transfer id.")
          }
          switch result {
          case .failure(let err):
            error = err
            semaphore.signal()

          case .success(let cb):
            callback(transferId, cb.progress)
            if cb.progress.completed || cb.progress.error != nil {
              semaphore.signal()
            }
          }
        }
      )
      semaphore.wait()
      try fileTransfer.closeSend(transferId: transferId)
      if let error {
        throw error
      }
    }
  }
}

extension MessengerSendFile {
  public static let unimplemented = MessengerSendFile(
    run: XCTUnimplemented("\(Self.self)")
  )
}
