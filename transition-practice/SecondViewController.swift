//
//  SecondViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2020/10/13.
//  Copyright © 2020 Jinsei Shima. All rights reserved.
//

import UIKit
import EasyPeasy

class SecondViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    if #available(iOS 13.0, *) {

      let action = UIAction.init(handler: { [weak self] (action) in
        let controller = SecondDetailViewController()
        self?.present(controller, animated: true, completion: nil)
      })

      let button = UIButton()
      if #available(iOS 14.0, *) {
        button.addAction(action, for: .touchUpInside)
      }
      button.setTitle("present", for: .normal)
      button.setTitleColor(.darkText, for: .normal)
      button.sizeToFit()

      view.addSubview(button)

      button.easy.layout(
        CenterX(),
        CenterY()
      )
    }

  }

}


class SecondDetailViewController: UIViewController {

  fileprivate var isInteractiveDismiss: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleSwipeFromLeft))
    left.edges = .left
    view.addGestureRecognizer(left)


    transitioningDelegate = self
  }

  @objc func handleSwipeFromLeft() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension SecondDetailViewController: UIViewControllerInteractiveTransitioning {

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    print("xxx: startInteractiveTransition")
  }
}

extension SecondDetailViewController: UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    nil
  }

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    DismissMenuAnimator()
  }

  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    nil
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    weak var _self = self
    return isInteractiveDismiss ? _self : nil
  }

}

class DismissMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.6
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    transitionContext.completeTransition(true)
  }
}
