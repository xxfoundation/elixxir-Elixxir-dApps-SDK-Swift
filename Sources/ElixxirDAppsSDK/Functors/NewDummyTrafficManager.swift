import Bindings
import XCTestDynamicOverlay

public struct NewDummyTrafficManager {
  public var run: (Int, Int, Int, Int) throws -> DummyTraffic

  public func callAsFunction(
    cMixId: Int,
    maxNumMessages: Int,
    avgSendDeltaMS: Int,
    randomRangeMS: Int
  ) throws -> DummyTraffic {
    try run(cMixId, maxNumMessages, avgSendDeltaMS, randomRangeMS)
  }
}

extension NewDummyTrafficManager {
  public static let live = NewDummyTrafficManager {
    cMixId, maxNumMessages, avgSendDeltaMS, randomRangeMS in

    var error: NSError?
    let bindingsDummyTraffic = BindingsNewDummyTrafficManager(
      cMixId,
      maxNumMessages,
      avgSendDeltaMS,
      randomRangeMS,
      &error
    )
    guard let bindingsDummyTraffic = bindingsDummyTraffic else {
      fatalError("BindingsNewDummyTrafficManager returned `nil` without providing error")
    }
    return .live(bindingsDummyTraffic)
  }
}

extension NewDummyTrafficManager {
  public static let unimplemented = NewDummyTrafficManager(
    run: XCTUnimplemented("\(Self.self)")
  )
}
