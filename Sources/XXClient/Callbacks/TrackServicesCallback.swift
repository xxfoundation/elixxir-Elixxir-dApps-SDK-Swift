import Bindings
import XCTestDynamicOverlay

public struct TrackServicesCallback {
  public init(handle: @escaping (Result<Data, Error>) -> Void) {
    self.handle = handle
  }

  public var handle: (Result<Data, Error>) -> Void
}

extension TrackServicesCallback {
  public static let unimplemented = HealthCallback(
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension TrackServicesCallback {
  func makeBindingsHealthCallback() -> BindingsTrackServicesCallbackProtocol {
    class CallbackObject: NSObject, BindingsTrackServicesCallbackProtocol {
      init(_ callback: TrackServicesCallback) {
        self.callback = callback
      }

      let callback: TrackServicesCallback

      func callback(_ marshalData: Data?, err: Error?) {
        if let err = err {
          callback.handle(.failure(err))
          return
        }
        if let marshalData = marshalData {
          callback.handle(.success(marshalData))
          return
        }
        fatalError("BindingsTrackServicesCallback received nil marshalData and err")
      }
    }

    return CallbackObject(self)
  }
}
