import Foundation
import XCTestDynamicOverlay

public struct CMixManagerHasStorage {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CMixManagerHasStorage {
  public static func live(
    directoryPath: String,
    fileManager: FileManager
  ) -> CMixManagerHasStorage {
    CMixManagerHasStorage {
      let contents = try? fileManager.contentsOfDirectory(atPath: directoryPath)
      return contents.map { $0.isEmpty == false } ?? false
    }
  }
}

extension CMixManagerHasStorage {
  public static let unimplemented = CMixManagerHasStorage(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}
