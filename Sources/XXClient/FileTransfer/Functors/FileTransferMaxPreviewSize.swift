import Bindings
import XCTestDynamicOverlay

public struct FileTransferMaxPreviewSize {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension FileTransferMaxPreviewSize {
  public static func live(_ bindingsFileTransfer: BindingsFileTransfer) -> FileTransferMaxPreviewSize {
    FileTransferMaxPreviewSize(run: bindingsFileTransfer.maxPreviewSize)
  }
}

extension FileTransferMaxPreviewSize {
  public static let unimplemented = FileTransferMaxPreviewSize(
    run: XCTUnimplemented("\(Self.self)")
  )
}
