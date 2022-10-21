import ComposableArchitecture
import HomeFeature
import PulseUI
import RestoreFeature
import SwiftUI
import WelcomeFeature

struct AppView: View {
  let store: StoreOf<AppComponent>
  @State var isPresentingPulse = false

  enum ViewState: Equatable {
    case loading
    case welcome
    case restore
    case home
    case failure(String)

    init(_ state: AppComponent.State) {
      switch state.screen {
      case .loading: self = .loading
      case .welcome(_): self = .welcome
      case .restore(_): self = .restore
      case .home(_): self = .home
      case .failure(let failure): self = .failure(failure)
      }
    }
  }

  var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      ZStack {
        switch viewStore.state {
        case .loading:
          ProgressView {
            Text("Loading")
          }
          .controlSize(.large)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.opacity)

        case .welcome:
          IfLetStore(
            store.scope(
              state: { (/AppComponent.State.Screen.welcome).extract(from: $0.screen) },
              action: AppComponent.Action.welcome
            ),
            then: { store in
              WelcomeView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .opacity
                ))
            }
          )

        case .restore:
          IfLetStore(
            store.scope(
              state: { (/AppComponent.State.Screen.restore).extract(from: $0.screen) },
              action: AppComponent.Action.restore
            ),
            then: { store in
              RestoreView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .opacity
                ))
            }
          )

        case .home:
          IfLetStore(
            store.scope(
              state: { (/AppComponent.State.Screen.home).extract(from: $0.screen) },
              action: AppComponent.Action.home
            ),
            then: { store in
              HomeView(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                  insertion: .move(edge: .trailing),
                  removal: .opacity
                ))
            }
          )

        case .failure(let failure):
          NavigationView {
            VStack(spacing: 0) {
              ScrollView {
                Text(failure)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding()
              }

              Divider()

              Button {
                viewStore.send(.start)
              } label: {
                Text("Retry")
                  .frame(maxWidth: .infinity)
              }
              .buttonStyle(.borderedProminent)
              .controlSize(.large)
              .padding()
            }
            .navigationTitle("Error")
          }
          .navigationViewStyle(.stack)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .opacity
          ))
        }
      }
      .animation(.default, value: viewStore.state)
      .task { viewStore.send(.start) }
    }
    .onShake {
      isPresentingPulse = true
    }
    .fullScreenCover(isPresented: $isPresentingPulse) {
      PulseUI.MainView(
        store: .shared,
        onDismiss: { isPresentingPulse = false }
      )
    }
  }
}

#if DEBUG
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppComponent.State(),
      reducer: EmptyReducer()
    ))
  }
}
#endif
