//
//  DetailViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  let interactor: Interactor = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .groupTableViewBackground
    transitioningDelegate = self

    let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
    view.addGestureRecognizer(gesture)

    let closeButton = UIButton()
    closeButton.setTitle("x", for: .normal)
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    closeButton.frame = .init(x: 0, y: 0, width: 36, height: 36)
    closeButton.center = view.center
    closeButton.layer.cornerRadius = 18
    closeButton.backgroundColor = .darkGray
    view.addSubview(closeButton)

  }

  @objc func close() {

    dismiss(animated: true, completion: nil)
  }

  @objc func panGesture(sender: UIPanGestureRecognizer) {

    let percentThreshold: CGFloat = 0.3

    // convert y-position to downward pull progress (percentage)
    let translation = sender.translation(in: view)
    let verticalMovement = translation.y / view.bounds.height
    let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
    let downwardMovementPercent = fminf(downwardMovement, 1.0)
    let progress = CGFloat(downwardMovementPercent)

    switch sender.state {
    case .began:
      interactor.hasStarted = true
      dismiss(animated: true, completion: nil)

    case .changed:
      interactor.shouldFinish = progress > percentThreshold
      interactor.update(progress)

    case .cancelled:
      interactor.hasStarted = false
      interactor.cancel()

    case .ended:
      interactor.hasStarted = false
      interactor.shouldFinish
        ? interactor.finish()
        : interactor.cancel()

    default:
      break
    }
  }

}

extension DetailViewController: UIViewControllerTransitioningDelegate {

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return DismissAnimator()
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactor.hasStarted ? interactor : nil
  }
}
