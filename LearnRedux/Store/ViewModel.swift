import UIKit

/*
 View models are basically plain stores.  The only difference is that
 we make sure that new states are passed along on the main thread for
 convenient rendering
 */
class ViewModel<State: StoreState, Action: StoreAction>: Store<State, Action> {

  /*
   Subscribes an object to new states. Events will be emitted on
    the main thread
   @param subscriber - the object subscribing to events
   */
  override func subscribe<S>(_ subscriber: S) where State == S.StateType, S : StateSubscriber {
    let mainBlock: (State) -> Void = {[weak subscriber] (state) -> Void in
      if Thread.isMainThread {
        subscriber?.newState(state: state)
      } else {
        DispatchQueue.main.async {
          subscriber?.newState(state: state)
        }
      }
    }

    let subscription = StateSubscription(mainBlock, identifier: ObjectIdentifier(subscriber))

    super.subscribe(subscription: subscription)
  }
}
