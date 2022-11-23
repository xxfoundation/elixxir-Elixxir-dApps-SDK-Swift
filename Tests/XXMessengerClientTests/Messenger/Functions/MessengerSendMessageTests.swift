import CustomDump
import XCTest
import XXClient
@testable import XXMessengerClient

final class MessengerSendMessageTests: XCTestCase {
  func testSend() throws {
    struct E2ESendParams: Equatable {
      var messageType: Int
      var recipientId: Data
      var payload: Data
      var e2eParams: Data
    }
    var e2eDidSendWithParams: [E2ESendParams] = []

    let e2eSendReport = E2ESendReport(
      rounds: [1, 2, 3],
      roundURL: "round-url",
      messageId: "message-id".data(using: .utf8)!,
      timestamp: 123,
      keyResidue: "key-residue".data(using: .utf8)!
    )

    var env: MessengerEnvironment = .unimplemented
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.cMix.get = { .unimplemented }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.send.run = { messageType, recipientId, payload, e2eParams in
        e2eDidSendWithParams.append(.init(
          messageType: messageType,
          recipientId: recipientId,
          payload: payload,
          e2eParams: e2eParams
        ))
        return e2eSendReport
      }
      return e2e
    }
    let send: MessengerSendMessage = .live(env)

    let report = try send(
      recipientId: "recipient-id".data(using: .utf8)!,
      payload: "payload".data(using: .utf8)!,
      deliveryCallback: nil
    )

    XCTAssertNoDifference(e2eDidSendWithParams, [.init(
      messageType: 2,
      recipientId: "recipient-id".data(using: .utf8)!,
      payload: "payload".data(using: .utf8)!,
      e2eParams: "e2e-params".data(using: .utf8)!
    )])

    XCTAssertNoDifference(report, e2eSendReport)
  }

  func testSendWithDeliveryCallback() throws {
    struct WaitForRoundResultsParams: Equatable {
      var roundList: Data
      var timeoutMS: Int
    }
    var didWaitForRoundResultsWithParams: [WaitForRoundResultsParams] = []
    var didWaitForRoundResultsWithCallback: [MessageDeliveryCallback] = []
    var didReceiveDeliveryReport: [MessengerSendMessage.DeliveryReport] = []

    let e2eSendReport = E2ESendReport(
      rounds: [1, 2, 3],
      roundURL: "round-url",
      messageId: "message-id".data(using: .utf8)!,
      timestamp: 123,
      keyResidue: "key-residue".data(using: .utf8)!
    )

    var env: MessengerEnvironment = .unimplemented
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForRoundResult.run = { roundList, timeoutMS, callback in
        didWaitForRoundResultsWithParams.append(.init(roundList: roundList, timeoutMS: timeoutMS))
        didWaitForRoundResultsWithCallback.append(callback)
      }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.send.run = { _, _, _, _ in e2eSendReport }
      return e2e
    }
    let send: MessengerSendMessage = .live(env)

    let report = try send(
      recipientId: "recipient-id".data(using: .utf8)!,
      payload: "payload".data(using: .utf8)!,
      deliveryCallback: .init { deliveryReport in
        didReceiveDeliveryReport.append(deliveryReport)
      }
    )

    XCTAssertNoDifference(report, e2eSendReport)

    XCTAssertNoDifference(didWaitForRoundResultsWithParams, [
      .init(roundList: try! e2eSendReport.encode(), timeoutMS: 30_000),
    ])

    didWaitForRoundResultsWithCallback.first?.handle(.delivered(roundResults: [1, 2, 3]))

    XCTAssertNoDifference(didReceiveDeliveryReport, [
      .init(report: report, result: .delivered)
    ])

    didReceiveDeliveryReport.removeAll()
    didWaitForRoundResultsWithCallback.first?.handle(.notDelivered(timedOut: false))

    XCTAssertNoDifference(didReceiveDeliveryReport, [
      .init(report: report, result: .notDelivered(timedOut: false))
    ])

    didReceiveDeliveryReport.removeAll()
    didWaitForRoundResultsWithCallback.first?.handle(.notDelivered(timedOut: true))

    XCTAssertNoDifference(didReceiveDeliveryReport, [
      .init(report: report, result: .notDelivered(timedOut: true))
    ])
  }

  func testSendWhenNotLoaded() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { nil }
    let send: MessengerSendMessage = .live(env)

    XCTAssertThrowsError(
      try send(
        recipientId: Data(),
        payload: Data(),
        deliveryCallback: nil
      )
    ) { error in
      XCTAssertNoDifference(
        error as? MessengerSendMessage.Error,
        .notLoaded
      )
    }
  }

  func testSendWhenNotConnected() {
    var env: MessengerEnvironment = .unimplemented
    env.cMix.get = { .unimplemented }
    env.e2e.get = { nil }
    let send: MessengerSendMessage = .live(env)

    XCTAssertThrowsError(
      try send(
        recipientId: Data(),
        payload: Data(),
        deliveryCallback: nil
      )
    ) { error in
      XCTAssertNoDifference(
        error as? MessengerSendMessage.Error,
        .notConnected
      )
    }
  }

  func testSendFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()

    var env: MessengerEnvironment = .unimplemented
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.cMix.get = { .unimplemented }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.send.run = { _, _, _, _ in throw error }
      return e2e
    }
    let send: MessengerSendMessage = .live(env)

    XCTAssertThrowsError(
      try send(
        recipientId: "recipient-id".data(using: .utf8)!,
        payload: "payload".data(using: .utf8)!,
        deliveryCallback: nil
      )
    ) { err in
      XCTAssertNoDifference(err as? Failure, error)
    }
  }

  func testSendDeliveryFailure() throws {
    let e2eSendReport = E2ESendReport(
      rounds: [1, 2, 3],
      roundURL: "round-url",
      messageId: "message-id".data(using: .utf8)!,
      timestamp: 123,
      keyResidue: "key-residue".data(using: .utf8)!
    )

    struct Failure: Error {}
    let error = Failure()

    var didReceiveDeliveryReport: [MessengerSendMessage.DeliveryReport] = []

    var env: MessengerEnvironment = .unimplemented
    env.getE2EParams.run = { "e2e-params".data(using: .utf8)! }
    env.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForRoundResult.run = { _, _, _ in throw error }
      return cMix
    }
    env.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.send.run = { _, _, _, _ in e2eSendReport }
      return e2e
    }
    let send: MessengerSendMessage = .live(env)

    let report = try send(
      recipientId: "recipient-id".data(using: .utf8)!,
      payload: "payload".data(using: .utf8)!,
      deliveryCallback: .init { deliveryReport in
        didReceiveDeliveryReport.append(deliveryReport)
      }
    )

    XCTAssertNoDifference(report, e2eSendReport)

    XCTAssertNoDifference(didReceiveDeliveryReport, [
      .init(report: report, result: .failure(error as NSError))
    ])
  }
}
