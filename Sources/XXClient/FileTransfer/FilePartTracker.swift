import Bindings

public struct FilePartTracker {
  public var getNumParts: FilePartTrackerGetNumParts
  public var getPartStatus: FilePartTrackerGetPartStatus
}

extension FilePartTracker {
  public static func live(_ bindingsTracker: BindingsFilePartTracker) -> FilePartTracker {
    FilePartTracker(
      getNumParts: .live(bindingsTracker),
      getPartStatus: .live(bindingsTracker)
    )
  }
}

extension FilePartTracker {
  public static let unimplemented = FilePartTracker(
    getNumParts: .unimplemented,
    getPartStatus: .unimplemented
  )
}
