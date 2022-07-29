import Bindings
import XCTestDynamicOverlay

public struct NewBroadcastChannel {
  public var run: (Int, ChannelDef) throws -> Channel

  public func callAsFunction(
    cmixId: Int,
    channelDef: ChannelDef
  ) throws -> Channel {
    try run(cmixId, channelDef)
  }
}

extension NewBroadcastChannel {
  public static let live = NewBroadcastChannel { cmixId, channelDef in
    var error: NSError?
    let bindingsChannel = BindingsNewBroadcastChannel(
      cmixId,
      try channelDef.encode(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsChannel = bindingsChannel else {
      fatalError("BindingsNewBroadcastChannel returned `nil` without providing error")
    }
    return .live(bindingsChannel)
  }
}

extension NewBroadcastChannel {
  public static let unimplemented = NewBroadcastChannel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
