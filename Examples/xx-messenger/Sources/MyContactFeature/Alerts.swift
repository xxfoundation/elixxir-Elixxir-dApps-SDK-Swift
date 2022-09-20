import ComposableArchitecture

extension AlertState {
  public static func error(_ message: String) -> AlertState<MyContactAction> {
    AlertState<MyContactAction>(
      title: TextState("Error"),
      message: TextState(message),
      buttons: []
    )
  }
}
