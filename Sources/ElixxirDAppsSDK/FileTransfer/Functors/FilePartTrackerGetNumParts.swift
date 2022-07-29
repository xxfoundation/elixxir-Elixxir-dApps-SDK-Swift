import Bindings
import XCTestDynamicOverlay

public struct FilePartTrackerGetNumParts {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension FilePartTrackerGetNumParts {
  public static func live(_ tracker: BindingsFilePartTracker) -> FilePartTrackerGetNumParts {
    FilePartTrackerGetNumParts(run: tracker.getNumParts)
  }
}

extension FilePartTrackerGetNumParts {
  public static let unimplemented = FilePartTrackerGetNumParts(
    run: XCTUnimplemented("\(Self.self)")
  )
}
