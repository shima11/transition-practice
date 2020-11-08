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

    if #available(iOS 14.0, *) {

      let button = UIButton(primaryAction: .init(title: "present", handler: { [weak self] _ in
        let _controller = SecondDetailViewController()
        let controller = UINavigationController(rootViewController: _controller)
        controller.modalPresentationStyle = .overFullScreen
        controller.transitioningDelegate = _controller
        self?.present(controller, animated: true, completion: nil)
      }))
      button.setTitleColor(.darkText, for: .normal)
      button.sizeToFit()

      view.addSubview(button)

      button.easy.layout(
        CenterX(),
        CenterY()
      )

      do {

        let button = UIButton(primaryAction: .init(title: "Push", handler: { [unowned self] (action) in
          let controller = UIViewController()
          controller.view.backgroundColor = .white
          self.navigationController?.pushViewController(controller, animated: true)
        }))
        button.setTitleColor(.darkText, for: .normal)
        button.sizeToFit()
        button.center = .init(x: view.center.x, y: view.center.y + 100)
        view.addSubview(button)

      }

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

    // TODO: ScrollViewがある状態での pull to bottomを実装

    view.backgroundColor = .systemBlue
    navigationController?.navigationBar.barTintColor = .systemGreen

    let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handleSwipeFromLeft))
    edgePanGesture.edges = .left

    let pullDownGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePullDown(_:)))

    pullDownGesture.require(toFail: edgePanGesture)

    view.addGestureRecognizer(edgePanGesture)
    view.addGestureRecognizer(pullDownGesture)


    let scrollView = UIScrollView()
    scrollView.alwaysBounceVertical = true
    scrollView.delegate = self
    view.addSubview(scrollView)
    scrollView.easy.layout(Edges())

//    scrollView.panGestureRecognizer.require(toFail: edgePanGesture)
//    scrollView.panGestureRecognizer.require(toFail: pullDownGesture)

    // ScrollViewのScrollをハンドリングしてdismissを呼ばないといけないかもしれない
    

    if #available(iOS 14.0, *) {

      let button = UIButton(primaryAction: .init(title: "Dismiss", handler: { [unowned self] (action) in
        self.dismiss(animated: true, completion: nil)
      }))
      button.setTitleColor(.darkText, for: .normal)
      button.sizeToFit()
      button.center = view.center
      scrollView.addSubview(button)

      do {

        let button = UIButton(primaryAction: .init(title: "Push", handler: { [unowned self] (action) in
          let controller = UIViewController()
          controller.view.backgroundColor = .white
          self.navigationController?.pushViewController(controller, animated: true)
        }))
        button.setTitleColor(.darkText, for: .normal)
        button.sizeToFit()
        button.center = .init(x: view.center.x, y: view.center.y + 100)
        scrollView.addSubview(button)

      }
    }

  }

  func didCancelDismissalTransition() {
    edgeSwipeDismissAnimator = nil
    pullToDismissAnimator = nil
  }

  private var edgeSwipeDismissAnimator: UIViewPropertyAnimator?
  private var pullToDismissAnimator: UIViewPropertyAnimator?

  private var isEdgeSwipeDismiss: Bool = false
  private var isPullToDismiss: Bool = false

  @objc func handleSwipeFromLeft(_ gesture: UIPanGestureRecognizer) {

    func progress() -> CGFloat? {

      guard let targetView = interactiveTransitionContext?.viewController(forKey: .from)?.view else {
        assertionFailure()
        return nil
      }
      return gesture.translation(in: targetView).x / targetView.bounds.width
    }

    switch gesture.state {
    case .began:

      isInteractiveDismiss = true
      isEdgeSwipeDismiss = true

      self.dismiss(animated: true, completion: nil)

    case .changed:

      if let progress = progress() {
        print("xxx", progress)
        edgeSwipeDismissAnimator!.fractionComplete = progress
      }

    case .ended, .cancelled, .failed:

      isInteractiveDismiss = false
      isEdgeSwipeDismiss = false

      guard let dismissalAnimator = edgeSwipeDismissAnimator else {
        didCancelDismissalTransition()
        gesture.isEnabled = true
        return
      }

      dismissalAnimator.pauseAnimation()

      // TODO: progressとvelocityを考慮してdismiss判定

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

  @objc func handlePullDown(_ gesture: UIPanGestureRecognizer) {

    hoge(gesture: gesture)
  }


  func hoge(gesture: UIPanGestureRecognizer) {

    func progress() -> CGFloat? {

      guard let targetView = interactiveTransitionContext?.viewController(forKey: .from)?.view else {
        return nil
      }
      return gesture.translation(in: targetView).y / targetView.bounds.height
    }

    switch gesture.state {
    case .began:

      isInteractiveDismiss = true
      isPullToDismiss = true

      self.dismiss(animated: true, completion: nil)

    case .changed:

      if let progress = progress() {
        print("yyy", progress)
        pullToDismissAnimator!.fractionComplete = progress
      }

    case .ended, .cancelled, .failed:

      isInteractiveDismiss = false
      isPullToDismiss = false

      guard let dismissalAnimator = pullToDismissAnimator else {
        didCancelDismissalTransition()
        gesture.isEnabled = true
        return
      }

      dismissalAnimator.pauseAnimation()

      // TODO: progressとvelocityを考慮してdismiss判定

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
      break
//      fatalError("Impossible gesture state? \(gesture.state.rawValue)")
    }

  }
}

extension SecondDetailViewController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {

    hoge(gesture: scrollView.panGestureRecognizer)

  }
}

extension SecondDetailViewController: UIViewControllerInteractiveTransitioning {

  func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {

    interactiveTransitionContext = transitionContext

    guard let targetView = transitionContext.viewController(forKey: .from) else {
      assertionFailure()
      return
    }

    switch (isPullToDismiss, isEdgeSwipeDismiss) {
    case (true, false):

      let pullToDismissAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1, animations: {
        targetView.view.transform = .init(translationX: 0, y: targetView.view.bounds.height)
      })
      pullToDismissAnimator.isReversed = false
      pullToDismissAnimator.pauseAnimation()
      self.pullToDismissAnimator = pullToDismissAnimator

    case (false, true):

      let edgeSwipeDismissAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1, animations: {
        targetView.view.transform = .init(translationX: targetView.view.bounds.width, y: 0)
      })
      edgeSwipeDismissAnimator.isReversed = false
      edgeSwipeDismissAnimator.pauseAnimation()
      self.edgeSwipeDismissAnimator = edgeSwipeDismissAnimator

    default:
      break
    }

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
