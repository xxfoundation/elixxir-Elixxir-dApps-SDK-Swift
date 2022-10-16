import XCTestDynamicOverlay
import XXClient

public struct MessengerStartFileTransfer {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: () throws -> Void

  public func callAsFunction() throws -> Void {
    try run()
  }
}

extension MessengerStartFileTransfer {
  public static func live(_ env: MessengerEnvironment) -> MessengerStartFileTransfer {
    MessengerStartFileTransfer {
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      let fileTransfer = try env.initFileTransfer(
        params: InitFileTransfer.Params(
          e2eId: e2e.getId(),
          e2eFileTransferParamsJSON: env.getE2EFileTransferParams(),
          fileTransferParamsJSON: env.getFileTransferParams()
        ),
        callback: env.receiveFileCallbacks.registered()
      )
      env.fileTransfer.set(fileTransfer)
    }
  }
}

extension MessengerStartFileTransfer {
  public static let unimplemented = MessengerStartFileTransfer(
    run: XCTUnimplemented("\(Self.self)")
  )
}
