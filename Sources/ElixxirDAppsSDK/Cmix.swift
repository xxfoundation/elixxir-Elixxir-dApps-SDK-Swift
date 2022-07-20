import Bindings

public struct Cmix {
  public var makeReceptionIdentity: MakeReceptionIdentity
}

extension Cmix {
  public static func live(_ bindingsCmix: BindingsCmix) -> Cmix {
    Cmix(
      makeReceptionIdentity: .live(bindingsCmix)
    )
  }
}

extension Cmix {
  public static let unimplemented = Cmix(
    makeReceptionIdentity: .unimplemented
  )
}
