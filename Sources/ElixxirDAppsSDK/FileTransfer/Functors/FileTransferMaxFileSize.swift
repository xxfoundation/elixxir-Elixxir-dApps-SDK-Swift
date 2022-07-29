import Bindings
import XCTestDynamicOverlay

public struct FileTransferMaxFileSize {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension FileTransferMaxFileSize {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferMaxFileSize {
    FileTransferMaxFileSize(run: bindingsFileTransfer.maxFileSize)
  }
}

extension FileTransferMaxFileSize {
  public static let unimplemented = FileTransferMaxFileSize(
    run: XCTUnimplemented("\(Self.self)")
  )
}
