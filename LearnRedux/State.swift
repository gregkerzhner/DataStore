//
//  State.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/6/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

struct AppState: StateType {
  let settingsState: SettingsState
  let breathState: BreathState
}

struct SettingsState: StateType, Codable {
  let inhaleStartLength: Float
  let inhaleEndLength: Float
  let pauseStartLength: Float
  let pauseEndLength: Float
  let exhaleStartLength: Float
  let exhaleEndLength: Float
  let duration: Float

  var inhaleIncrement: Float {
    guard durationBreaths > 1 else {return 0}
    return (inhaleEndSeconds - inhaleStartSeconds) / (durationBreaths - 1)
  }

  var pauseIncrement: Float {
    guard durationBreaths > 1 else {return 0}
    return (pauseEndSeconds - pauseStartSeconds) / (durationBreaths - 1)
  }

  var exhaleIncrement: Float {
    guard durationBreaths > 1 else {return 0}
    return (exhaleEndSeconds - exhaleStartSeconds) / (durationBreaths - 1)
  }

  var totalTime: Float {
    let increaseFactor: Float = (((durationBreaths - 1) * durationBreaths)/2)
    return (inhaleStartSeconds * durationBreaths) +
      (pauseStartSeconds * durationBreaths) +
      (exhaleStartSeconds * durationBreaths) +
      (increaseFactor * inhaleIncrement) +
      (increaseFactor * pauseIncrement) +
      (increaseFactor * exhaleIncrement)
  }

  static let reset = SettingsState(inhaleStartLength: 0.0,
                                   inhaleEndLength: 0,
                                   pauseStartLength: 0,
                                   pauseEndLength: 0,
                                   exhaleStartLength: 0,
                                   exhaleEndLength: 0,
                                   duration: 0)
}

extension SettingsState {
  var inhaleStartText: String {
    return "Inhale Start Length \(inhaleStartSeconds)s"
  }

  var inhaleEndText: String {
    return "Inhale End Length \(inhaleEndSeconds)s"
  }

  var pauseStartText: String {
    return "Pause Start Length \(pauseStartSeconds)s"
  }

  var pauseEndText: String {
    return "Pause End Length \(pauseEndSeconds)s"
  }

  var exhaleStartText: String {
    return "Exhale Start Length \(exhaleStartSeconds)s"
  }

  var exhaleEndText: String {
    return "Exhale End Length \(exhaleEndSeconds)s"
  }

  var durationText: String {
    let timeString = totalTime < 61 ? "\(totalTime) seconds" :
      String(format: "%.1f minutes", totalTime/60)
    return "Breaths - \(durationBreaths) (\(timeString)"
  }

  var inhaleStartSeconds: Float {
    return round(inhaleStartLength * 15)
  }

  var inhaleEndSeconds: Float {
    return round(inhaleEndLength * 15)
  }

  var exhaleStartSeconds: Float {
    return round(exhaleStartLength * 15)
  }

  var exhaleEndSeconds: Float {
    return round(exhaleEndLength * 15)
  }

  var pauseStartSeconds: Float {
    return round(pauseStartLength * 15)
  }

  var pauseEndSeconds: Float {
    return round(pauseEndLength * 15)
  }

  var durationBreaths: Float {
    return round(duration * 1000)
  }
}

struct BreathState {
  let inhaleLength: CGFloat
  let pauseLength: CGFloat
  let exhaleLength: CGFloat
  let elapsedTime: Float

  var duration: Float {
    return Float(inhaleLength) + Float(pauseLength) + Float(exhaleLength)
  }

  static let empty = BreathState(inhaleLength: 0,
                                 pauseLength: 0,
                                 exhaleLength: 0,
                                 elapsedTime: 0)
}
