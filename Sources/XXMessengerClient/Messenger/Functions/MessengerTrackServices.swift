import XCTestDynamicOverlay
import XXClient

public struct MessengerTrackServices {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
  }

  public typealias OnError = (Swift.Error) -> Void

  public var run: (@escaping OnError) throws -> Void

  public func callAsFunction(onError: @escaping OnError) throws {
    try run(onError)
  }
}

extension MessengerTrackServices {
  public static func live(_ env: MessengerEnvironment) -> MessengerTrackServices {
    MessengerTrackServices { onError in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      let callback = TrackServicesCallback { result in
        switch result {
        case .success(let serviceList):
          env.serviceList.set(serviceList)
        case .failure(let error):
          env.serviceList.set(nil)
          onError(error)
        }
      }
      cMix.trackServices(callback: callback)
    }
  }
}

extension MessengerTrackServices {
  public static let unimplemented = MessengerTrackServices(
    run: XCTUnimplemented("\(Self.self)")
  )
}
