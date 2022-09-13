import Bindings
import XCTestDynamicOverlay

public struct GroupChatProcessor {
  public struct Callback: Equatable {
    public init(
      decryptedMessage: GroupChatMessage,
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

    public var decryptedMessage: GroupChatMessage
    public var msg: Data
    public var receptionId: Data
    public var ephemeralId: Int64
    public var roundId: Int64
  }

  public init(
    name: String = "GroupChatProcessor",
    handle: @escaping (Result<Callback, NSError>) -> Void
  ) {
    self.name = name
    self.handle = handle
  }

  public var name: String
  public var handle: (Result<Callback, NSError>) -> Void
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
        if let err = err {
          callback.handle(.failure(err as NSError))
          return
        }
        guard let decryptedMessage = decryptedMessage else {
          fatalError("BindingsGroupChatProcessor received `nil` decryptedMessage")
        }
        guard let msg = msg else {
          fatalError("BindingsGroupChatProcessor received `nil` msg")
        }
        guard let receptionId = receptionId else {
          fatalError("BindingsGroupChatProcessor received `nil` receptionId")
        }
        do {
          callback.handle(.success(.init(
            decryptedMessage: try GroupChatMessage.decode(decryptedMessage),
            msg: msg,
            receptionId: receptionId,
            ephemeralId: ephemeralId,
            roundId: roundId
          )))
        } catch {
          callback.handle(.failure(error as NSError))
        }
      }

      func string() -> String {
        callback.name
      }
    }

    return CallbackObject(self)
  }
}
