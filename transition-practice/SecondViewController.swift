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
        let _controller = SecondDetailViewController()
        let controller = UINavigationController(rootViewController: _controller)
        controller.modalPresentationStyle = .overFullScreen
        controller.transitioningDelegate = _controller
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


// https://github.com/aunnnn/AppStoreiOS11InteractiveTransition
// https://github.com/alberdev/CiaoTransitions
// https://github.com/SebastianBoldt/Jelly
// https://github.com/cocoatoucher/AICustomViewControllerTransition

class SecondDetailViewController: UIViewController {

  fileprivate var isInteractiveDismiss: Bool = false

  fileprivate weak var interactiveTransitionContext: UIViewControllerContextTransitioning?

  init() {

    super.init(nibName: nil, bundle: nil)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // TODO: Pull To Bottom で閉じれるようにする

    // TODO: ScrollViewがある状態での pull to bottomを実装

    view.backgroundColor = .systemBlue
    navigationController?.navigationBar.barTintColor = .systemGreen

    let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleSwipeFromLeft))
    left.edges = .left
    view.addGestureRecognizer(left)

//    transitioningDelegate = self

    if #available(iOS 14.0, *) {
      let button = UIButton(primaryAction: .init(title: "Dismiss", handler: { [unowned self] (action) in
        self.dismiss(animated: true, completion: nil)
      }))
      button.setTitleColor(.darkText, for: .normal)
      button.sizeToFit()
      button.center = view.center
      view.addSubview(button)
    }

  }

  func didCancelDismissalTransition() {
    interactiveStartingPoint = nil
    dismissalAnimator = nil
//      draggingDownToDismiss = false
  }

  var interactiveStartingPoint: CGPoint?
  var dismissalAnimator: UIViewPropertyAnimator?

  @objc func handleSwipeFromLeft(_ gesture: UIPanGestureRecognizer) {

    //      let isScreenEdgePan = gesture.isKind(of: DismissalScreenEdgePanGesture.self)
//    let isScreenEdgePan = true
    //      let canStartDragDownToDismissPan = !isScreenEdgePan && !draggingDownToDismiss

    let startingPoint: CGPoint

    if let p = interactiveStartingPoint {
      startingPoint = p
    } else {
      startingPoint = gesture.location(in: nil)
      interactiveStartingPoint = startingPoint
    }

    func progress() -> CGFloat? {

      guard let targetView = interactiveTransitionContext?.viewController(forKey: .from)?.view else {
        return nil
      }
      return gesture.translation(in: targetView).x / targetView.bounds.width
    }

    switch gesture.state {
    case .began:

      isInteractiveDismiss = true

      self.dismiss(animated: true, completion: nil)

    case .changed:

      if let progress = progress() {
        dismissalAnimator!.fractionComplete = progress
      }

    case .ended, .cancelled, .failed:

      isInteractiveDismiss = false

      guard let dismissalAnimator = dismissalAnimator else {
        didCancelDismissalTransition()
        return
      }

      dismissalAnimator.pauseAnimation()

      if progress()! > 0.5 {

        dismissalAnimator.isReversed = false
        dismissalAnimator.addCompletion { [unowned self] (pos) in
          self.interactiveTransitionContext?.completeTransition(true)
          gesture.isEnabled = true
        }

      } else {

        dismissalAnimator.isReversed = true
        dismissalAnimator.addCompletion { [unowned self] (pos) in
          self.didCancelDismissalTransition()
          self.interactiveTransitionContext?.completeTransition(false)
          gesture.isEnabled = true
        }
      }

      gesture.isEnabled = false

      dismissalAnimator.startAnimation()

    default:
      fatalError("Impossible gesture state? \(gesture.state.rawValue)")
    }
  }

}

extension SecondDetailViewController: UIViewControllerInteractiveTransitioning {

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

    interactiveTransitionContext = transitionContext

    guard let targetView = transitionContext.viewController(forKey: .from) else {
      assertionFailure()
      return
    }
    let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1, animations: {
      targetView.view.transform = .init(translationX: targetView.view.bounds.width, y: 0)
    })
    animator.isReversed = false
    animator.pauseAnimation()
    dismissalAnimator = animator
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
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    guard let fromVC = transitionContext.viewController(forKey: .from) else {
      transitionContext.completeTransition(false)
      return
    }

    let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1, animations: {
      fromVC.view.transform = .init(translationX: 0, y: fromVC.view.bounds.height)
    })
    animator.addCompletion { (position) in
      transitionContext.completeTransition(true)
    }
    animator.startAnimation()
  }
}
