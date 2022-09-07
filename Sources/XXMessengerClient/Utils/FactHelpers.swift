import XXClient

extension Array where Element == Fact {
  public var username: String? {
    get { first(where: { $0.type == 0 })?.fact }
    set {
      removeAll(where: { $0.type == 0 })
      if let newValue = newValue {
        append(Fact(fact: newValue, type: 0))
        sort(by: { $0.type < $1.type })
      }
    }
  }

  public var email: String? {
    get { first(where: { $0.type == 1 })?.fact }
    set {
      removeAll(where: { $0.type == 1 })
      if let newValue = newValue {
        append(Fact(fact: newValue, type: 1))
        sort(by: { $0.type < $1.type })
      }
    }
  }

  public var phone: String? {
    get { first(where: { $0.type == 2 })?.fact }
    set {
      removeAll(where: { $0.type == 2 })
      if let newValue = newValue {
        append(Fact(fact: newValue, type: 2))
        sort(by: { $0.type < $1.type })
      }
    }
  }
}
