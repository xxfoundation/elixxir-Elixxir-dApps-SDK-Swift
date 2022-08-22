import XXClient
import XCTestDynamicOverlay

public struct MessengerContext {
  public var getCMix: () -> CMix?
  public var setCMix: (CMix?) -> Void
  public var getE2E: () -> E2E?
  public var setE2E: (E2E?) -> Void
  public var getUD: () -> UserDiscovery?
  public var setUD: (UserDiscovery?) -> Void
}

extension MessengerContext {
  public static func live() -> MessengerContext {
    class Container {
      var cMix: CMix?
      var e2e: E2E?
      var ud: UserDiscovery?
    }
    let container = Container()

    return MessengerContext(
      getCMix: { container.cMix },
      setCMix: { container.cMix = $0 },
      getE2E: { container.e2e },
      setE2E: { container.e2e = $0 },
      getUD: { container.ud },
      setUD: { container.ud = $0 }
    )
  }
}

extension MessengerContext {
  public static let unimplemented = MessengerContext(
    getCMix: XCTUnimplemented("\(Self.self).getCMix"),
    setCMix: XCTUnimplemented("\(Self.self).setCMix"),
    getE2E: XCTUnimplemented("\(Self.self).getE2E"),
    setE2E: XCTUnimplemented("\(Self.self).setE2E"),
    getUD: XCTUnimplemented("\(Self.self).getUD"),
    setUD: XCTUnimplemented("\(Self.self).setUD")
  )
}
