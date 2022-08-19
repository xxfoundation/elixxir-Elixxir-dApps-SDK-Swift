import Bindings
import XCTestDynamicOverlay

public struct GroupChatProcessor {
  public struct Callback: Equatable {
    public init(
      decryptedMessage: Result<Data, NSError>,
      msg: Data,
      receptionId: Data,
      ephemeralId: Int64,
      roundId: Int64
    ) {
      self.decryptedMessage = decryptedMessage
      self.msg = msg
      self.receptionId = receptionId
      self.ephemeralId = ephemeralId
      self.roundId = roundId
    }

    public var decryptedMessage: Result<Data, NSError>
    public var msg: Data
    public var receptionId: Data
    public var ephemeralId: Int64
    public var roundId: Int64
  }

  public init(
    name: String = "GroupChatProcessor",
    handle: @escaping (Callback) -> Void
  ) {
    self.name = name
    self.handle = handle
  }

  public var name: String
  public var handle: (Callback) -> Void
}

extension GroupChatProcessor {
  public static let unimplemented = GroupChatProcessor(
    name: "GroupChatProcessor.unimplemented",
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension GroupChatProcessor {
  func makeBindingsGroupChatProcessor() -> BindingsGroupChatProcessorProtocol {
    class CallbackObject: NSObject, BindingsGroupChatProcessorProtocol {
      init(_ callback: GroupChatProcessor) {
        self.callback = callback
      }

      let callback: GroupChatProcessor

      func process(
        _ decryptedMessage: Data?,
        msg: Data?,
        receptionId: Data?,
        ephemeralId: Int64,
        roundId: Int64,
        err: Error?
      ) {
        guard let msg = msg else {
          fatalError("BindingsGroupChatProcessor received `nil` msg")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsGroupChatProcessor received `nil` receptionId")
        }
        let decryptedMessageResult: Result<Data, NSError>
        if let err = err {
          decryptedMessageResult = .failure(err as NSError)
        } else if let decryptedMessage = decryptedMessage {
          decryptedMessageResult = .success(decryptedMessage)
        } else {
          fatalError("BindingsGroupChatProcessor received `nil` decryptedMessage and `nil` error")
        }
        callback.handle(.init(
          decryptedMessage: decryptedMessageResult,
          msg: msg,
          receptionId: receptionId,
          ephemeralId: ephemeralId,
          roundId: roundId
        ))
      }

      func string() -> String {
        callback.name
      }
    }

    return CallbackObject(self)
  }
}
