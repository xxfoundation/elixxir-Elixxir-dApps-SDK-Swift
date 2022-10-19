import AppCore
import ComposableArchitecture
import SwiftUI

public struct ChatView: View {
  public init(store: Store<ChatState, ChatAction>) {
    self.store = store
  }

  let store: Store<ChatState, ChatAction>
  @State var isPresentingImagePicker = false

  struct ViewState: Equatable {
    var myContactId: Data?
    var messages: IdentifiedArrayOf<ChatState.Message>
    var failure: String?
    var sendFailure: String?
    var text: String

    init(state: ChatState) {
      myContactId = state.myContactId
      messages = state.messages
      failure = state.failure
      sendFailure = state.sendFailure
      text = state.text
    }
  }

  public var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      ScrollView {
        LazyVStack {
          if let failure = viewStore.failure {
            VStack {
              Text(failure)
                .frame(maxWidth: .infinity, alignment: .leading)
              Button {
                viewStore.send(.start)
              } label: {
                Text("Retry").padding()
              }
            }
            .padding()
            .background {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Material.ultraThick)
            }
            .padding()
          }

          ForEach(viewStore.messages) { message in
            MessageView(
              message: message,
              myContactId: viewStore.myContactId
            )
          }

          if let sendFailure = viewStore.sendFailure {
            VStack {
              Text(sendFailure)
                .frame(maxWidth: .infinity, alignment: .leading)
              Button {
                viewStore.send(.dismissSendFailureTapped)
              } label: {
                Text("Dismiss").padding()
              }
            }
            .padding()
            .background {
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Material.ultraThick)
            }
            .padding()
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

            if viewStore.text.isEmpty == false {
              Button {
                viewStore.send(.sendTapped)
              } label: {
                Image(systemName: "paperplane.fill")
              }
              .buttonStyle(.borderedProminent)
            } else {
              Button {
                isPresentingImagePicker = true
              } label: {
                Image(systemName: "photo.on.rectangle.angled")
              }
              .buttonStyle(.borderedProminent)
              .sheet(isPresented: $isPresentingImagePicker) {
                ImagePicker { image in
                  if let data = image.jpegData(compressionQuality: 0.7) {
                    viewStore.send(.imagePicked(data))
                  }
                }
              }
            }
          }
          .padding()
        }
        .background(Material.bar)
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

    var paddingEdge: Edge.Set {
      message.senderId == myContactId ? .leading : .trailing
    }

    var textColor: Color? {
      message.senderId == myContactId ? Color.white : nil
    }

    var body: some View {
      VStack {
        Text("\(message.date.formatted()), \(statusText)")
          .foregroundColor(.secondary)
          .font(.footnote)
          .frame(maxWidth: .infinity, alignment: alignment)

        VStack(alignment: .leading) {
          if let fileTransfer = message.fileTransfer {
            Text("\(fileTransfer.name) (\(fileTransfer.type))")
            if fileTransfer.progress < 1 {
              ProgressView(value: fileTransfer.progress)
            }
            if fileTransfer.type == "image",
               let data = fileTransfer.data,
               let image = UIImage(data: data) {
              Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 8)
            }
          } else {
            Text(message.text)
          }
        }
        .foregroundColor(textColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
          if message.senderId == myContactId {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .fill(Color.blue)
          } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .fill(Material.ultraThick)
          }
        }
        .frame(maxWidth: .infinity, alignment: alignment)
        .padding(paddingEdge, 60)
      }
      .padding(.horizontal)
    }

    var statusText: String {
      switch message.status {
      case .sending: return "Sending"
      case .sendingTimedOut: return "Sending timed out"
      case .sendingFailed: return "Failed"
      case .sent: return "Sent"
      case .receiving: return "Receiving"
      case .receivingFailed: return "Receiving failed"
      case .received: return "Received"
      }
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
              text: "Hello!",
              status: .received
            ),
            .init(
              id: 2,
              date: Date(),
              senderId: "my-contact-id".data(using: .utf8)!,
              text: "Hi!",
              status: .sent
            ),
            .init(
              id: 3,
              date: Date(),
              senderId: "contact-id".data(using: .utf8)!,
              text: "",
              status: .received,
              fileTransfer: .init(
                id: Data(),
                contactId: Data(),
                name: "received_file.jpeg",
                type: "image",
                progress: 0.75,
                isIncoming: true
              )
            ),
            .init(
              id: 4,
              date: Date(),
              senderId: "my-contact-id".data(using: .utf8)!,
              text: "",
              status: .sent,
              fileTransfer: .init(
                id: Data(),
                contactId: Data(),
                name: "sent_file.jpeg",
                type: "image",
                data: {
                  let bounds = CGRect(origin: .zero, size: .init(width: 4, height: 3))
                  let format = UIGraphicsImageRendererFormat()
                  format.scale = 1
                  let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
                  let image = renderer.image { ctx in
                    UIColor.systemMint.setFill()
                    ctx.fill(bounds)
                  }
                  return image.jpegData(compressionQuality: 0.72)
                }(),
                progress: 1,
                isIncoming: true
              )
            ),
          ],
          failure: "Something went wrong when fetching messages from database.",
          sendFailure: "Something went wrong when sending message."
        ),
        reducer: .empty,
        environment: ()
      ))
    }
  }
}
#endif
