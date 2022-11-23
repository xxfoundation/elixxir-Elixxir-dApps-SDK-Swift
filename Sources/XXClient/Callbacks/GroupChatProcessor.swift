import Bindings
import XCTestDynamicOverlay

public struct GroupChatProcessor {
  public typealias Result = Swift.Result<Callback, NSError>

  public struct Callback: Equatable {
    public init(
      decryptedMessage: GroupChatMessage,
      msg: Data,
      receptionId: Data,
      ephemeralId: Int64,
      roundId: Int64,
      roundUrl: String
    ) {
      self.decryptedMessage = decryptedMessage
      self.msg = msg
      self.receptionId = receptionId
      self.ephemeralId = ephemeralId
      self.roundId = roundId
      self.roundUrl = roundUrl
    }

    public var decryptedMessage: GroupChatMessage
    public var msg: Data
    public var receptionId: Data
    public var ephemeralId: Int64
    public var roundId: Int64
    public var roundUrl: String
  }

  public init(
    name: String = "GroupChatProcessor",
    handle: @escaping (Result) -> Void
  ) {
    self.name = name
    self.handle = handle
  }

  public var name: String
  public var handle: (Result) -> Void
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
        roundUrl: String?,
        err: Error?
      ) {
        if let err = err {
          callback.handle(.failure(err as NSError))
          return
        }
        guard let decryptedMessage else {
          fatalError("BindingsGroupChatProcessor received `nil` decryptedMessage")
        }
        guard let msg else {
          fatalError("BindingsGroupChatProcessor received `nil` msg")
        }
        guard let receptionId else {
          fatalError("BindingsGroupChatProcessor received `nil` receptionId")
        }
        guard let roundUrl else {
          fatalError("BindingsGroupChatProcessor received `nil` roundUrl")
        }
        do {
          callback.handle(.success(.init(
            decryptedMessage: try GroupChatMessage.decode(decryptedMessage),
            msg: msg,
            receptionId: receptionId,
            ephemeralId: ephemeralId,
            roundId: roundId,
            roundUrl: roundUrl
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
