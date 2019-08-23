//
//  ModalTransitioning.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

protocol InteractiveTransitionType: class {
  var bodyView: UIView { get }
}

class ModalTransitioningDelegate: NSObject {


  let fromViewController: (UIViewController & InteractiveTransitionType)

  init(fromViewController: (UIViewController & InteractiveTransitionType)) {

    self.fromViewController = fromViewController

    super.init()
  }

  let interactor: InteractiveTransition = .init()

  func beganInteraction() {
    interactor.hasStarted = true
  }
  
  func changedInteraction(shouldFinish: Bool, progress: CGFloat) {
    interactor.shouldFinish = shouldFinish
    interactor.update(progress)
  }

  func cancelInteraction() {
    interactor.hasStarted = false
    interactor.cancel()
  }

  func finishInteraction() {
    interactor.hasStarted = false
    interactor.shouldFinish ? interactor.finish() : interactor.cancel()
  }
  
}

extension ModalTransitioningDelegate : UIViewControllerTransitioningDelegate {

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return DismissAnimator(fromViewController: fromViewController)
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

    return interactor.hasStarted ? interactor : nil
  }

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

    return nil
  }

}
