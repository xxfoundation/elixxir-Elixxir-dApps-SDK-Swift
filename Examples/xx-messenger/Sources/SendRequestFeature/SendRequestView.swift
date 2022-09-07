import AppCore
import ComposableArchitecture
import SwiftUI
import XXClient

public struct SendRequestView: View {
  public init(store: Store<SendRequestState, SendRequestAction>) {
    self.store = store
  }

  let store: Store<SendRequestState, SendRequestAction>

  struct ViewState: Equatable {
    var contact: XXClient.Contact
    var myContact: XXClient.Contact?
    var sendUsername: Bool
    var sendEmail: Bool
    var sendPhone: Bool
    var isSending: Bool
    var failure: String?

    init(state: SendRequestState) {
      contact = state.contact
      myContact = state.myContact
      sendUsername = state.sendUsername
      sendEmail = state.sendEmail
      sendPhone = state.sendPhone
      isSending = state.isSending
      failure = state.failure
    }
  }

  public var body: some View {
    WithViewStore(store.scope(state: ViewState.init)) { viewStore in
      Form {
        Section {
          HStack {
            Label(viewStore.myContact?.username ?? "", systemImage: "person")
            Spacer()
            Toggle(
              isOn: viewStore.binding(
                get: \.sendUsername,
                send: { SendRequestAction.set(\.$sendUsername, $0) }
              ),
              label: EmptyView.init
            )
          }

          HStack {
            Label(viewStore.myContact?.email ?? "", systemImage: "envelope")
            Spacer()
            Toggle(
              isOn: viewStore.binding(
                get: \.sendEmail,
                send: { SendRequestAction.set(\.$sendEmail, $0) }
              ),
              label: EmptyView.init
            )
          }

          HStack {
            Label(viewStore.myContact?.phone ?? "", systemImage: "phone")
            Spacer()
            Toggle(
              isOn: viewStore.binding(
                get: \.sendPhone,
                send: { SendRequestAction.set(\.$sendPhone, $0) }
              ),
              label: EmptyView.init
            )
          }
        } header: {
          Text("My facts")
        }
        .disabled(viewStore.isSending)

        Section {
          Label(viewStore.contact.username ?? "", systemImage: "person")
          Label(viewStore.contact.email ?? "", systemImage: "envelope")
          Label(viewStore.contact.phone ?? "", systemImage: "phone")
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
        initialState: SendRequestState(
          contact: {
            var contact = XXClient.Contact.unimplemented("contact-data".data(using: .utf8)!)
            contact.getFactsFromContact.run = { _ in
              [
                Fact(fact: "contact-username", type: 0),
                Fact(fact: "contact-email", type: 1),
                Fact(fact: "contact-phone", type: 2),
              ]
            }
            return contact
          }(),
          myContact: {
            var contact = XXClient.Contact.unimplemented("my-data".data(using: .utf8)!)
            contact.getFactsFromContact.run = { _ in
              [
                Fact(fact: "my-username", type: 0),
                Fact(fact: "my-email", type: 1),
                Fact(fact: "my-phone", type: 2),
              ]
            }
            return contact
          }(),
          isSending: true,
          failure: "Something went wrong"
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
