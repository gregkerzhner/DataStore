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
  var animatableLayer : CAShapeLayer?

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func startAnimation() {
    let yCenter: CGFloat = (bounds.height / 2) - (bounds.width / 2)
    let rect = CGRect(x: 0, y: yCenter, width: bounds.width, height: bounds.width)

    self.backgroundColor = .white
    self.animatableLayer = CAShapeLayer()
    self.animatableLayer?.fillColor = UIColor.blue.cgColor
    self.animatableLayer?.path = UIBezierPath(roundedRect: rect, cornerRadius: (bounds.width / 2)).cgPath
    self.animatableLayer?.frame = self.bounds
    self.animatableLayer?.cornerRadius = self.bounds.width/2
    self.animatableLayer?.masksToBounds = true
    self.layer.addSublayer(self.animatableLayer!)
  }

  func update(state: BreathState) {
    CATransaction.begin()

    let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
    layerAnimation.fromValue = 0
    layerAnimation.toValue = 1
    layerAnimation.isAdditive = false
    layerAnimation.duration = CFTimeInterval(state.inhaleLength)
    layerAnimation.fillMode = kCAFillModeForwards
    layerAnimation.isRemovedOnCompletion = true
    layerAnimation.repeatCount = 1
    layerAnimation.autoreverses = false

    CATransaction.setCompletionBlock{ [weak self] in
      let deadline: DispatchTime = .now() + DispatchTimeInterval.seconds(Int(state.pauseLength))
      DispatchQueue.main.asyncAfter(deadline: deadline) {
        self?.shrink(state: state)
      }
    }
    self.animatableLayer?.add(layerAnimation, forKey: "growingAnimation")

    CATransaction.commit()
  }

  private func shrink(state: BreathState) {
    let layerAnimation = CABasicAnimation(keyPath: "transform.scale")
    layerAnimation.fromValue = 1
    layerAnimation.toValue = 0
    layerAnimation.isAdditive = false
    layerAnimation.duration = CFTimeInterval(state.inhaleLength)
    layerAnimation.fillMode = kCAFillModeForwards
    layerAnimation.isRemovedOnCompletion = true
    layerAnimation.repeatCount = 1
    layerAnimation.autoreverses = false

    CATransaction.setCompletionBlock{ [weak self] in
      store.dispatch(BreathEndAction())
    }
    self.animatableLayer?.add(layerAnimation, forKey: "shrinkingAnimation")

    CATransaction.commit()
  }

}
