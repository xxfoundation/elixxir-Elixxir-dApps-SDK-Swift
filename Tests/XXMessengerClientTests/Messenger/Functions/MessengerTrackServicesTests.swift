import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
@testable import XXMessengerClient

final class MessengerTrackServicesTests: XCTestCase {
  func testTrack() throws {
    struct Failure: Error, Equatable {}
    let failure = Failure()
    let serviceList = MessageServiceList.stub()

    var didSetServiceList: [MessageServiceList?] = []
    var didReceiveError: [Error] = []
    var callbacks: [TrackServicesCallback] = []

    var env: MessengerEnvironment = .unimplemented
    env.serviceList.set = { serviceList in
      didSetServiceList.append(serviceList)
    }
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.trackServices.run = { callback in
        callbacks.append(callback)
      }
      return cMix
    }
    let track: MessengerTrackServices = .live(env)

    try track(onError: { error in
      didReceiveError.append(error)
    })

    XCTAssertEqual(callbacks.count, 1)

    didSetServiceList = []
    didReceiveError = []
    callbacks.first?.handle(.success(serviceList))

    XCTAssertNoDifference(didSetServiceList, [serviceList])
    XCTAssertEqual(didReceiveError.count, 0)

    didSetServiceList = []
    didReceiveError = []
    callbacks.first?.handle(.failure(failure))

    XCTAssertNoDifference(didSetServiceList, [nil])
    XCTAssertEqual(didReceiveError.count, 1)
    XCTAssertNoDifference(didReceiveError.first as? Failure, failure)
  }

  func testTrackWhenNotLoaded() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let track: MessengerTrackServices = .live(env)

    XCTAssertThrowsError(try track(onError: unimplemented())) { error in
      XCTAssertNoDifference(
        error as NSError,
        MessengerTrackServices.Error.notLoaded as NSError
      )
    }
  }
}
