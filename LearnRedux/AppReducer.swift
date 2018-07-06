//
//  AppReducer.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/6/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

func appReducer(action: Action, state: AppState?) -> AppState {
  return AppState(settingsState: settingsReducer(action: action,
                                                 state: state?.settingsState),
                  breathState: breathReducer(action: action,
                                             state: state?.breathState,
                                             settingsState: state?.settingsState))
}

func breathReducer(action: Action, state: BreathState?, settingsState: SettingsState?) -> BreathState {
  guard let settingsState = settingsState else {
    return BreathState.empty
  }

  switch action {
    case let startAction as BreathingStartAction:
    return BreathState(inhaleLength: CGFloat(settingsState.inhaleStartSeconds),
                       pauseLength: CGFloat(settingsState.pauseStartSeconds),
                       exhaleLength: CGFloat(settingsState.exhaleStartSeconds),
                       elapsedTime: 0)
    default:
      let current = state ?? BreathState.empty
      return BreathState(inhaleLength: current.inhaleLength + CGFloat(settingsState.inhaleIncrement),
                         pauseLength: current.pauseLength + CGFloat(settingsState.pauseIncrement),
                         exhaleLength: current.exhaleLength + CGFloat(settingsState.exhaleIncrement),
                         elapsedTime: 0)
  }

}

func settingsReducer(action: Action, state: SettingsState?) -> SettingsState {
  var state = state ?? initialState()


  switch action {
  case let inhaleStartAction as InhaleStartLengthAction:
    state =  SettingsState(inhaleStartLength: inhaleStartAction.value,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: state.duration)
  case let inhaleEndAction as InhaleEndLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: inhaleEndAction.value,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: state.duration)
  case let exhaleStartAction as ExhaleStartLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: exhaleStartAction.value,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: state.duration)
  case let exhaleEndAction as ExhaleEndLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: exhaleEndAction.value,
                         duration: state.duration)
  case let pauseStartLength as PauseStartLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: pauseStartLength.value,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: state.duration)
  case let pauseEndLengthAction as PauseEndLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: pauseEndLengthAction.value,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: state.duration)
  case let durationAction as DurationLengthAction:
    state = SettingsState(inhaleStartLength: state.inhaleStartLength,
                         inhaleEndLength: state.inhaleEndLength,
                         pauseStartLength: state.pauseStartLength,
                         pauseEndLength: state.pauseEndLength,
                         exhaleStartLength: state.exhaleStartLength,
                         exhaleEndLength: state.exhaleEndLength,
                         duration: durationAction.value)
  default: break
  }

  UserDefaults.standard.set(try? PropertyListEncoder().encode(state), forKey:"settings")
  UserDefaults.standard.synchronize()
  return state
}

private func initialState() -> SettingsState {
  guard let data = UserDefaults.standard.value(forKey:"settings") as? Data else {
    return SettingsState.reset
  }

  return (try? PropertyListDecoder().decode(SettingsState.self, from: data))
    ?? SettingsState.reset
}
