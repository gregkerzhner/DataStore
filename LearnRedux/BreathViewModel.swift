//
//  BreathViewModel.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/9/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation

struct BreathViewState: StoreState {
  let state: BreathState

  var inhaleDuration: CFTimeInterval {
    return CFTimeInterval(state.inhaleLength)
  }

  var exhaleDuration: CFTimeInterval {
    return CFTimeInterval(state.exhaleLength)
  }

  var dispatchDelay: DispatchTimeInterval {
    return DispatchTimeInterval.milliseconds(Int(state.pauseLength * 1000))
  }

  var finished: Bool {
    return state.finished
  }

  var navigationBarHidden: Bool {
    return started && !finished
  }

  let started: Bool

  init(state: BreathState = .empty, started: Bool = false) {
    self.state = state
    self.started = started
  }

  static let empty = BreathViewState()
}

enum BreathViewAction: StoreAction {
  case start
  case storeUpdated(BreathState)
}


class BreathViewModel: ViewModel<BreathViewState, BreathViewAction> {
  deinit {
    print("Suckaa")
  }
  private let breathStore: BreathStore
  private var storeSubscription: StateSubscription<BreathState>?
  init(breathStore: BreathStore = BreathStore()) {
    self.breathStore = breathStore
    print("A new guy")
    super.init(initialState: BreathViewState.empty,
               reducer: BreathViewReducer().reducer)

    breathStore.subscribe(self)
  }

  func startAnimation() {
    dispatch(action: .start)
  }

  func onBreathEnd() {
    breathStore.dispatch(action: .breathEnded)
  }
}

extension BreathViewModel: StateSubscriber {
  func newState(state: BreathState) {
    self.dispatch(action: .storeUpdated(state))
  }
}

struct BreathViewReducer {
  func reducer(action: BreathViewAction, state: BreathViewState) -> BreathViewState {
    switch action {
    case .start: return BreathViewState(state: state.state, started: true)
    case .storeUpdated(let settings): return BreathViewState(state: settings, started: state.started)
    }
  }
}
