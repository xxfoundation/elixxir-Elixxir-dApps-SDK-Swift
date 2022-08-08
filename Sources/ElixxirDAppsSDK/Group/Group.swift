import Bindings
import XCTestDynamicOverlay

public struct Group {
  public var getCreatedMS: GroupGetCreatedMS
  public var getCreatedNano: GroupGetCreatedNano
  public var getId: GroupGetId
  public var getInitMessage: GroupGetInitMessage
  public var getMembership: GroupGetMembership
  public var getName: GroupGetName
  public var getTrackedID: GroupGetTrackedId
  public var serialize: GroupSerialize
}

extension Group {
  public static func live(_ bindingsGroup: BindingsGroup) -> Group {
    Group(
      getCreatedMS: .live(bindingsGroup),
      getCreatedNano: .live(bindingsGroup),
      getId: .live(bindingsGroup),
      getInitMessage: .live(bindingsGroup),
      getMembership: .live(bindingsGroup),
      getName: .live(bindingsGroup),
      getTrackedID: .live(bindingsGroup),
      serialize: .live(bindingsGroup)
    )
  }
}

extension Group {
  public static let unimplemented = Group(
    getCreatedMS: .unimplemented,
    getCreatedNano: .unimplemented,
    getId: .unimplemented,
    getInitMessage: .unimplemented,
    getMembership: .unimplemented,
    getName: .unimplemented,
    getTrackedID: .unimplemented,
    serialize: .unimplemented
  )
}
