import ComposableArchitecture

extension AlertState {
  public static func confirmAccountDeletion() -> AlertState<HomeComponent.Action> {
    AlertState<HomeComponent.Action>(
      title: TextState("Delete Account"),
      message: TextState("This will permanently delete your account and can't be undone."),
      buttons: [
        .destructive(TextState("Delete"), action: .send(.deleteAccount(.confirmed))),
        .cancel(TextState("Cancel"))
      ]
    )
  }

  public static func accountDeletionFailed(_ error: Error) -> AlertState<HomeComponent.Action> {
    AlertState<HomeComponent.Action>(
      title: TextState("Error"),
      message: TextState(error.localizedDescription),
      buttons: []
    )
  }
}
