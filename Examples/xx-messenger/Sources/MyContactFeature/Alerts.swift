import ComposableArchitecture

extension AlertState {
  public static func error(_ message: String) -> AlertState<MyContactComponent.Action> {
    AlertState<MyContactComponent.Action>(
      title: TextState("Error"),
      message: TextState(message),
      buttons: []
    )
  }
}
