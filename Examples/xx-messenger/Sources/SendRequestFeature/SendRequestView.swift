import AppCore
import ComposableArchitecture
import SwiftUI
import XXClient

public struct SendRequestView: View {
  public init(store: StoreOf<SendRequestComponent>) {
    self.store = store
  }

  let store: StoreOf<SendRequestComponent>

  struct ViewState: Equatable {
    var contactUsername: String?
    var contactEmail: String?
    var contactPhone: String?
    var myUsername: String?
    var myEmail: String?
    var myPhone: String?
    var sendUsername: Bool
    var sendEmail: Bool
    var sendPhone: Bool
    var isSending: Bool
    var failure: String?

    init(state: SendRequestComponent.State) {
      contactUsername = try? state.contact.getFact(.username)?.value
      contactEmail = try? state.contact.getFact(.email)?.value
      contactPhone = try? state.contact.getFact(.phone)?.value
      myUsername = try? state.myContact?.getFact(.username)?.value
      myEmail = try? state.myContact?.getFact(.email)?.value
      myPhone = try? state.myContact?.getFact(.phone)?.value
      sendUsername = state.sendUsername
      sendEmail = state.sendEmail
      sendPhone = state.sendPhone
      isSending = state.isSending
      failure = state.failure
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      Form {
        Section {
          Button {
            viewStore.send(.set(\.$sendUsername, !viewStore.sendUsername))
          } label: {
            HStack {
              Label(viewStore.myUsername ?? "", systemImage: "person")
                .tint(Color.primary)
              Spacer()
              Image(systemName: viewStore.sendUsername ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.accentColor)
            }
          }
          .animation(.default, value: viewStore.sendUsername)

          Button {
            viewStore.send(.set(\.$sendEmail, !viewStore.sendEmail))
          } label: {
            HStack {
              Label(viewStore.myEmail ?? "", systemImage: "envelope")
                .tint(Color.primary)
              Spacer()
              Image(systemName: viewStore.sendEmail ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.accentColor)
            }
          }
          .animation(.default, value: viewStore.sendEmail)

          Button {
            viewStore.send(.set(\.$sendPhone, !viewStore.sendPhone))
          } label: {
            HStack {
              Label(viewStore.myPhone ?? "", systemImage: "phone")
                .tint(Color.primary)
              Spacer()
              Image(systemName: viewStore.sendPhone ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.accentColor)
            }
          }
          .animation(.default, value: viewStore.sendPhone)
        } header: {
          Text("My facts")
        }
        .disabled(viewStore.isSending)

        Section {
          Label(viewStore.contactUsername ?? "", systemImage: "person")
          Label(viewStore.contactEmail ?? "", systemImage: "envelope")
          Label(viewStore.contactPhone ?? "", systemImage: "phone")
        } header: {
          Text("Contact")
        }

        Section {
          Button {
            viewStore.send(.sendTapped)
          } label: {
            HStack {
              Text("Send request")
              Spacer()
              if viewStore.isSending {
                ProgressView()
              } else {
                Image(systemName: "paperplane")
              }
            }
          }
        }
        .disabled(viewStore.isSending)

        if let failure = viewStore.failure {
          Section {
            Text(failure)
          } header: {
            Text("Error")
          }
        }
      }
      .navigationTitle("Send Request")
      .task { viewStore.send(.start) }
    }
  }
}

#if DEBUG
public struct SendRequestView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      SendRequestView(store: Store(
        initialState: SendRequestComponent.State(
          contact: {
            var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
            contact.getFactsFromContact.run = { _ in
              [
                Fact(type: .username, value: "contact-username"),
                Fact(type: .email, value: "contact-email"),
                Fact(type: .phone, value: "contact-phone"),
              ]
            }
            return contact
          }(),
          myContact: {
            var contact = XXClient.Contact.unimplemented("my-data".data(using: .utf8)!)
            contact.getFactsFromContact.run = { _ in
              [
                Fact(type: .username, value: "my-username"),
                Fact(type: .email, value: "my-email"),
                Fact(type: .phone, value: "my-phone"),
              ]
            }
            return contact
          }(),
          sendUsername: true,
          sendEmail: false,
          sendPhone: true,
          isSending: false,
          failure: "Something went wrong"
        ),
        reducer: EmptyReducer()
      ))
    }
  }
}
#endif
