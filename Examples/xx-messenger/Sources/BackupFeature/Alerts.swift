import ComposableArchitecture

extension AlertState where Action == BackupAction {
  public static func error(_ error: Error) -> AlertState<BackupAction> {
    AlertState(
      title: TextState("Error"),
      message: TextState(error.localizedDescription)
    )
  }
}
