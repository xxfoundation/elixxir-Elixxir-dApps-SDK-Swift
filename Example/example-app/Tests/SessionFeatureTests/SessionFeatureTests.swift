import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import MyIdentityFeature
import XCTest
@testable import SessionFeature

final class SessionFeatureTests: XCTestCase {
  func testViewDidLoad() {
    var networkFollowerStatus: NetworkFollowerStatus!
    var didStartMonitoringNetworkHealth = 0
    var didStopMonitoringNetworkHealth = 0
    var networkHealthCallback: ((Bool) -> Void)!
    let bgScheduler = DispatchQueue.test
    let mainScheduler = DispatchQueue.test

    var env = SessionEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.networkFollower.status.status = { networkFollowerStatus }
      client.monitorNetworkHealth.listen = { callback in
        networkHealthCallback = callback
        didStartMonitoringNetworkHealth += 1
        return Cancellable {
          didStopMonitoringNetworkHealth += 1
        }
      }
      return client
    }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: SessionState(id: UUID()),
      reducer: sessionReducer,
      environment: env
    )

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

    networkHealthCallback(true)
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

    var env = SessionEnvironment.failing
    env.getClient = {
      var client = Client.failing
      client.networkFollower.status.status = {
        networkFollowerStatus
      }
      client.networkFollower.start.start = {
        didStartNetworkFollowerWithTimeout.append($0)
        if let error = networkFollowerStartError {
          throw error
        }
      }
      client.networkFollower.stop.stop = {
        didStopNetworkFollower += 1
      }
      return client
    }
    env.bgScheduler = bgScheduler.eraseToAnyScheduler()
    env.mainScheduler = mainScheduler.eraseToAnyScheduler()

    let store = TestStore(
      initialState: SessionState(id: UUID()),
      reducer: sessionReducer,
      environment: env
    )

    store.send(.runNetworkFollower(true)) {
      $0.networkFollowerStatus = .starting
    }

    networkFollowerStatus = .running
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000])
    XCTAssertEqual(didStopNetworkFollower, 0)

    store.receive(.didUpdateNetworkFollowerStatus(.running)) {
      $0.networkFollowerStatus = .running
    }

    store.send(.runNetworkFollower(false)) {
      $0.networkFollowerStatus = .stopping
    }

    networkFollowerStatus = .stopped
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000])
    XCTAssertEqual(didStopNetworkFollower, 1)

    store.receive(.didUpdateNetworkFollowerStatus(.stopped)) {
      $0.networkFollowerStatus = .stopped
    }

    store.send(.runNetworkFollower(true)) {
      $0.networkFollowerStatus = .starting
    }

    networkFollowerStartError = NSError(domain: "test", code: 1234)
    networkFollowerStatus = .stopped
    bgScheduler.advance()
    mainScheduler.advance()

    XCTAssertEqual(didStartNetworkFollowerWithTimeout, [30_000, 30_000])
    XCTAssertEqual(didStopNetworkFollower, 1)

    store.receive(.networkFollowerDidFail(networkFollowerStartError!)) {
      $0.error = ErrorState(error: networkFollowerStartError!)
    }

    store.receive(.didUpdateNetworkFollowerStatus(.stopped)) {
      $0.networkFollowerStatus = .stopped
    }

    store.send(.didDismissError) {
      $0.error = nil
    }
  }

  func testPresentingMyIdentity() {
    let newId = UUID()

    var env = SessionEnvironment.failing
    env.makeId = { newId }

    let store = TestStore(
      initialState: SessionState(id: UUID()),
      reducer: sessionReducer,
      environment: env
    )

    store.send(.presentMyIdentity) {
      $0.myIdentity = MyIdentityState(id: newId)
    }

    store.send(.didDismissMyIdentity) {
      $0.myIdentity = nil
    }
  }
}
