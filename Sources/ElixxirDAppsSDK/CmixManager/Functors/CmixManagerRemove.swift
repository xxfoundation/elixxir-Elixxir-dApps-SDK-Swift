import Foundation
import XCTestDynamicOverlay

public struct CmixManagerRemove {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension CmixManagerRemove {
  public static func live(
    directoryPath: String,
    fileManager: FileManager
  ) -> CmixManagerRemove {
    CmixManagerRemove {
      try fileManager.removeItem(atPath: directoryPath)
    }
  }
}

extension CmixManagerRemove {
  public static let unimplemented = CmixManagerRemove(
    run: XCTUnimplemented("\(Self.self)")
  )
}
