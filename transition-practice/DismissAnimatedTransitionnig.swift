//
//  DismissAnimator.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  let fromViewController: (UIViewController & InteractiveTransitionType)

  init(fromViewController: (UIViewController & InteractiveTransitionType)) {
    self.fromViewController = fromViewController
    super.init()
  }


  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    let fromVC = transitionContext.viewController(forKey: .from) as! UIViewController & InteractiveTransitionType
    let toVC = (transitionContext.viewController(forKey: .to) as! UINavigationController).topViewController as! UIViewController & InteractiveTransitionType
//    let toVC = fromViewController

    let finalFrame = toVC.bodyView.frame

    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      animations: {
        fromVC.bodyView.frame = finalFrame
    },
      completion: { _ in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })

  }
}
