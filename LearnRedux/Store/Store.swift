import UIKit


public protocol StoreState: Equatable, CustomLogDescriptionConvertible {}
public protocol ViewState: StoreState {}

public extension Equatable where Self: StoreState {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    return false
  }
}

// have each store take a reducer as argument that creates next state from previous state
// maybe stores don't event need subclasses?  not sure here

protocol StoreAction {}

class Store<State: StoreState, Action: StoreAction> {
  typealias Reducer = (Action, State) -> State
  private var subscriptions = NSHashTable<StateSubscription<State>>.weakObjects()
  private var otherStoresSubscriptions = [String: AnyObject]()
  private lazy var stateTransactionQueue = DispatchQueue(label: "com.mlb.\(type(of: self)).StateTransactionQueue")

  // This should be protected and changed only by subclasses.
  private var state: State {
    didSet(oldState) {
      if #available(iOS 10.0, *) {
        dispatchPrecondition(condition: .onQueue(stateTransactionQueue))
      }

      stateDidChange(oldState: oldState, newState: state)
    }
  }

  private var storeIdentifier: String {
    return String(describing: self)
  }

  private let reducer: Reducer

  init(initialState: State, reducer: @escaping Reducer) {
    self.state = initialState
    self.reducer = reducer
  }

  func dispatch(action: Action) {
    write {
      self.state = self.reducer(action, state)
    }
  }

  private func write(_ transaction: () -> Void) {
    stateTransactionQueue.sync(execute: transaction)
  }


  public func subscribe(_ block: @escaping (State) -> Void) -> StateSubscription<State> {
    let subscription = StateSubscription(block)
    subscriptions.add(subscription)

    subscription.fire(state)
    return subscription
  }

  public func unsubscribe(_ subscription: StateSubscription<State>) {
    subscriptions.remove(subscription)
  }

  private func stateDidChange(oldState: State, newState: State) {
    guard oldState != newState else {
      print("[\(storeLogDescription())] Skip forwarding same state: \(newState.logDescription)")
      return
    }

    print("[\(storeLogDescription())] State change: \(newState.logDescription)")
    subscriptions.allObjects.forEach {
      $0.fire(state)
    }
  }

  private func storeLogDescription() -> String {
    return String(describing: type(of: self))
  }
}
