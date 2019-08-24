//
//  Interactor.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

//class InteractiveTransition: UIPercentDrivenInteractiveTransition {
//
//  var hasStarted = false
//  var shouldFinish = false
//}

class InteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {

  private(set) var hasStarted = false
  private var shouldFinish = false

  private var draggableView: UIView?
//  private var beginPoint: CGPoint?
  private var draggableViewFinalFrame: CGRect!
  private var draggableViewInitialFrame: CGRect!
//  private var fromSnapshot: UIView?
//  private let coverView = UIView()
//  private var startedPop = false

  private var currentTransitionContext: UIViewControllerContextTransitioning?
  private var targetViewController: (UIViewController & InteractiveTransitionType)?

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

    self.currentTransitionContext = transitionContext

//    let fromViewController = transitionContext.viewController(forKey: .from) as! UIViewController & InteractiveTransitionType
    let fromViewController = targetViewController!
    let toViewController = (transitionContext.viewController(forKey: .to) as! UINavigationController).topViewController as! UIViewController & InteractiveTransitionType

    let snapshotSourceView: UIView = fromViewController.bodyView.snapshotView(afterScreenUpdates: true)!
    self.draggableView = snapshotSourceView
    self.draggableViewInitialFrame = snapshotSourceView.frame
    self.draggableViewFinalFrame = toViewController.bodyView.frame

    transitionContext.containerView.addSubview(snapshotSourceView)

    fromViewController.bodyView.alpha = 0
  }

  func setTriggerGesture(target: UIViewController & InteractiveTransitionType) {

    self.targetViewController = target

    let panGesture = UIPanGestureRecognizer()
    panGesture.addTarget(self, action: #selector(panEvent(sender:)))
    panGesture.delegate = self
    target.view.addGestureRecognizer(panGesture)
  }
  

  @objc private func panEvent(sender: UIPanGestureRecognizer) {

    guard let target = sender.view else { return }

    let percentThreshold: CGFloat = 0.3

    let translation = sender.translation(in: target)
    let verticalMovement = translation.y / target.bounds.height
    let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
    let downwardMovementPercent = fminf(downwardMovement, 1.0)
    let progress = CGFloat(downwardMovementPercent)

    switch sender.state {
    case .began:

      beganInteraction()
      targetViewController?.dismiss(animated: true, completion: nil)

      guard let draggableView = self.draggableView else { return }
      currentTransitionContext?.containerView.addSubview(draggableView)

    case .changed:
      changedInteraction(shouldFinish: progress > percentThreshold, progress: progress)

      guard let draggableView = self.draggableView else { return }

      let point = sender.translation(in: targetViewController!.view)
      draggableView.center = .init(x: draggableViewInitialFrame.midX + point.x, y: draggableViewInitialFrame.midY + point.y)

    case .cancelled, .failed:
      cancelInteraction()
      animateCancel()

    case .ended:
      finishInteraction()

      guard progress > percentThreshold else {
        animateCancel()
        return
      }

      animateFinish(velocity: sender.velocity(in: draggableView))

    default:
      break
    }

  }

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  func beganInteraction() {
    hasStarted = true
  }

  func changedInteraction(shouldFinish: Bool, progress: CGFloat) {
    self.shouldFinish = shouldFinish
    self.update(progress: progress)
  }

  func cancelInteraction() {
    hasStarted = false
    self.cancel()
  }

  func finishInteraction() {
    hasStarted = false
    shouldFinish ? self.finish() : self.cancel()
  }


  private func update(progress: CGFloat) {

  }

  private func finish() {

  }

  private func cancel() {

  }

  private func animateFinish(velocity: CGPoint) {

    guard
      let transitionContext = currentTransitionContext
      else {
        assertionFailure()
        return
    }

    transitionContext.finishInteractiveTransition()

    guard
      let currentFrame = draggableView?.frame,
      let targetFrame = draggableViewFinalFrame
      else {
        fatalError()
    }

    let base = CGVector(
      dx: targetFrame.minX - currentFrame.minX,
      dy: targetFrame.minY - currentFrame.minY
    )

    let animationDuration: TimeInterval = 0.5

    let originAnimator = UIViewPropertyAnimator(
      duration: animationDuration,
      timingParameters: UISpringTimingParameters(
        dampingRatio: 0.9,
        initialVelocity: CGVector(
          dx: (velocity.x / base.dx) * 1.5,
          dy: (velocity.y / base.dy) * 2.5
        )
      )
    )

    let sizeAnimator = UIViewPropertyAnimator(
      duration: animationDuration,
      timingParameters: UICubicTimingParameters(
        controlPoint1: .init(x: 0.15, y: 0.8),
        controlPoint2: .init(x: 0.5, y: 1)
      )
    )

//    let backgroundViewAnimator = UIViewPropertyAnimator(
//      duration: animationDuration,
//      timingParameters: UICubicTimingParameters(
//        controlPoint1: .init(x: 0.36, y: 0.68),
//        controlPoint2: .init(x: 0.5, y: 1)
//      )
//    )
//
//    backgroundViewAnimator
//      .addAnimations {
//        self.targetViewController?.view.transform = .identity
//    }

    sizeAnimator
      .addAnimations {

//        self.coverView.alpha = 0
//        self.fromSnapshot?.alpha = 0
        self.draggableView?.frame.size = self.draggableViewFinalFrame.size
    }

    originAnimator
      .addAnimations {
        self.draggableView?.frame.origin = self.draggableViewFinalFrame.origin
    }

    originAnimator
      .addCompletion { (position) in
        self.draggableView?.removeFromSuperview()
        self.currentTransitionContext?.completeTransition(self.shouldFinish)
    }

//    backgroundViewAnimator.startAnimation()
    originAnimator.startAnimation()
    sizeAnimator.startAnimation()
  }

  private func animateCancel() {

    guard
      let transitionContext = currentTransitionContext
      else {
        assertionFailure()
        return
    }

    transitionContext.cancelInteractiveTransition()

    let animator = UIViewPropertyAnimator(
      duration: 0.3,
      timingParameters: UICubicTimingParameters(animationCurve: .easeInOut)
    )

    animator.addAnimations {
//      self.fromSnapshot?.alpha = 1
//      self.fromSnapshot?.transform = .identity
//      self.draggableView?.transform = .identity
      self.draggableView?.frame.size = self.draggableViewInitialFrame.size
      self.draggableView?.frame.origin = self.draggableViewInitialFrame.origin
    }

    animator.addCompletion { _ in
      self.draggableView?.removeFromSuperview()
      self.currentTransitionContext?.completeTransition(self.shouldFinish)
      self.targetViewController?.bodyView.alpha = 1
    }

    animator.startAnimation()

  }


}
