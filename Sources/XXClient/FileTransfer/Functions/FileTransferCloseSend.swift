import Bindings
import XCTestDynamicOverlay

public struct FileTransferCloseSend {
  public var run: (Data) throws -> Void

  public func callAsFunction(transferId: Data) throws {
    try run(transferId)
  }
}

extension FileTransferCloseSend {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferCloseSend {
    FileTransferCloseSend(run: bindingsFileTransfer.closeSend)
  }
}

extension FileTransferCloseSend {
  public static let unimplemented = FileTransferCloseSend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
