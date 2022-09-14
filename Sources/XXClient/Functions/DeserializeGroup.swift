import Bindings
import XCTestDynamicOverlay

public struct DeserializeGroup {
  public var run: (Data) throws -> Group

  public func callAsFunction(_ serializedGroupData: Data) throws -> Group {
    try run(serializedGroupData)
  }
}

extension DeserializeGroup {
  public static func live() -> DeserializeGroup {
    DeserializeGroup { serializedGroupData in
      var error: NSError?
      let bindingsGroup = BindingsDeserializeGroup(serializedGroupData, &error)
      if let error = error {
        throw error
      }
      guard let bindingsGroup = bindingsGroup else {
        fatalError("BindingsDeserializeGroup returned `nil` without providing error")
      }
      return .live(bindingsGroup)
    }
  }
}

extension DeserializeGroup {
  public static let unimplemented = DeserializeGroup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
