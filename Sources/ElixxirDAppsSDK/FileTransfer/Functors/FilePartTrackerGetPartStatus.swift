import Bindings
import XCTestDynamicOverlay

public struct FilePartTrackerGetPartStatus {
  public var run: (Int) -> FilePartStatus

  public func callAsFunction(partNum: Int) -> FilePartStatus {
    run(partNum)
  }
}

extension FilePartTrackerGetPartStatus {
  public static func live(_ tracker: BindingsFilePartTracker) -> FilePartTrackerGetPartStatus {
    FilePartTrackerGetPartStatus { partNum in
      FilePartStatus(rawValue: tracker.getPartStatus(partNum))
    }
  }
}

extension FilePartTrackerGetPartStatus {
  public static let unimplemented = FilePartTrackerGetPartStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
