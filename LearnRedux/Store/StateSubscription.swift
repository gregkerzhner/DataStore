// A class that represents a subscription to a store.
class StateSubscription<State> {
  private(set) var block: ((State) -> Void)?
  let identifier: ObjectIdentifier

  /*
   @param block - the code you want executed when data changes
   @param identifier - a unique identifier for the subscribing object
   */
  init(_ block: @escaping (State) -> Void, identifier: ObjectIdentifier) {
    self.block = block
    self.identifier = identifier
  }

  /*
   Executes the block for a new state
   @param state - the new state
   */
  func fire(_ state: State) {
    block?(state)
  }

  /*
   Stop the subscription
   */
  func stop() {
    block = nil
  }

  deinit {
    stop()
  }
}
