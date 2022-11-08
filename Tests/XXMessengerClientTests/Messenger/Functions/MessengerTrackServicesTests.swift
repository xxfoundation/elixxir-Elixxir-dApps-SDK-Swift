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
    let e2eId = 123

    var didTrackServicesWithIdentity: [Int] = []
    var didSetServiceList: [MessageServiceList?] = []
    var didReceiveError: [Error] = []
    var callbacks: [TrackServicesCallback] = []

    var env: MessengerEnvironment = .unimplemented
    env.serviceList.set = { serviceList in
      didSetServiceList.append(serviceList)
    }
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.trackServicesWithIdentity.run = { e2eId, callback in
        didTrackServicesWithIdentity.append(e2eId)
        callbacks.append(callback)
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getId.run = { e2eId }
      return e2e
    }
    let track: MessengerTrackServices = .live(env)

    try track(onError: { error in
      didReceiveError.append(error)
    })

    XCTAssertNoDifference(didTrackServicesWithIdentity, [e2eId])
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
        error as? MessengerTrackServices.Error,
        .notLoaded
      )
    }
  }

  func testTrackWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { .unimplemented }
    env.e2e.get = { nil }
    let track: MessengerTrackServices = .live(env)

    XCTAssertThrowsError(try track(onError: unimplemented())) { error in
      XCTAssertNoDifference(
        error as? MessengerTrackServices.Error,
        .notConnected
      )
    }
  }
}
