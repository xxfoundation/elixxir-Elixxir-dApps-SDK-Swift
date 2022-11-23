import Bindings
import XCTestDynamicOverlay

public struct UdNetworkStatus {
  public init(handle: @escaping () -> NetworkFollowerStatus) {
    self.handle = handle
  }

  public var handle: () -> NetworkFollowerStatus
}

extension UdNetworkStatus {
  public static let unimplemented = UdNetworkStatus(
    handle: XCTUnimplemented("\(Self.self)", placeholder: .unknown(code: -1))
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
        callback.handle().rawValue
      }
    }

    return CallbackObject(self)
  }
}
