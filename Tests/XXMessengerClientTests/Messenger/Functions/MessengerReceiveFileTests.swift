import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerReceiveFileTests: XCTestCase {
  func testReceiveFile() throws {
    let params: MessengerReceiveFile.Params = .stub
    let receivedData = "received".data(using: .utf8)!

    var didRegisterReceivedProgressCallbackWithTransferId: [Data] = []
    var didRegisterReceivedProgressCallbackWithPeriod: [Int] = []
    var didRegisterReceivedProgressCallbackWithCallback: [FileTransferProgressCallback] = []
    var didReceiveTransferId: [Data] = []
    var didReceiveCallback: [MessengerReceiveFile.CallbackInfo] = []

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.registerReceivedProgressCallback.run = { transferId, period, callback in
        didRegisterReceivedProgressCallbackWithTransferId.append(transferId)
        didRegisterReceivedProgressCallbackWithPeriod.append(period)
        didRegisterReceivedProgressCallbackWithCallback.append(callback)
      }
      fileTransfer.receive.run = { transferId in
        didReceiveTransferId.append(transferId)
        return receivedData
      }
      return fileTransfer
    }
    let receiveFile: MessengerReceiveFile = .live(env)

    try receiveFile(params) { info in
      didReceiveCallback.append(info)
    }

    XCTAssertNoDifference(didRegisterReceivedProgressCallbackWithTransferId, [
      params.transferId
    ])
    XCTAssertNoDifference(didRegisterReceivedProgressCallbackWithPeriod, [
      params.callbackIntervalMS
    ])
    XCTAssertNoDifference(didReceiveCallback, [])

    didReceiveCallback = []
    didRegisterReceivedProgressCallbackWithCallback.first?.handle(.init(
      progress: .init(
        transferId: params.transferId,
        completed: false,
        transmitted: 1,
        total: 3
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .progress(transmitted: 1, total: 3),
    ])

    didReceiveCallback = []
    didRegisterReceivedProgressCallbackWithCallback.first?.handle(.init(
      progress: .init(
        transferId: params.transferId,
        completed: false,
        transmitted: 2,
        total: 3
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .progress(transmitted: 2, total: 3),
    ])

    didReceiveCallback = []
    didRegisterReceivedProgressCallbackWithCallback.first?.handle(.init(
      progress: Progress(
        transferId: params.transferId,
        completed: true,
        transmitted: 3,
        total: 3
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveTransferId, [
      params.transferId,
    ])
    XCTAssertNoDifference(didReceiveCallback, [
      .finished(receivedData),
    ])
  }

  func testReceiveFileWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = { nil }
    let receiveFile: MessengerReceiveFile = .live(env)

    XCTAssertThrowsError(try receiveFile(.stub) { _ in }) { error in
      XCTAssertNoDifference(
        error as? MessengerReceiveFile.Error,
        MessengerReceiveFile.Error.fileTransferNotStarted
      )
    }
  }

  func testReceiveFileCallbackError() throws {
    let error = NSError(domain: "test", code: 123)

    var receivedProgressCallback: FileTransferProgressCallback?
    var didReceiveCallback: [MessengerReceiveFile.CallbackInfo] = []

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.registerReceivedProgressCallback.run = { _, _, callback in
        receivedProgressCallback = callback
      }
      return fileTransfer
    }
    let receiveFile: MessengerReceiveFile = .live(env)

    try receiveFile(.stub) { info in
      didReceiveCallback.append(info)
    }

    receivedProgressCallback?.handle(.init(
      progress: Progress(transferId: Data(), completed: false, transmitted: 0, total: 0),
      partTracker: .unimplemented,
      error: error
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .failed(.callback(error))
    ])
  }

  func testReceiveFileReceiveError() throws {
    let params: MessengerReceiveFile.Params = .stub
    let error = NSError(domain: "test", code: 123)

    var receivedProgressCallback: FileTransferProgressCallback?
    var didReceiveCallback: [MessengerReceiveFile.CallbackInfo] = []

    var env: MessengerEnvironment = .unimplemented
    env.fileTransfer.get = {
      var fileTransfer: FileTransfer = .unimplemented
      fileTransfer.registerReceivedProgressCallback.run = { _, _, callback in
        receivedProgressCallback = callback
      }
      fileTransfer.receive.run = { _ in
        throw error
      }
      return fileTransfer
    }
    let receiveFile: MessengerReceiveFile = .live(env)

    try receiveFile(params) { info in
      didReceiveCallback.append(info)
    }

    receivedProgressCallback?.handle(.init(
      progress: Progress(
        transferId: params.transferId,
        completed: true,
        transmitted: 3,
        total: 3
      ),
      partTracker: .unimplemented,
      error: nil
    ))

    XCTAssertNoDifference(didReceiveCallback, [
      .failed(.receive(error))
    ])
  }
}

private extension MessengerReceiveFile.Params {
  static let stub = MessengerReceiveFile.Params(
    transferId: "transfer-id".data(using: .utf8)!,
    callbackIntervalMS: 123
  )
}
