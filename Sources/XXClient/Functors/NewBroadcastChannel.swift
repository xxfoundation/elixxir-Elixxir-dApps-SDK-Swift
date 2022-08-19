import Bindings
import XCTestDynamicOverlay

public struct NewBroadcastChannel {
  public var run: (Int, ChannelDef) throws -> Channel

  public func callAsFunction(
    cMixId: Int,
    channelDef: ChannelDef
  ) throws -> Channel {
    try run(cMixId, channelDef)
  }
}

extension NewBroadcastChannel {
  public static let live = NewBroadcastChannel { cMixId, channelDef in
    var error: NSError?
    let bindingsChannel = BindingsNewBroadcastChannel(
      cMixId,
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
