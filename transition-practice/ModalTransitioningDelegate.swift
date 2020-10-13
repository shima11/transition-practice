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

  let interactor: InteractiveTransition = .init()
}

extension ModalTransitioningDelegate : UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

     return MatchedTransitionAnimator(isPresented: true)
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    return MatchedTransitionAnimator(isPresented: false)
  }

  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

    return nil
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

    return interactor.hasStarted ? interactor : nil
  }

  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

    return nil
  }

}
