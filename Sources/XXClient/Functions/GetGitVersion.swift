import Bindings
import XCTestDynamicOverlay

public struct GetGitVersion {
  public var run: () -> String

  public func callAsFunction() -> String {
    run()
  }
}

extension GetGitVersion {
  public static let live = GetGitVersion(
    run: BindingsGetGitVersion
  )
}

extension GetGitVersion {
  public static let unimplemented = GetGitVersion(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented")
  )
}
