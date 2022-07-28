import Bindings
import XCTestDynamicOverlay

public struct Listener {
  public init(
    name: String = "Listener",
    handle: @escaping (Message) -> Void
  ) {
    self.name = name
    self.handle = handle
  }

  public var name: String
  public var handle: (Message) -> Void
}

extension Listener {
  public static let unimplemented = Listener(
    name: "unimplemented",
    handle: XCTUnimplemented("\(Self.self)")
  )
}

extension Listener {
  func makeBindingsListener() -> BindingsListenerProtocol {
    class CallbackObject: NSObject, BindingsListenerProtocol {
      init(_ callback: Listener) {
        self.callback = callback
      }

      let callback: Listener

      func hear(_ item: Data?) {
        guard let item = item else {
          fatalError("BindingsListener.hear received `nil`")
        }
        do {
          callback.handle(try Message.decode(item))
        } catch {
          fatalError("BindingsListener.hear message decoding failed with error: \(error)")
        }
      }

      func name() -> String {
        callback.name
      }
    }

    return CallbackObject(self)
  }
}
