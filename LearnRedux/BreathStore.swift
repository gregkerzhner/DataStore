//
//  SettingsStore.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/9/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import UIKit

enum BreathAction: StoreAction {
  case settingsUpdated(SettingsState)
  case breathEnded
}

class BreathStore: Store<BreathState, BreathAction> {
  static let shared = BreathStore()

  private let settingsStore: SettingsStore
  init(settingsStore: SettingsStore = SettingsStore.shared) {
    self.settingsStore = settingsStore
    super.init(initialState: BreathState.empty, reducer: BreathStoreReducer().reducer)

    settingsStore.subscribe(self)
  }
}

extension BreathStore: StateSubscriber {
  func newState(state: SettingsState) {
    self.dispatch(action: .settingsUpdated(state))
  }
}

struct BreathStoreReducer {
  func reducer(action: BreathAction, state: BreathState) -> BreathState {
    switch action {
    case .breathEnded: return onBreathEnd(state: state)
    case .settingsUpdated(let settings): return onSettingsUpdate(settings: settings)
    }
  }

  private func onBreathEnd(state: BreathState) -> BreathState {
    let current = state
    return BreathState(inhaleLength: current.inhaleLength + state.settingsState.inhaleIncrement,
                       pauseLength: current.pauseLength + state.settingsState.pauseIncrement,
                       exhaleLength: current.exhaleLength + state.settingsState.exhaleIncrement,
                       breaths: state.breaths + 1,
                       settingsState: state.settingsState)

  }

  private func onSettingsUpdate(settings: SettingsState) -> BreathState {
    return BreathState(inhaleLength: settings.inhaleStartSeconds,
                       pauseLength: settings.pauseStartSeconds,
                       exhaleLength: settings.exhaleStartSeconds,
                       breaths: 0,
                       settingsState: settings)
  }
}

struct BreathState: StoreState {
  let inhaleLength: Float
  let pauseLength: Float
  let exhaleLength: Float
  let breaths: Float

  let settingsState: SettingsState

  var duration: Float {
    return inhaleLength + pauseLength + exhaleLength
  }

  var finished: Bool {
    return breaths > 0 && breaths >= settingsState.durationBreaths
  }

  static let empty = BreathState(inhaleLength: 0,
                                 pauseLength: 0,
                                 exhaleLength: 0,
                                 breaths: 0,
                                 settingsState: SettingsState.reset)
}
