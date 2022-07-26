import Bindings
import XCTestDynamicOverlay

public struct CmixManagerHasStorage {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CmixManagerHasStorage {
  public static func live(
    directoryPath: String,
    fileManager: FileManager
  ) -> CmixManagerHasStorage {
    CmixManagerHasStorage {
      let contents = try? fileManager.contentsOfDirectory(atPath: directoryPath)
      return contents.map { $0.isEmpty == false } ?? false
    }
  }
}

extension CmixManagerHasStorage {
  public static let unimplemented = CmixManagerHasStorage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
