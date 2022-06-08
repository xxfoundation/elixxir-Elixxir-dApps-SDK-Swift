import Combine
import ComposableArchitecture
import ComposablePresentation
import ElixxirDAppsSDK
import ErrorFeature

public struct MyContactState: Equatable {
  public init(
    id: UUID,
    contact: Data? = nil,
    isMakingContact: Bool = false,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.contact = contact
    self.isMakingContact = isMakingContact
    self.error = error
  }

  public var id: UUID
  public var contact: Data?
  public var isMakingContact: Bool
  public var error: ErrorState?
}

public enum MyContactAction: Equatable {
  case viewDidLoad
  case observeMyContact
  case didUpdateMyContact(Data?)
  case makeContact
  case didFinishMakingContact(NSError?)
  case didDismissError
  case error(ErrorAction)
}

public struct MyContactEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    getIdentity: @escaping () -> Identity?,
    observeContact: @escaping () -> AnyPublisher<Data?, Never>,
    updateContact: @escaping (Data?) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.getClient = getClient
    self.getIdentity = getIdentity
    self.observeContact = observeContact
    self.updateContact = updateContact
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var getClient: () -> Client?
  public var getIdentity: () -> Identity?
  public var observeContact: () -> AnyPublisher<Data?, Never>
  public var updateContact: (Data?) -> Void
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
}

public let myContactReducer = Reducer<MyContactState, MyContactAction, MyContactEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .merge([
      .init(value: .observeMyContact),
    ])

  case .observeMyContact:
    struct EffectId: Hashable {
      let id: UUID
    }
    return env.observeContact()
      .removeDuplicates()
      .map(MyContactAction.didUpdateMyContact)
      .subscribe(on: env.bgScheduler)
      .receive(on: env.mainScheduler)
      .eraseToEffect()
      .cancellable(id: EffectId(id: state.id), cancelInFlight: true)

  case .didUpdateMyContact(let contact):
    state.contact = contact
    return .none

  case .makeContact:
    state.isMakingContact = true
    return Effect.future { fulfill in
      guard let identity = env.getIdentity() else {
        fulfill(.success(.didFinishMakingContact(NoIdentityError() as NSError)))
        return
      }
      do {
        env.updateContact(try env.getClient()?.makeContactFromIdentity(identity: identity))
        fulfill(.success(.didFinishMakingContact(nil)))
      } catch {
        fulfill(.success(.didFinishMakingContact(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didFinishMakingContact(let error):
    state.isMakingContact = false
    if let error = error {
      state.error = ErrorState(error: error)
    }
    return .none

  case .didDismissError:
    state.error = nil
    return .none

  case .error(_):
    return .none
  }
}

public struct NoIdentityError: Error, LocalizedError {
  public init() {}
}

#if DEBUG
extension MyContactEnvironment {
  public static let failing = MyContactEnvironment(
    getClient: { fatalError() },
    getIdentity: { fatalError() },
    observeContact: { fatalError() },
    updateContact: { _ in fatalError() },
    bgScheduler: .failing,
    mainScheduler: .failing,
    error: .failing
  )
}
#endif
