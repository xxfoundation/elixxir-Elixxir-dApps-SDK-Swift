import AppCore
import ComposableArchitecture
import SwiftUI

public struct ChatView: View {
  public init(store: Store<ChatState, ChatAction>) {
    self.store = store
  }

  let store: Store<ChatState, ChatAction>

  struct ViewState: Equatable {
    var myContactId: Data?
    var messages: IdentifiedArrayOf<ChatState.Message>
    var failure: String?
    var text: String

    init(state: ChatState) {
      myContactId = state.myContactId
      messages = state.messages
      failure = state.failure
      text = state.text
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      ScrollView {
        LazyVStack {
          if let failure = viewStore.failure {
            Text(failure)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding()
            Button {
              viewStore.send(.start)
            } label: {
              Text("Retry")
            }
            .padding()
          }
          ForEach(viewStore.messages) { message in
            MessageView(
              message: message,
              myContactId: viewStore.myContactId
            )
          }
        }
      }
      .toolbar(
        position: .bottom,
        ignoresKeyboard: true,
        frameChangeAnimation: .default
      ) {
        VStack(spacing: 0) {
          Divider()
          HStack {
            TextField("Text", text: viewStore.binding(
              get: \.text,
              send: { ChatAction.set(\.$text, $0) }
            ))
            .textFieldStyle(.roundedBorder)

            Button {
              viewStore.send(.sendTapped)
            } label: {
              Image(systemName: "paperplane.fill")
            }
            .buttonStyle(.borderedProminent)
          }
          .padding()
        }
        .background(Material.regularMaterial)
      }
      .navigationTitle("Chat")
      .task { viewStore.send(.start) }
      .toolbarSafeAreaInset()
    }
  }

  struct MessageView: View {
    var message: ChatState.Message
    var myContactId: Data?

    var alignment: Alignment {
      message.senderId == myContactId ? .trailing : .leading
    }

    var backgroundColor: Color {
      message.senderId == myContactId ? Color.blue : Color.gray.opacity(0.5)
    }

    var textColor: Color? {
      message.senderId == myContactId ? Color.white : nil
    }

    var body: some View {
      VStack {
        Text("\(message.date.formatted())")
          .foregroundColor(.secondary)
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: alignment)

        Text(message.text)
          .foregroundColor(textColor)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .fill(backgroundColor)
          }
          .frame(maxWidth: .infinity, alignment: alignment)
      }
      .padding(.horizontal)
    }
  }
}

#if DEBUG
public struct ChatView_Previews: PreviewProvider {
  public static var previews: some View {
    NavigationView {
      ChatView(store: Store(
        initialState: ChatState(
          id: .contact("contact-id".data(using: .utf8)!),
          myContactId: "my-contact-id".data(using: .utf8)!,
          messages: [
            .init(
              id: 1,
              date: Date(),
              senderId: "contact-id".data(using: .utf8)!,
              text: "Hello!"
            ),
            .init(
              id: 2,
              date: Date(),
              senderId: "my-contact-id".data(using: .utf8)!,
              text: "Hi!"
            ),
          ]
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
