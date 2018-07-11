//
//  BreathView.swift
//  LearnRedux
//
//  Created by Greg Kerzhner on 7/6/18.
//  Copyright © 2018 Greg Kerzhner. All rights reserved.
//

import Foundation
import UIKit

class BreathView: UIView {
  private let circleView = UIView()
  let startButton = UIButton(type: .system)

  private let doneButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("You did it!", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let catImageView: UIImageView = {
    let catImageView = UIImageView()
    catImageView.image = UIImage(named: "fatcat.jpg")
    catImageView.translatesAutoresizingMaskIntoConstraints = false
    catImageView.contentMode = .scaleAspectFit
    return catImageView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(displayP3Red: 28/255, green: 39/255, blue: 45/255, alpha: 1.0)
    addSubview(circleView)
    addSubview(startButton)
    addSubview(doneButton)

    startButton.translatesAutoresizingMaskIntoConstraints = false
    startButton.setTitle("Tap Anywhere to Begin", for: .normal)

    addSubview(catImageView)

    NSLayoutConstraint.activate([
      startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      startButton.centerYAnchor.constraint(equalTo: centerYAnchor),

      catImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5),
      catImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
      catImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      catImageView.centerXAnchor.constraint(equalTo: centerXAnchor),

      doneButton.topAnchor.constraint(equalTo: catImageView.bottomAnchor, constant: 20),
      doneButton.centerXAnchor.constraint(equalTo: centerXAnchor)
    ])
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func createAnimationLayer() {
    let yCenter: CGFloat = (bounds.height / 2) - (bounds.width / 2)
    let rect = CGRect(x: 0, y: yCenter, width: bounds.width, height: bounds.width)

    circleView.frame = rect

    circleView.backgroundColor = UIColor(displayP3Red: 47/255, green: 176/255, blue: 234/255, alpha: 1.0)
    circleView.layer.cornerRadius = bounds.width/2
    circleView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
  }

  func update(state: BreathViewState, completion: @escaping () -> Void) {
    self.startButton.isHidden = state.started
    self.circleView.isHidden = !state.started

    self.doneButton.isHidden = !state.finished
    self.catImageView.isHidden = !state.finished


    UIView.animate(withDuration: 0.3) {
      self.doneButton.alpha = state.finished ? 1 : 0
      self.catImageView.alpha = state.finished ? 1 : 0
    }

    guard state.started else { return }
    guard !state.finished else { return }

    UIView.animate(withDuration: state.inhaleDuration, animations: {[weak self] in
      self?.circleView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }) {[weak self] _ in
      let deadline: DispatchTime = .now() + state.dispatchDelay
      DispatchQueue.main.asyncAfter(deadline: deadline) {
        self?.shrink(state: state, completion: completion)
      }
    }
  }

  private func shrink(state: BreathViewState, completion: @escaping () -> Void) {
    UIView.animate(withDuration: state.exhaleDuration, animations: {[weak self] in
      self?.circleView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    }) { _ in
      completion()
    }
  }
}
