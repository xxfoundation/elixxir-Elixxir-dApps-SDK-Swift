import Foundation
import XCTestDynamicOverlay
import XXClient

public struct GroupChatProcessorRegistry {
  public var register: (GroupChatProcessor) -> Cancellable
  public var registered: () -> GroupChatProcessor
}

extension GroupChatProcessorRegistry {
  public static func live() -> GroupChatProcessorRegistry {
    class Registry {
      var items: [UUID: GroupChatProcessor] = [:]
    }
    let registry = Registry()
    return GroupChatProcessorRegistry(
      register: { processor in
        let id = UUID()
        registry.items[id] = processor
        return Cancellable { registry.items[id] = nil }
      },
      registered: {
        GroupChatProcessor(
          name: "GroupChatProcessorRegistry.registered",
          handle: { result in
            registry.items.values.forEach { $0.handle(result) }
          }
        )
      }
    )
  }
}

extension GroupChatProcessorRegistry {
  public static let unimplemented = GroupChatProcessorRegistry(
    register: XCTestDynamicOverlay.unimplemented(
      "\(Self.self).register",
      placeholder: Cancellable {}
    ),
    registered: XCTestDynamicOverlay.unimplemented(
      "\(Self.self).registered",
      placeholder: .unimplemented
    )
  )
}
