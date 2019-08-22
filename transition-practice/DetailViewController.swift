//
//  DetailViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/08/22.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit
import EasyPeasy

class DetailViewController: UIViewController {

  let interactor: Interactor = .init()

  let moveObject: UIView = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .groupTableViewBackground
    transitioningDelegate = self

    let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
    view.addGestureRecognizer(gesture)

    moveObject.backgroundColor = .darkGray

    let closeButton = UIButton()
    closeButton.setTitle("x", for: .normal)
    closeButton.setTitleColor(.white, for: .normal)
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    closeButton.layer.cornerRadius = 18
    closeButton.backgroundColor = UIColor.init(white: 0, alpha: 0.8)

    view.addSubview(moveObject)
    view.addSubview(closeButton)

    moveObject.easy.layout(
      Left(),
      Top(),
      Right(),
      Height(300)
    )

    closeButton.easy.layout(
      Top(32).to(view.safeAreaLayoutGuide, .top),
      Right(32),
      Size(36)
    )

  }

  @objc func close() {

    dismiss(animated: true, completion: nil)
  }

  @objc func panGesture(sender: UIPanGestureRecognizer) {

    let percentThreshold: CGFloat = 0.3

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
