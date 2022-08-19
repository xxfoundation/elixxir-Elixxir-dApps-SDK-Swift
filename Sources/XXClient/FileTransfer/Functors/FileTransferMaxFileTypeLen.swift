import Bindings
import XCTestDynamicOverlay

public struct FileTransferMaxFileTypeLen {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension FileTransferMaxFileTypeLen {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferMaxFileTypeLen {
    FileTransferMaxFileTypeLen(run: bindingsFileTransfer.maxFileTypeLen)
  }
}

extension FileTransferMaxFileTypeLen {
  public static let unimplemented = FileTransferMaxFileTypeLen(
    run: XCTUnimplemented("\(Self.self)")
  )
}
