import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerSendFileTests: XCTestCase {
  func testSendFile() throws {
    let e2eId = 123
    let e2eFileTransferParams = "e2eFileTransferParams".data(using: .utf8)!
    let fileTransferParams = "fileTransferParams".data(using: .utf8)!
    let newTransferId = "transferId".data(using: .utf8)!

    var didInitFileTransfer: [InitFileTransfer.Params] = []
    var didSendFile: [FileTransferSend.Params] = []
    var didCloseSend: [Data] = []
    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []

    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.getE2EFileTransferParams.run = { e2eFileTransferParams }
    env.getFileTransferParams.run = { fileTransferParams }
    env.initFileTransfer.run = { params, callback in
      didInitFileTransfer.append(params)
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
    XCTAssertNoDifference(didInitFileTransfer, [
      .init(
        e2eId: e2eId,
        e2eFileTransferParamsJSON: e2eFileTransferParams,
        fileTransferParamsJSON: fileTransferParams
      )
    ])
    XCTAssertNoDifference(didSendFile, [
      .init(
        payload: params.file,
        recipientId: params.recipientId,
        retry: Float(params.retry),
        period: params.callbackIntervalMS
      )
    ])

    fileTransferProgressCallback.handle(.success(.init(
      progress: Progress(
        completed: false,
        transmitted: 1,
        total: 10,
        error: nil
      ),
      partTracker: .unimplemented
    )))
    fileTransferProgressCallback.handle(.success(.init(
      progress: Progress(
        completed: false,
        transmitted: 6,
        total: 10,
        error: nil
      ),
      partTracker: .unimplemented
    )))
    fileTransferProgressCallback.handle(.success(.init(
      progress: Progress(
        completed: true,
        transmitted: 10,
        total: 10,
        error: nil
      ),
      partTracker: .unimplemented
    )))

    XCTAssertNoDifference(didReceiveCallback, [
      .progress(id: transferId, transmitted: 1, total: 10),
      .progress(id: transferId, transmitted: 6, total: 10),
      .finished(id: transferId),
    ])
    XCTAssertNoDifference(didCloseSend, [transferId])
  }

  func testSendFileWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let sendFile: MessengerSendFile = .live(env)

    XCTAssertThrowsError(try sendFile(.stub) { _ in }) { error in
      XCTAssertNoDifference(
        error as? MessengerSendFile.Error,
        MessengerSendFile.Error.notConnected
      )
    }
  }

  func testSendFileCallbackFailure() throws {
    var didCloseSend: [Data] = []
    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.getE2EFileTransferParams.run = { Data() }
    env.getFileTransferParams.run = { Data() }
    env.initFileTransfer.run = { params, callback in
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { _, callback in
        fileTransferProgressCallback = callback
        return "transferId".data(using: .utf8)!
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

    let error = NSError(domain: "test", code: 1234)
    fileTransferProgressCallback.handle(.failure(error))

    XCTAssertNoDifference(didReceiveCallback, [
      .failed(id: transferId, .error(error)),
    ])
    XCTAssertNoDifference(didCloseSend, [transferId])
  }

  func testSendFileProgressError() throws {
    var didCloseSend: [Data] = []
    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.getE2EFileTransferParams.run = { Data() }
    env.getFileTransferParams.run = { Data() }
    env.initFileTransfer.run = { params, callback in
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { _, callback in
        fileTransferProgressCallback = callback
        return "transferId".data(using: .utf8)!
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

    let error = "something went wrong"
    fileTransferProgressCallback.handle(.success(.init(
      progress: .init(
        completed: false,
        transmitted: 0,
        total: 0,
        error: error
      ),
      partTracker: .unimplemented
    )))

    XCTAssertNoDifference(didReceiveCallback, [
      .failed(id: transferId, .progressError(error)),
    ])
    XCTAssertNoDifference(didCloseSend, [transferId])
  }

  func testSendFileCloseError() throws {
    let closeError = NSError(domain: "test", code: 1234)

    var didReceiveCallback: [MessengerSendFile.CallbackInfo] = []
    var fileTransferProgressCallback: FileTransferProgressCallback!

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { 123 }
      return e2e
    }
    env.getE2EFileTransferParams.run = { Data() }
    env.getFileTransferParams.run = { Data() }
    env.initFileTransfer.run = { params, callback in
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.send.run = { _, callback in
        fileTransferProgressCallback = callback
        return "transferId".data(using: .utf8)!
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

    fileTransferProgressCallback.handle(.success(.init(
      progress: .init(
        completed: true,
        transmitted: 1,
        total: 1,
        error: nil
      ),
      partTracker: .unimplemented
    )))

    XCTAssertNoDifference(didReceiveCallback, [
      .finished(id: transferId),
      .failed(id: transferId, .close(closeError)),
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
