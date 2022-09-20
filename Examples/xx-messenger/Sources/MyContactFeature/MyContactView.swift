import ComposableArchitecture
import SwiftUI
import XXModels

public struct MyContactView: View {
  public init(store: Store<MyContactState, MyContactAction>) {
    self.store = store
  }

  let store: Store<MyContactState, MyContactAction>
  @FocusState var focusedField: MyContactState.Field?

  struct ViewState: Equatable {
    init(state: MyContactState) {
      contact = state.contact
      focusedField = state.focusedField
      email = state.email
      phone = state.phone
      isLoadingFacts = state.isLoadingFacts
    }

    var contact: XXModels.Contact?
    var focusedField: MyContactState.Field?
    var email: String
    var phone: String
    var isLoadingFacts: Bool
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Text(viewStore.contact?.username ?? "")
        } header: {
          Label("Username", systemImage: "person")
        }

        Section {
          if let contact = viewStore.contact {
            if let email = contact.email {
              Text(email)
              Button(role: .destructive) {
                viewStore.send(.unregisterEmailTapped)
              } label: {
                Text("Unregister")
              }
            } else {
              TextField(
                text: viewStore.binding(
                  get: \.email,
                  send: { MyContactAction.set(\.$email, $0) }
                ),
                prompt: Text("Enter email"),
                label: { Text("Email") }
              )
              .focused($focusedField, equals: .email)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              Button {
                viewStore.send(.registerEmailTapped)
              } label: {
                Text("Register")
              }
            }
          } else {
            Text("")
          }
        } header: {
          Label("Email", systemImage: "envelope")
        }

        Section {
          if let contact = viewStore.contact {
            if let phone = contact.phone {
              Text(phone)
              Button(role: .destructive) {
                viewStore.send(.unregisterPhoneTapped)
              } label: {
                Text("Unregister")
              }
            } else {
              TextField(
                text: viewStore.binding(
                  get: \.phone,
                  send: { MyContactAction.set(\.$phone, $0) }
                ),
                prompt: Text("Enter phone"),
                label: { Text("Phone") }
              )
              .focused($focusedField, equals: .phone)
              .textInputAutocapitalization(.never)
              .disableAutocorrection(true)
              Button {
                viewStore.send(.registerPhoneTapped)
              } label: {
                Text("Register")
              }
            }
          } else {
            Text("")
          }
        } header: {
          Label("Phone", systemImage: "phone")
        }

        Section {
          Button {
            viewStore.send(.loadFactsTapped)
          } label: {
            HStack {
              Text("Reload facts")
              Spacer()
              if viewStore.isLoadingFacts {
                ProgressView()
              }
            }
          }
          .disabled(viewStore.isLoadingFacts)
        } header: {
          Text("Actions")
        }
      }
      .navigationTitle("My Contact")
      .task { viewStore.send(.start) }
      .onChange(of: viewStore.focusedField) { focusedField = $0 }
      .onChange(of: focusedField) { viewStore.send(.set(\.$focusedField, $0)) }
      .alert(store.scope(state: \.alert), dismiss: .alertDismissed)
    }
  }
}

#if DEBUG
public struct MyContactView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      MyContactView(store: Store(
        initialState: MyContactState(),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
