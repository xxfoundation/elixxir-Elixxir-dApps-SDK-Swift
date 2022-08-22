import XXClient
import XCTestDynamicOverlay

public struct MessengerCMix {
  public var get: () -> CMix?
  public var set: (CMix?) -> Void

  public func callAsFunction() -> CMix? {
    get()
  }
}

extension MessengerCMix {
  public static func live() -> MessengerCMix {
    class Storage { var value: CMix? }
    let storage = Storage()
    return MessengerCMix(
      get: { storage.value },
      set: { storage.value = $0 }
    )
  }
}

extension MessengerCMix {
  public static let unimplemented = MessengerCMix(
    get: XCTUnimplemented("\(Self.self).get", placeholder: nil),
    set: XCTUnimplemented("\(Self.self).set")
  )
}
