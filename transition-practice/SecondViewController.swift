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

  fileprivate weak var interactiveTransitionContext: UIViewControllerContextTransitioning?

  init() {

    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .overFullScreen
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBlue

    let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleSwipeFromLeft))
    left.edges = .left
    view.addGestureRecognizer(left)


    transitioningDelegate = self
  }

  @objc func handleSwipeFromLeft(_ recognizer: UIScreenEdgePanGestureRecognizer) {

    switch recognizer.state {
    case .began:
      isInteractiveDismiss = true
      self.dismiss(animated: true, completion: nil)

    case .changed:

      print(recognizer.translation(in: recognizer.view), recognizer.velocity(in: recognizer.view))

      let view = interactiveTransitionContext?.view(forKey: .from)
      let alpha = (200 - recognizer.translation(in: recognizer.view).x) / 200
      view?.alpha = alpha
      print("alpha:", alpha)

    case .cancelled, .failed:
      isInteractiveDismiss = false
      let view = interactiveTransitionContext?.view(forKey: .from)
      view?.alpha = 1
      interactiveTransitionContext?.completeTransition(false)

    case .ended:
      isInteractiveDismiss = false

      let alpha = (200 - recognizer.translation(in: recognizer.view).x) / 200
      if alpha > 0.5 {
        let view = interactiveTransitionContext?.view(forKey: .from)
        view?.alpha = 1
        interactiveTransitionContext?.completeTransition(false)
      } else {
        interactiveTransitionContext?.completeTransition(true)
      }

    case .possible:
      break
    @unknown default:
      break
    }
  }
}

extension SecondDetailViewController: UIViewControllerInteractiveTransitioning {

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

    interactiveTransitionContext = transitionContext
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
