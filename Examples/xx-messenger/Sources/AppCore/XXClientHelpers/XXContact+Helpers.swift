import XXClient

extension Contact {
  public var username: String? {
    try? getFacts().first(where: { $0.type == 0 })?.fact
  }

  public var email: String? {
    try? getFacts().first(where: { $0.type == 1 })?.fact
  }

  public var phone: String? {
    try? getFacts().first(where: { $0.type == 2 })?.fact
  }
}
