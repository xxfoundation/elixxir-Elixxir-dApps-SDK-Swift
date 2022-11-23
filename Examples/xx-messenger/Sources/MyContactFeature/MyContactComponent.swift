import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct MyContactComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case email
      case emailCode
      case phone
      case phoneCode
    }

    public init(
      contact: XXModels.Contact? = nil,
      focusedField: Field? = nil,
      email: String = "",
      emailConfirmationID: String? = nil,
      emailConfirmationCode: String = "",
      isRegisteringEmail: Bool = false,
      isConfirmingEmail: Bool = false,
      isUnregisteringEmail: Bool = false,
      phone: String = "",
      phoneConfirmationID: String? = nil,
      phoneConfirmationCode: String = "",
      isRegisteringPhone: Bool = false,
      isConfirmingPhone: Bool = false,
      isUnregisteringPhone: Bool = false,
      isLoadingFacts: Bool = false,
      alert: AlertState<Action>? = nil
    ) {
      self.contact = contact
      self.focusedField = focusedField
      self.email = email
      self.emailConfirmationID = emailConfirmationID
      self.emailConfirmationCode = emailConfirmationCode
      self.isRegisteringEmail = isRegisteringEmail
      self.isConfirmingEmail = isConfirmingEmail
      self.isUnregisteringEmail = isUnregisteringEmail
      self.phone = phone
      self.phoneConfirmationID = phoneConfirmationID
      self.phoneConfirmationCode = phoneConfirmationCode
      self.isRegisteringPhone = isRegisteringPhone
      self.isConfirmingPhone = isConfirmingPhone
      self.isUnregisteringPhone = isUnregisteringPhone
      self.isLoadingFacts = isLoadingFacts
      self.alert = alert
    }

    public var contact: XXModels.Contact?
    @BindableState public var focusedField: Field?
    @BindableState public var email: String
    @BindableState public var emailConfirmationID: String?
    @BindableState public var emailConfirmationCode: String
    @BindableState public var isRegisteringEmail: Bool
    @BindableState public var isConfirmingEmail: Bool
    @BindableState public var isUnregisteringEmail: Bool
    @BindableState public var phone: String
    @BindableState public var phoneConfirmationID: String?
    @BindableState public var phoneConfirmationCode: String
    @BindableState public var isRegisteringPhone: Bool
    @BindableState public var isConfirmingPhone: Bool
    @BindableState public var isUnregisteringPhone: Bool
    @BindableState public var isLoadingFacts: Bool
    public var alert: AlertState<Action>?
  }

  public enum Action: Equatable, BindableAction {
    case start
    case contactFetched(XXModels.Contact?)
    case registerEmailTapped
    case confirmEmailTapped
    case unregisterEmailTapped
    case registerPhoneTapped
    case confirmPhoneTapped
    case unregisterPhoneTapped
    case loadFactsTapped
    case didFail(String)
    case alertDismissed
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      enum DBFetchEffectID {}
      let db = self.db

      switch action {
      case .start:
        return Effect
          .catching { try messenger.e2e.tryGet().getContact().getId() }
          .tryMap { try db().fetchContactsPublisher(.init(id: [$0])) }
          .flatMap { $0 }
          .assertNoFailure()
          .map(\.first)
          .map(Action.contactFetched)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
          .eraseToEffect()
          .cancellable(id: DBFetchEffectID.self, cancelInFlight: true)

      case .contactFetched(let contact):
        state.contact = contact
        return .none

      case .registerEmailTapped:
        state.focusedField = nil
        state.isRegisteringEmail = true
        return Effect.run { [state] subscriber in
          do {
            let ud = try messenger.ud.tryGet()
            let fact = Fact(type: .email, value: state.email)
            let confirmationID = try ud.sendRegisterFact(fact)
            subscriber.send(.set(\.$emailConfirmationID, confirmationID))
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isRegisteringEmail, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .confirmEmailTapped:
        guard let confirmationID = state.emailConfirmationID else { return .none }
        state.focusedField = nil
        state.isConfirmingEmail = true
        return Effect.run { [state] subscriber in
          do {
            let ud = try messenger.ud.tryGet()
            try ud.confirmFact(confirmationId: confirmationID, code: state.emailConfirmationCode)
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            if var dbContact = try db().fetchContacts(.init(id: [contactId])).first {
              dbContact.email = state.email
              try db().saveContact(dbContact)
            }
            subscriber.send(.set(\.$email, ""))
            subscriber.send(.set(\.$emailConfirmationID, nil))
            subscriber.send(.set(\.$emailConfirmationCode, ""))
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isConfirmingEmail, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .unregisterEmailTapped:
        guard let email = state.contact?.email else { return .none }
        state.isUnregisteringEmail = true
        return Effect.run { subscriber in
          do {
            let ud: UserDiscovery = try messenger.ud.tryGet()
            let fact = Fact(type: .email, value: email)
            try ud.removeFact(fact)
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            if var dbContact = try db().fetchContacts(.init(id: [contactId])).first {
              dbContact.email = nil
              try db().saveContact(dbContact)
            }
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isUnregisteringEmail, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .registerPhoneTapped:
        state.focusedField = nil
        state.isRegisteringPhone = true
        return Effect.run { [state] subscriber in
          do {
            let ud = try messenger.ud.tryGet()
            let fact = Fact(type: .phone, value: state.phone)
            let confirmationID = try ud.sendRegisterFact(fact)
            subscriber.send(.set(\.$phoneConfirmationID, confirmationID))
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isRegisteringPhone, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .confirmPhoneTapped:
        guard let confirmationID = state.phoneConfirmationID else { return .none }
        state.focusedField = nil
        state.isConfirmingPhone = true
        return Effect.run { [state] subscriber in
          do {
            let ud = try messenger.ud.tryGet()
            try ud.confirmFact(confirmationId: confirmationID, code: state.phoneConfirmationCode)
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            if var dbContact = try db().fetchContacts(.init(id: [contactId])).first {
              dbContact.phone = state.phone
              try db().saveContact(dbContact)
            }
            subscriber.send(.set(\.$phone, ""))
            subscriber.send(.set(\.$phoneConfirmationID, nil))
            subscriber.send(.set(\.$phoneConfirmationCode, ""))
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isConfirmingPhone, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .unregisterPhoneTapped:
        guard let phone = state.contact?.phone else { return .none }
        state.isUnregisteringPhone = true
        return Effect.run { subscriber in
          do {
            let ud: UserDiscovery = try messenger.ud.tryGet()
            let fact = Fact(type: .phone, value: phone)
            try ud.removeFact(fact)
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            if var dbContact = try db().fetchContacts(.init(id: [contactId])).first {
              dbContact.phone = nil
              try db().saveContact(dbContact)
            }
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isUnregisteringPhone, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .loadFactsTapped:
        state.isLoadingFacts = true
        return Effect.run { subscriber in
          do {
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            if var dbContact = try db().fetchContacts(.init(id: [contactId])).first {
              let facts = try messenger.ud.tryGet().getFacts()
              dbContact.username = facts.get(.username)?.value
              dbContact.email = facts.get(.email)?.value
              dbContact.phone = facts.get(.phone)?.value
              try db().saveContact(dbContact)
            }
          } catch {
            subscriber.send(.didFail(error.localizedDescription))
          }
          subscriber.send(.set(\.$isLoadingFacts, false))
          subscriber.send(completion: .finished)
          return AnyCancellable {}
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .didFail(let failure):
        state.alert = .error(failure)
        return .none

      case .alertDismissed:
        state.alert = nil
        return .none

      case .binding(_):
        return .none
      }
    }
  }
}
