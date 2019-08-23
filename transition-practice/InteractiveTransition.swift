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

  private weak var currentTransitionContext: UIViewControllerContextTransitioning?
  private weak var targetViewController: (UIViewController & InteractiveTransitionType)?

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

    self.currentTransitionContext = transitionContext

    let fromViewController = transitionContext.viewController(forKey: .from) as! UIViewController & InteractiveTransitionType

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

    let percentThreshold: CGFloat = 0

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

//      let transform = draggableView.transform.translatedBy(x: draggableViewInitialFrame.midX + point.x, y: draggableViewInitialFrame.midY + point.y)
//      draggableView.transform = transform

      draggableView.center = .init(x: draggableViewInitialFrame.midX + point.x, y: draggableViewInitialFrame.midY + point.y)

    case .cancelled, .failed:
      cancelInteraction()
      currentTransitionContext?.completeTransition(shouldFinish)

    case .ended:
      finishInteraction()
      currentTransitionContext?.completeTransition(shouldFinish)


      

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

}
