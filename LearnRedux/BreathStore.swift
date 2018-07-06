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

func reducer(action: BreathAction, state: BreathState) -> BreathState {
  return BreathState.empty
}

class BreathStore: Store<BreathState, BreathAction> {
  static let shared = BreathStore()

  private let settingsStore: SettingsStore
  init(settingsStore: SettingsStore = SettingsStore.shared) {
    self.settingsStore = settingsStore
    super.init(initialState: BreathState.empty, reducer: BreathStoreReducer().reducer)

    settingsStore.subscribe {[weak self] (state) in
      self?.dispatch(action: .settingsUpdated(state))
    }
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
    return state
  }

  private func onSettingsUpdate(settings: SettingsState) -> BreathState {
    return BreathState(inhaleLength: settings.inhaleStartSeconds,
                       pauseLength: settings.pauseStartSeconds,
                       exhaleLength: settings.exhaleStartSeconds,
                       elapsedTime: 0)
  }

  func foo() -> BreathState {
    return BreathState.empty
  }
}

struct BreathState: StoreState {
  let inhaleLength: Float
  let pauseLength: Float
  let exhaleLength: Float
  let elapsedTime: Float

  var duration: Float {
    return inhaleLength + pauseLength + exhaleLength
  }

  static let empty = BreathState(inhaleLength: 0,
                                 pauseLength: 0,
                                 exhaleLength: 0,
                                 elapsedTime: 0)
}


/*
class BreathStore: Store<BreathState> {
  static let shared = BreathStore()
  private let settingsStore: SettingsStore

  init(settingsStore: SettingsStore = SettingsStore.shared) {
    self.settingsStore = settingsStore
    super.init(initialState: .empty)

    //settingsStore.subscribe(to: settingsStore) {[weak self] _ in
      //self?.update()
    //}
  }

  private func update() {
    
  }

  func breathFinished() {
    update(state: .empty)
  }
}
*/
