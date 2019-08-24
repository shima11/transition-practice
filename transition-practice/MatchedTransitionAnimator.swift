//
//  MatchedTransitionAnimator.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

class MatchedTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  let isPresented: Bool

  init(isPresented: Bool) {

    self.isPresented = isPresented
    
    super.init()
  }


  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    let fromVC: UIViewController & InteractiveTransitionType
    let toVC: UIViewController & InteractiveTransitionType

    if isPresented {

      fromVC = (transitionContext.viewController(forKey: .from) as! UINavigationController).topViewController as! UIViewController & InteractiveTransitionType
      toVC = transitionContext.viewController(forKey: .to) as! UIViewController & InteractiveTransitionType

      toVC.beginAppearanceTransition(true, animated: true)
      fromVC.beginAppearanceTransition(false, animated: false)
      transitionContext.containerView.addSubview(toVC.view)
    }
    else {

      fromVC = transitionContext.viewController(forKey: .from) as! UIViewController & InteractiveTransitionType
      toVC = (transitionContext.viewController(forKey: .to) as! UINavigationController).topViewController as! UIViewController & InteractiveTransitionType

      toVC.beginAppearanceTransition(true, animated: true)
      fromVC.beginAppearanceTransition(false, animated: false)
    }

    toVC.view.layoutIfNeeded()


//    guard let snapshotView = fromVC.bodyView.snapshotView(afterScreenUpdates: true) else { return }
    let snapshotView = UIView()
    snapshotView.backgroundColor = fromVC.bodyView.backgroundColor
    snapshotView.frame = fromVC.bodyView.frame
    snapshotView.layer.cornerRadius = fromVC.bodyView.layer.cornerRadius

//    let animation = CABasicAnimation(keyPath: "cornerRadius")
//    animation.duration = transitionDuration(using: transitionContext)
//    animation.fromValue = fromVC.bodyView.layer.cornerRadius
//    animation.toValue = toVC.bodyView.layer.cornerRadius
//    animation.autoreverses = false
//    animation.isRemovedOnCompletion = false
//    animation.fillMode = CAMediaTimingFillMode.forwards
//    snapshotView.layer.add(animation, forKey: nil)

//    snapshotView.transform = fromVC.bodyView.transform
    transitionContext.containerView.addSubview(snapshotView)
    transitionContext.containerView.backgroundColor = fromVC.view.backgroundColor

    fromVC.bodyView.alpha = 0
    toVC.view.alpha = 0
    toVC.bodyView.alpha = 0

    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      animations: {
        fromVC.view.alpha = 0
        toVC.view.alpha = 1
        snapshotView.frame = toVC.bodyView.frame
        snapshotView.layer.cornerRadius = toVC.bodyView.layer.cornerRadius
//        snapshotView.transform = toVC.bodyView.transform
    },
      completion: { _ in
        fromVC.bodyView.alpha = 1
        fromVC.view.alpha = 1
        toVC.view.alpha = 1
        toVC.bodyView.alpha = 1
        snapshotView.removeFromSuperview()
        toVC.endAppearanceTransition()
        fromVC.endAppearanceTransition()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })

  }
}
