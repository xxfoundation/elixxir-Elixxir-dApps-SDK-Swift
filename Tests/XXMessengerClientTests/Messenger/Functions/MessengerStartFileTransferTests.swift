import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerStartFileTransferTests: XCTestCase {
  func testStart() throws {
    let e2eId = 123
    let e2eFileTransferParams = "e2eFileTransferParams".data(using: .utf8)!
    let fileTransferParams = "fileTransferParams".data(using: .utf8)!

    var didInitFileTransfer: [InitFileTransfer.Params] = []
    var receiveFileCallback: ReceiveFileCallback?
    var didSetFileTransfer: [FileTransfer?] = []

    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    env.getE2EFileTransferParams.run = {
      e2eFileTransferParams
    }
    env.getFileTransferParams.run = {
      fileTransferParams
    }
    env.initFileTransfer.run = { params, callback in
      didInitFileTransfer.append(params)
      receiveFileCallback = callback
      var fileTransfer: FileTransfer = .unimplemented
      return fileTransfer
    }
    env.fileTransfer.set = {
      didSetFileTransfer.append($0)
    }

    let start: MessengerStartFileTransfer = .live(env)

    try start()

    XCTAssertNoDifference(didInitFileTransfer, [.init(
      e2eId: e2eId,
      e2eFileTransferParamsJSON: e2eFileTransferParams,
      fileTransferParamsJSON: fileTransferParams
    )])
    XCTAssertNotNil(receiveFileCallback)
    XCTAssertNoDifference(didSetFileTransfer.map { $0 != nil }, [true])
  }

  func testStartWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.e2e.get = { nil }
    let start: MessengerStartFileTransfer = .live(env)

    XCTAssertThrowsError(try start()) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerStartFileTransfer.Error.notConnected as NSError
      )
    }
  }
}
