import Bindings
import XCTestDynamicOverlay

public struct GroupGetId {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GroupGetId {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupGetId {
    GroupGetId {
      guard let data = bindingsGroup.getID() else {
        fatalError("BindingsGroup.getID returned `nil`")
      }
      return data
    }
  }
}

extension GroupGetId {
  public static let unimplemented = GroupGetId(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
