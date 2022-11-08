import XCTestDynamicOverlay
import XXClient

public struct MessengerTrackServices {
  public enum Error: Swift.Error, Equatable {
    case notLoaded
    case notConnected
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
      guard let e2e = env.e2e() else {
        throw Error.notConnected
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
      try cMix.trackServicesWithIdentity(
        e2eId: e2e.getId(),
        callback: callback
      )
    }
  }
}

extension MessengerTrackServices {
  public static let unimplemented = MessengerTrackServices(
    run: XCTUnimplemented("\(Self.self)")
  )
}
