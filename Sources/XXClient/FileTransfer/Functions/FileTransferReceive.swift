import Bindings
import XCTestDynamicOverlay

public struct FileTransferReceive {
  public var run: (Data) throws -> Data

  public func callAsFunction(transferId: Data) throws -> Data {
    try run(transferId)
  }
}

extension FileTransferReceive {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferReceive {
    FileTransferReceive(run: bindingsFileTransfer.receive)
  }
}

extension FileTransferReceive {
  public static let unimplemented = FileTransferReceive(
    run: XCTUnimplemented("\(Self.self)")
  )
}
