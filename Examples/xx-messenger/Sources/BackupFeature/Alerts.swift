import ComposableArchitecture

extension AlertState where Action == BackupComponent.Action {
  public static func error(_ error: Error) -> AlertState<BackupComponent.Action> {
    AlertState<BackupComponent.Action>(
      title: TextState("Error"),
      message: TextState(error.localizedDescription)
    )
  }
}
