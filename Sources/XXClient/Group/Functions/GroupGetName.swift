import Bindings
import XCTestDynamicOverlay

public struct GroupGetName {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GroupGetName {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetName {
    GroupGetName {
      guard let data = bindingsGroup.getName() else {
        fatalError("BindingsGroup.getName returned `nil`")
      }
      return data
    }
  }
}

extension GroupGetName {
  public static let unimplemented = GroupGetName(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
