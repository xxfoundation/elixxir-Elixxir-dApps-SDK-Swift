import Bindings
import XCTestDynamicOverlay

public struct FileTransferMaxFilenameLen {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension FileTransferMaxFilenameLen {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferMaxFilenameLen {
    FileTransferMaxFilenameLen(run: bindingsFileTransfer.maxFileNameLen)
  }
}

extension FileTransferMaxFilenameLen {
  public static let unimplemented = FileTransferMaxFilenameLen(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
