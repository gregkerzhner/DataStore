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

  deinit {
    print("llll")
  }

  private let viewModel = BreathViewModel()
  private var subscription: StateSubscription<BreathViewState>?

  override func loadView() {
    super.loadView()
    self.view = BreathView()

    breathView.startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    breathView.createAnimationLayer()

    viewModel.subscribe(self)

    //subscription = viewModel.subscribe(self.newState)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if let subscription = self.subscription {
      viewModel.unsubscribe(subscription)
      self.subscription = nil
    }
  }

  @objc private func startButtonTapped() {
    viewModel.startAnimation()
  }
}

extension BreatheViewController: StateSubscriber {
  func newState(state: BreathViewState) {
    print("Got state \(state)")
    navigationController?.setNavigationBarHidden(state.navigationBarHidden, animated: true)
    breathView.update(state: state) {[weak self] in
      self?.viewModel.onBreathEnd()
    }
  }
}

/*
extension BreatheViewController: StoreSubscriber {
  func newState(state: BreathViewState) {
    print("Got state \(state)")
    navigationController?.setNavigationBarHidden(state.navigationBarHidden, animated: true)
    breathView.update(state: state) {[weak self] in
      self?.viewModel.onBreathEnd()
    }
  }
}*/
