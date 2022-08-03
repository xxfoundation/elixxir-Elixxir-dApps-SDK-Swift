import Foundation
import XCTestDynamicOverlay

public struct CMixManagerRemove {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension CMixManagerRemove {
  public static func live(
    directoryPath: String,
    fileManager: FileManager
  ) -> CMixManagerRemove {
    CMixManagerRemove {
      try fileManager.removeItem(atPath: directoryPath)
    }
  }
}

extension CMixManagerRemove {
  public static let unimplemented = CMixManagerRemove(
    run: XCTUnimplemented("\(Self.self)")
  )
}
