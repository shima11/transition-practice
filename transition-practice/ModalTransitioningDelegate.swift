//
//  ModalTransitioning.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

class ModalTransitioningDelegate: NSObject {

  var interactor: InteractiveTransition?
}

extension ModalTransitioningDelegate : UIViewControllerTransitioningDelegate {

  func setInteractiveTransition(_ transition: InteractiveTransition) {
    self.interactor = transition
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DismissAnimator()
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return (interactor?.hasStarted ?? false) ? interactor : nil
  }

}
