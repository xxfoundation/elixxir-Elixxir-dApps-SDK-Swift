import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class WaitForNodesTests: XCTestCase {
  func testWaitWhenNotLoaded() {
    var env: Environment = .unimplemented
    env.cMix.get = { nil }
    let waitForNodes: WaitForNodes = .live(env)

    XCTAssertThrowsError(try waitForNodes()) { error in
      XCTAssertEqual(
        error as? WaitForNodes.Error,
        WaitForNodes.Error.notLoaded
      )
    }
  }

  func testWaitWhenHasTargetRatio() throws {
    var didProgress: [NodeRegistrationReport] = []

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getNodeRegistrationStatus.run = {
        NodeRegistrationReport(registered: 8, total: 10)
      }
      return cMix
    }
    let waitForNodes: WaitForNodes = .live(env)

    try waitForNodes(
      targetRatio: 0.7,
      sleepMS: 123,
      retries: 3,
      onProgress: { didProgress.append($0) }
    )

    XCTAssertNoDifference(didProgress, [
      NodeRegistrationReport(registered: 8, total: 10)
    ])
  }

  func testWaitForTargetRatio() throws {
    var didSleep: [Int] = []
    var didProgress: [NodeRegistrationReport] = []

    var reports: [NodeRegistrationReport] = [
      .init(registered: 0, total: 10),
      .init(registered: 3, total: 10),
      .init(registered: 8, total: 10),
    ]

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getNodeRegistrationStatus.run = { reports.removeFirst() }
      return cMix
    }
    env.sleep = { didSleep.append($0) }
    let waitForNodes: WaitForNodes = .live(env)

    try waitForNodes(
      targetRatio: 0.7,
      sleepMS: 123,
      retries: 3,
      onProgress: { didProgress.append($0) }
    )

    XCTAssertNoDifference(didSleep, [123, 123])
    XCTAssertNoDifference(didProgress, [
      NodeRegistrationReport(registered: 0, total: 10),
      NodeRegistrationReport(registered: 3, total: 10),
      NodeRegistrationReport(registered: 8, total: 10),
    ])
  }

  func testWaitTimeout() {
    var didSleep: [Int] = []
    var didProgress: [NodeRegistrationReport] = []

    var reports: [NodeRegistrationReport] = [
      .init(registered: 0, total: 10),
      .init(registered: 3, total: 10),
      .init(registered: 5, total: 10),
      .init(registered: 6, total: 10),
    ]

    var env: Environment = .unimplemented
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.getNodeRegistrationStatus.run = { reports.removeFirst() }
      return cMix
    }
    env.sleep = { didSleep.append($0) }
    let waitForNodes: WaitForNodes = .live(env)

    XCTAssertThrowsError(try waitForNodes(
      targetRatio: 0.7,
      sleepMS: 123,
      retries: 3,
      onProgress: { didProgress.append($0) }
    )) { error in
      XCTAssertEqual(
        error as? WaitForNodes.Error,
        WaitForNodes.Error.timeout
      )
    }

    XCTAssertNoDifference(didSleep, [123, 123, 123])
    XCTAssertNoDifference(didProgress, [
      NodeRegistrationReport(registered: 0, total: 10),
      NodeRegistrationReport(registered: 3, total: 10),
      NodeRegistrationReport(registered: 5, total: 10),
      NodeRegistrationReport(registered: 6, total: 10),
    ])
  }
}
