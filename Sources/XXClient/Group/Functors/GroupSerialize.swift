import Bindings
import XCTestDynamicOverlay

public struct GroupSerialize {
  public var run: () -> Data

  public func callAsFunction() -> Data {
    run()
  }
}

extension GroupSerialize {
  public static func live(_ bindingsGroup: BindingsGroup) -> GroupSerialize {
    GroupSerialize {
      guard let data = bindingsGroup.serialize() else {
        fatalError("BindingsGroup.serialize returned `nil`")
      }
      return data
    }
  }
}

extension GroupSerialize {
  public static let unimplemented = GroupSerialize(
    run: XCTUnimplemented("\(Self.self)", placeholder: "unimplemented".data(using: .utf8)!)
  )
}
