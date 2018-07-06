//
//  BreatheViewController.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/6/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class BreatheViewController: UIViewController {
  private var breathView: BreathView! {
    return view as? BreathView
  }
  override func loadView() {
    super.loadView()
    self.view = BreathView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    breathView.startAnimation()
    store.dispatch(BreathingStartAction())


    store.subscribe(self) {
      $0.select {
        $0.breathState
      }
    }

  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 3
    store.unsubscribe(self)
  }
}

extension BreatheViewController: StoreSubscriber {
  func newState(state: BreathState) {
    breathView.update(state: state)
  }
}
