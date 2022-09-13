import Foundation
import XCTestDynamicOverlay
import XXClient

public struct MessengerSendMessage {
  public struct DeliveryReport: Equatable {
    public enum Result: Equatable {
      case delivered
      case notDelivered(timedOut: Bool)
      case failure(NSError)
    }

    public init(
      report: E2ESendReport,
      result: Result
    ) {
      self.report = report
      self.result = result
    }

    public var report: E2ESendReport
    public var result: Result
  }

  public typealias DeliveryCallback = (DeliveryReport) -> Void

  public enum Error: Swift.Error, Equatable {
    case notLoaded
    case notConnected
  }

  public var run: (Data, Data, DeliveryCallback?) throws -> E2ESendReport

  public func callAsFunction(
    recipientId: Data,
    payload: Data,
    deliveryCallback: DeliveryCallback?
  ) throws -> E2ESendReport {
    try run(recipientId, payload, deliveryCallback)
  }
}

extension MessengerSendMessage {
  public static func live(_ env: MessengerEnvironment) -> MessengerSendMessage {
    MessengerSendMessage { recipientId, payload, deliveryCallback in
      guard let cMix = env.cMix() else {
        throw Error.notLoaded
      }
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      let report = try e2e.send(
        messageType: 2,
        recipientId: recipientId,
        payload: payload,
        e2eParams: env.getE2EParams()
      )
      if let deliveryCallback = deliveryCallback {
        do {
          try cMix.waitForRoundResult(
            roundList: try report.encode(),
            timeoutMS: 30_000,
            callback: .init { result in
              switch result {
              case .delivered(_):
                deliveryCallback(.init(report: report, result: .delivered))
              case .notDelivered(let timedOut):
                deliveryCallback(.init(report: report, result: .notDelivered(timedOut: timedOut)))
              }
            }
          )
        } catch {
          deliveryCallback(.init(report: report, result: .failure(error as NSError)))
        }
      }
      return report
    }
  }
}

extension MessengerSendMessage {
  public static let unimplemented = MessengerSendMessage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
