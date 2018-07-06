import UIKit

class ViewModel<State: StoreState, Action: StoreAction>: Store<State, Action> {
  override func subscribe(_ block: @escaping (State) -> Void) -> StateSubscription<State> {
    let mainBlock: (State) -> Void = { (state) -> Void in
      if Thread.isMainThread {
        block(state)
      } else {
        DispatchQueue.main.async {
          block(state)
        }
      }
    }

    return super.subscribe(mainBlock)
  }
}
/*
open class ViewModel<State: ViewState>: Store<State> {
    private var views = Set<AnyStatefulView<State>>()

    /*
    // This should be protected and changed only by subclasses.
    // Never read it directly from views, always call `subscribe(from:)`.
    public override var state: State {
        didSet(oldState) {
            views.forEach {
                stateDidChange(oldState: oldState, newState: state, view: $0)
            }
        }
    }

    */


    override public func subscribe(_ block: @escaping (State) -> Void) -> StateSubscription<State> {
      let mainBlock: (State) -> Void = { (state) -> Void in
        if Thread.isMainThread {
          block(state)
        } else {
          DispatchQueue.main.async {
            block(state)
          }
        }
      }

      return super.subscribe(mainBlock)
    }
}
*/
