import Bindings

public struct Cmix {
  public var getId: CmixGetId
  public var makeReceptionIdentity: MakeReceptionIdentity
}

extension Cmix {
  public static func live(_ bindingsCmix: BindingsCmix) -> Cmix {
    Cmix(
      getId: .live(bindingsCmix),
      makeReceptionIdentity: .live(bindingsCmix)
    )
  }
}

extension Cmix {
  public static let unimplemented = Cmix(
    getId: .unimplemented,
    makeReceptionIdentity: .unimplemented
  )
}
