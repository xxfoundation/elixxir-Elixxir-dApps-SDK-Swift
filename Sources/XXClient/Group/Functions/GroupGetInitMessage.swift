import Bindings
import XCTestDynamicOverlay

public struct GroupGetInitMessage {
  public var run: () -> Data?

  public func callAsFunction() -> Data? {
    run()
  }
}

extension GroupGetInitMessage {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetInitMessage {
    GroupGetInitMessage(run: bindingsGroup.getInitMessage)
  }
}

extension GroupGetInitMessage {
  public static let unimplemented = GroupGetInitMessage(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
