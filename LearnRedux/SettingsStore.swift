//
//  SettingsStore.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/9/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import ReSwift

enum SettingsAction: StoreAction {
  case settingsUpdated(SettingsState)
}

class SettingsStore: Store<SettingsState, SettingsAction> {
  static let shared = SettingsStore()

  init() {
    super.init(initialState: SettingsState.reset, reducer: SettingsReducer().reduce)

    store.subscribe(self) {
      $0.select {
        $0.settingsState
      }
    }
  }
}

struct SettingsReducer {
  func reduce(action: SettingsAction, state: SettingsState) -> SettingsState {
    switch action {
    case .settingsUpdated(let settings): return settings
    }
  }
}

extension SettingsStore: StoreSubscriber {
  func newState(state: SettingsState) {
    dispatch(action: .settingsUpdated(state))
  }
}

