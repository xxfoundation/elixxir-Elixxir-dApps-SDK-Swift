import Bindings
import XCTestDynamicOverlay

public struct UdNetworkStatus {
  public init(handle: @escaping () -> Int) {
    self.handle = handle
  }

  public var handle: () -> Int
}

extension UdNetworkStatus {
  public static let unimplemented = UdNetworkStatus(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension UdNetworkStatus {
  func makeBindingsUdNetworkStatus() -> BindingsUdNetworkStatusProtocol {
    class CallbackObject: NSObject, BindingsUdNetworkStatusProtocol {
      init(_ callback: UdNetworkStatus) {
        self.callback = callback
      }

      let callback: UdNetworkStatus

      func udNetworkStatus() -> Int {
        callback.handle()
      }
    }

    return CallbackObject(self)
  }
}
