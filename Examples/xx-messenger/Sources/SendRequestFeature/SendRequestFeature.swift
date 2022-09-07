import ComposableArchitecture
import XCTestDynamicOverlay
import XXClient
import XXModels

public struct SendRequestState: Equatable {
  public init(
    contact: XXClient.Contact,
    myContact: XXClient.Contact? = nil,
    sendUsername: Bool = true,
    sendEmail: Bool = true,
    sendPhone: Bool = true,
    isSending: Bool = false,
    failure: String? = nil
  ) {
    self.contact = contact
    self.myContact = myContact
    self.sendUsername = sendUsername
    self.sendEmail = sendEmail
    self.sendPhone = sendPhone
    self.isSending = isSending
    self.failure = failure
  }

  public var contact: XXClient.Contact
  public var myContact: XXClient.Contact?
  @BindableState public var sendUsername: Bool
  @BindableState public var sendEmail: Bool
  @BindableState public var sendPhone: Bool
  public var isSending: Bool
  public var failure: String?
}

public enum SendRequestAction: Equatable, BindableAction {
  case start
  case sendTapped
  case binding(BindingAction<SendRequestState>)
}

public struct SendRequestEnvironment {
  public init() {}
}

#if DEBUG
extension SendRequestEnvironment {
  public static let unimplemented = SendRequestEnvironment()
}
#endif

public let sendRequestReducer = Reducer<SendRequestState, SendRequestAction, SendRequestEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none

  case .sendTapped:
    return .none

  case .binding(_):
    return .none
  }
}
