import Bindings
import XCTestDynamicOverlay

public struct ChannelGet {
  public var run: () throws -> ChannelDef

  public func callAsFunction() throws -> ChannelDef {
    try run()
  }
}

extension ChannelGet {
  public static func live(_ bindingsChannel: BindingsChannel) -> ChannelGet {
    ChannelGet {
      try ChannelDef.decode(bindingsChannel.get())
    }
  }
}

extension ChannelGet {
  public static let unimplemented = ChannelGet(
    run: XCTUnimplemented("\(Self.self)")
  )
}
