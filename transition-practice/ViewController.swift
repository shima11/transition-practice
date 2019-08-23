//
//  ViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/03/26.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit
import EasyPeasy

class ViewController: UIViewController, InteractiveTransitionType {

  var bodyView: UIView {
    return moveObject1
  }
  
  let moveObject1: UIView = .init()
  let moveObject2: UIView = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    moveObject1.backgroundColor = .gray
    let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(didTapObject1))
    moveObject1.addGestureRecognizer(tapGesture1)
    view.addSubview(moveObject1)

    moveObject2.backgroundColor = .darkGray
    let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(didTapObject2))
    moveObject2.addGestureRecognizer(tapGesture2)
    view.addSubview(moveObject2)

    moveObject1.easy.layout(
      CenterX(),
      CenterY(-100),
      Size(100)
    )

    moveObject2.easy.layout(
      CenterX(),
      CenterY(100),
      Size(100)
    )

  }

  @objc func didTapObject1() {

    let delegate = ModalTransitioningDelegate(fromViewController: self)
    let controller = DetailViewController(modalTransitioning: delegate)
//    controller.modalPresentationStyle = .overCurrentContext
    present(controller, animated: true, completion: nil)
  }

  @objc func didTapObject2() {

    let delegate = ModalTransitioningDelegate(fromViewController: self)
    let controller = DetailViewController(modalTransitioning: delegate)
    navigationController?.pushViewController(controller, animated: true)
  }
}
