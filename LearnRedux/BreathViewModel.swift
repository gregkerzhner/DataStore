//
//  BreathViewModel.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/9/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation

struct BreathViewState: StoreState {
  private let state: BreathState

  var inhaleDuration: CFTimeInterval {
    return CFTimeInterval(state.inhaleLength)
  }

  var exhaleDuration: CFTimeInterval {
    return CFTimeInterval(state.exhaleLength)
  }

  var dispatchDelay: DispatchTimeInterval {
    return DispatchTimeInterval.seconds(Int(state.pauseLength))
  }

  init(state: BreathState = .empty) {
    self.state = state
  }

  static let empty = BreathViewState()
}

enum BreathViewAction: StoreAction {
  case restart
  case storeUpdated(BreathState)
}


class BreathViewModel: ViewModel<BreathViewState, BreathViewAction> {
  private let breathStore: BreathStore
  init(breathStore: BreathStore = BreathStore()) {
    self.breathStore = breathStore
    super.init(initialState: BreathViewState.empty,
               reducer: BreathViewReducer().reducer)
  }

  func onBreathEnd() {
    breathStore.dispatch(action: .breathEnded)
  }
}

struct BreathViewReducer {
  func reducer(action: BreathViewAction, state: BreathViewState) -> BreathViewState {
    return BreathViewState.empty
  }
}

/*
class BreathViewModel: ViewModel<BreathViewState> {
  private let store: BreathStore
  init(store: BreathStore = BreathStore()) {
    self.store = store
    super.init(initialState: .empty)


    store.subscribe { (state) in
      let newState = BreathViewState(state: state)
      self.update(state: newState)
    }

    //subscribe(to: <#T##Store<StoreState>#>, block: <#T##(StoreState) -> Void#>)
  }
}
 */
