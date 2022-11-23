import Bindings

public struct DummyTraffic {
  public var getStatus: DummyTrafficGetStatus
  public var setStatus: DummyTrafficSetStatus
}

extension DummyTraffic {
  public static func live(_ bindingsDummyTraffic: BindingsDummyTraffic) -> DummyTraffic {
    DummyTraffic(
      getStatus: .live(bindingsDummyTraffic),
      setStatus: .live(bindingsDummyTraffic)
    )
  }
}

extension DummyTraffic {
  public static let unimplemented = DummyTraffic(
    getStatus: .unimplemented,
    setStatus: .unimplemented
  )
}
