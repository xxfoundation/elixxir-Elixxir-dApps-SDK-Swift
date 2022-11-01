import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerSendFileTests: XCTestCase {
  func testSendFile() throws {
    let newTransferId = "transferId".data(using: .utf8)!

    var didSendFile: [FileTransferSend.Params] = []
    var didCloseSend: [Data] = []
    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { params, callback in
        didSendFile.append(params)
        fileTransferProgressCallback = callback
        return newTransferId
      }
      fileTransfer.closeSend.run = { id in
        didCloseSend.append(id)
      }
      return fileTransfer
    }

    let sendFile: MessengerSendFile = .live(env)
    let params = MessengerSendFile.Params.stub

    let transferId = try sendFile(params) { info in
      didReceiveCallback.append(info)
    }

    XCTAssertNoDifference(transferId, newTransferId)
    XCTAssertNoDifference(didSendFile, [
      .init(
        payload: params.file,
        recipientId: params.recipientId,
        retry: Float(params.retry),
        period: params.callbackIntervalMS
      )
    ])

    fileTransferProgressCallback.handle(.init(
      progress: Progress(
        transferId: newTransferId,
        completed: false,
        transmitted: 1,
        total: 10
      ),
      partTracker: .unimplemented,
      error: nil
    ))
    fileTransferProgressCallback.handle(.init(
      progress: Progress(
        transferId: newTransferId,
        completed: false,
        transmitted: 6,
        total: 10
      ),
      partTracker: .unimplemented,
      error: nil
    ))
    fileTransferProgressCallback.handle(.init(
      progress: Progress(
        transferId: newTransferId,
        completed: true,
        transmitted: 10,
        total: 10
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .progress(id: transferId, transmitted: 1, total: 10),
      .progress(id: transferId, transmitted: 6, total: 10),
      .finished(id: transferId),
    ])
    XCTAssertNoDifference(didCloseSend, [transferId])
  }

  func testSendFileWhenNotStarted() {
    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = { nil }
    let sendFile: MessengerSendFile = .live(env)

    XCTAssertThrowsError(try sendFile(.stub) { _ in }) { error in
      XCTAssertNoDifference(
        error as? MessengerSendFile.Error,
        MessengerSendFile.Error.fileTransferNotStarted
      )
    }
  }

  func testSendFileCallbackFailure() throws {
    let newTransferId = "transferId".data(using: .utf8)!
    let error = NSError(domain: "test", code: 1234)

    var didCloseSend: [Data] = []
    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { _, callback in
        fileTransferProgressCallback = callback
        return newTransferId
      }
      fileTransfer.closeSend.run = { id in
        didCloseSend.append(id)
      }
      return fileTransfer
    }
    let sendFile: MessengerSendFile = .live(env)

    let transferId = try sendFile(.stub) { info in
      didReceiveCallback.append(info)
    }
    fileTransferProgressCallback.handle(.init(
      progress: .init(
        transferId: newTransferId,
        completed: false,
        transmitted: 0,
        total: 0
      ),
      partTracker: .unimplemented,
      error: error
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .failed(id: newTransferId, .callback(error)),
    ])
    XCTAssertNoDifference(didCloseSend, [newTransferId])
  }

  func testSendFileCloseError() throws {
    let closeError = NSError(domain: "test", code: 1234)
    let newTransferId = "transferId".data(using: .utf8)!

    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { _, callback in
        fileTransferProgressCallback = callback
        return newTransferId
      }
      fileTransfer.closeSend.run = { id in
        throw closeError
      }
      return fileTransfer
    }
    let sendFile: MessengerSendFile = .live(env)

    let transferId = try sendFile(.stub) { info in
      didReceiveCallback.append(info)
    }

    fileTransferProgressCallback.handle(.init(
      progress: .init(
        transferId: newTransferId,
        completed: true,
        transmitted: 1,
        total: 1
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .finished(id: newTransferId),
      .failed(id: newTransferId, .close(closeError)),
    ])
  }
}

private extension MessengerSendFile.Params {
  static let stub = MessengerSendFile.Params(
    file: FileSend(
      name: "file-name",
      type: "file-type",
      preview: "file-preview".data(using: .utf8)!,
      contents: "file-contents".data(using: .utf8)!
    ),
    recipientId: "recipient-id".data(using: .utf8)!,
    retry: 123,
    callbackIntervalMS: 321
  )
}
