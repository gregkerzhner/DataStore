//
//  ViewController.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/5/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController {

  @IBOutlet weak var durationSlider: UISlider!
  @IBOutlet weak var exhaleEndSlider: UISlider!
  @IBOutlet weak var exhaleStartSlider: UISlider!
  @IBOutlet weak var pauseEndSlider: UISlider!
  @IBOutlet weak var pauseStartSlider: UISlider!
  @IBOutlet weak var inhaleEndSlider: UISlider!
  @IBOutlet weak var inhaleStartSlider: UISlider!

  @IBOutlet weak var inhaleStartLabel: UILabel!

  @IBOutlet weak var inhaleEndLabel: UILabel!

  @IBOutlet weak var pauseStartLabel: UILabel!
  @IBOutlet weak var pauseEndLabel: UILabel!
  @IBOutlet weak var exhaleStartLabel: UILabel!
  @IBOutlet weak var exhaleEndLabel: UILabel!
  @IBOutlet weak var durationLabelLabel: UILabel!


  @IBAction func inhaleEndChange(_ sender: Any) {
    store.dispatch(InhaleEndLengthAction(value: inhaleEndSlider.value))
  }

  @IBAction func exhaleStartChange(_ sender: Any) {
    store.dispatch(ExhaleStartLengthAction(value: exhaleStartSlider.value))
  }

  @IBAction func exhaleEndChange(_ sender: Any) {
    store.dispatch(ExhaleEndLengthAction(value: exhaleEndSlider.value))
  }

  @IBAction func pauseStartChange(_ sender: Any) {
    store.dispatch(PauseStartLengthAction(value: pauseStartSlider.value))
  }

  @IBAction func pauseEndChange(_ sender: Any) {
    store.dispatch(PauseEndLengthAction(value: pauseEndSlider.value))
  }

  @IBAction func durationChange(_ sender: Any) {
    store.dispatch(DurationLengthAction(value: durationSlider.value))
  }

  @IBAction func inhaleStartChange(_ sender: Any) {
    store.dispatch(InhaleStartLengthAction(value: inhaleStartSlider.value))
  }

  @IBAction func startAction(_ sender: Any) {
    let breatheViewController = BreatheViewController()
    navigationController?.pushViewController(breatheViewController, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // 2
    store.subscribe(self) {
      $0.select {
        $0.settingsState
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 3
    store.unsubscribe(self)
  }
}

extension ViewController: StoreSubscriber {
  func newState(state: SettingsState) {
    inhaleStartLabel.text = state.inhaleStartText
    inhaleEndLabel.text = state.inhaleEndText
    exhaleStartLabel.text = state.exhaleStartText
    exhaleEndLabel.text = state.exhaleEndText
    pauseStartLabel.text = state.pauseStartText
    pauseEndLabel.text = state.pauseEndText
    durationLabelLabel.text = state.durationText

    inhaleStartSlider.value = state.inhaleStartLength
    inhaleEndSlider.value = state.inhaleEndLength
    exhaleStartSlider.value = state.exhaleStartLength
    exhaleEndSlider.value = state.exhaleEndLength
    pauseStartSlider.value = state.pauseStartLength
    pauseEndSlider.value = state.pauseEndLength
    durationSlider.value = state.duration
  }
}
