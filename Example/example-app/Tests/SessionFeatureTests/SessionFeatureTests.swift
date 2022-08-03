import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import XCTest
@testable import SessionFeature

final class SessionFeatureTests: XCTestCase {
  func testViewDidLoad() {
    var networkFollowerStatus: NetworkFollowerStatus!
    var didStartMonitoringNetworkHealth = 0
    var didStopMonitoringNetworkHealth = 0
    var networkHealthCallback: HealthCallback!
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: SessionState(id: UUID()),
      reducer: sessionReducer,
      environment: .unimplemented
    )

    store.environment.getCmix = {
      var cmix = Cmix.unimplemented
      cmix.networkFollowerStatus.run = { networkFollowerStatus }
      cmix.addHealthCallback.run = { callback in
        networkHealthCallback = callback
        didStartMonitoringNetworkHealth += 1
        return Cancellable {
          didStopMonitoringNetworkHealth += 1
        }
      }
      return cmix
    }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.viewDidLoad)

    store.receive(.updateNetworkFollowerStatus)
    store.receive(.monitorNetworkHealth(true))

    networkFollowerStatus = .stopped
    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didUpdateNetworkFollowerStatus(.stopped)) {
      $0.networkFollowerStatus = .stopped
    }

    XCTAssertEqual(didStartMonitoringNetworkHealth, 1)
    XCTAssertEqual(didStopMonitoringNetworkHealth, 0)

    networkHealthCallback.handle(true)
    bgScheduler.advance()
    mainScheduler.advance()

    store.receive(.didUpdateNetworkHealth(true)) {
      $0.isNetworkHealthy = true
    }

    store.send(.monitorNetworkHealth(false))

    bgScheduler.advance()

    XCTAssertEqual(didStartMonitoringNetworkHealth, 1)
    XCTAssertEqual(didStopMonitoringNetworkHealth, 1)
  }

  func testStartStopNetworkFollower() {
    var networkFollowerStatus: NetworkFollowerStatus!
    var didStartNetworkFollowerWithTimeout = [Int]()
    var didStopNetworkFollower = 0
    var networkFollowerStartError: NSError?
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    let store = TestStore(
      initialState: SessionState(id: UUID()),
      reducer: sessionReducer,
      environment: .unimplemented
    )

    store.environment.getCmix = {
      var cmix = Cmix.unimplemented
      cmix.networkFollowerStatus.run = { networkFollowerStatus }
      cmix.startNetworkFollower.run = {
        didStartNetworkFollowerWithTimeout.append($0)
        if let error = networkFollowerStartError {
          throw error
        }
      }
      cmix.stopNetworkFollower.run = {
        didStopNetworkFollower += 1
      }
      return cmix
    }
    store.environment.bgScheduler = bgScheduler.eraseToAnyScheduler()
    store.environment.mainScheduler = mainScheduler.eraseToAnyScheduler()

    store.send(.runNetworkFollower(true))

    networkFollowerStatus = .running
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000])
    XCTAssertEqual(didStopNetworkFollower, 0)

    store.receive(.didUpdateNetworkFollowerStatus(.running)) {
      $0.networkFollowerStatus = .running
    }

    store.send(.runNetworkFollower(false))

    networkFollowerStatus = .stopped
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000])
    XCTAssertEqual(didStopNetworkFollower, 1)

    store.receive(.didUpdateNetworkFollowerStatus(.stopped)) {
      $0.networkFollowerStatus = .stopped
    }

    store.send(.runNetworkFollower(true))

    networkFollowerStartError = NSError(domain: "test", code: 1234)
    networkFollowerStatus = .stopped
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000, 30_000])
    XCTAssertEqual(didStopNetworkFollower, 1)

    store.receive(.networkFollowerDidFail(networkFollowerStartError!)) {
      $0.error = ErrorState(error: networkFollowerStartError!)
    }

    store.receive(.didUpdateNetworkFollowerStatus(.stopped))

    store.send(.didDismissError) {
      $0.error = nil
    }
  }
}
