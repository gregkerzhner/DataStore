import UIKit

/* For a store that doesn't depend on other stores, you don't have to subclass
   and can just customize the store purley through the reducer.

   For a store that subscribes to other stores or has other functionality, you can
   subclass this base class.

   @generic param StoreState - this is (usually) a struct that has all the data
                  that this store holds

   @generic param StoreAction - this is (usually) an enum specifying any change
                  that can happen to the store's data
 */

class Store<State: StoreState, Action: StoreAction> {
  //The reducer returns the next State based on an Action and the current State.
  typealias Reducer = (Action, State) -> State

  private var subscriptions = NSHashTable<StateSubscription<State>>()
  private lazy var stateTransactionQueue = DispatchQueue(label: "com.mlb.\(type(of: self)).StateTransactionQueue")

  private var state: State {
    didSet(oldState) {
      dispatchPrecondition(condition: .onQueue(stateTransactionQueue))
      stateDidChange(oldState: oldState, newState: state)
    }
  }

  private let reducer: Reducer

  /*
   @param initialState - The first state this Store will return
   @param reducer - a function that returns the next state based on the current state
     and an action
   */
  init(initialState: State, reducer: @escaping Reducer) {
    self.state = initialState
    self.reducer = reducer
  }

  /*
   Updates the store's state based on an action
   @param Action - Some change to the store
   */
  func dispatch(action: Action) {
    write {
      self.state = self.reducer(action, state)
    }
  }

  /*
   Subscribe to a store's changes
   @param subscriber - A store subscriber.  It should implement a `func newState(state: SomeState)`
   */
  func subscribe<S>(_ subscriber: S) where State == S.StateType, S : StateSubscriber {

    let block = {[weak subscriber] (state: State) -> Void in
      subscriber?.newState(state: state)
    }

    let subscription = StateSubscription(block, identifier: ObjectIdentifier(subscriber))
    subscriptions.add(subscription)
    subscription.fire(state)
  }

  /*
   Subscribe to a store's changes using a subscription.  A lower level API in case
   a more custom subscription is needed.
   Subscribing will immediatly emit an event with the store's current state.
   @param subscription - A subscription object
   */
  func subscribe(subscription: StateSubscription<State>) {
    subscriptions.add(subscription)
    subscription.fire(state)
  }

  /*
   Unsubscribe from a store
   @param subscriber - any subscriber
   */
  func unsubscribe<S>(_ subscriber: S) where State == S.StateType, S : StateSubscriber {
    let identifier = ObjectIdentifier(subscriber)
    guard let subscription = subscriptions.allObjects.first(where: {$0.identifier == identifier}) else {
      return
    }

    subscriptions.remove(subscription)
  }

  // MARK: private methods

  private func write(_ transaction: () -> Void) {
    stateTransactionQueue.sync(execute: transaction)
  }

  public func unsubscribe(_ subscription: StateSubscription<State>) {
    subscriptions.remove(subscription)
  }

  private func stateDidChange(oldState: State, newState: State) {
    guard oldState != newState else {
      print("[\(storeLogDescription)] Skip forwarding same state: \(newState.logDescription)")
      return
    }

    print("[\(storeLogDescription)] State change: \(newState.logDescription)")
    subscriptions.allObjects.forEach {
      $0.fire(state)
    }
  }

  private var storeLogDescription: String {
    return String(describing: type(of: self))
  }
}

// A store state can be anything that helps you represent the data in your store
public protocol StoreState: Equatable, CustomLogDescriptionConvertible {}
public extension Equatable where Self: StoreState {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return false
  }
}

// A store action can also be anything that helps you represent some change
// to a store, but Enums seem to work the best
protocol StoreAction {}

// Any object that subscribes to a store's changes
public protocol StateSubscriber: class {
  associatedtype StateType
  func newState(state: Self.StateType)
}

