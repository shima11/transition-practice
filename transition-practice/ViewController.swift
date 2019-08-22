//
//  ViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/03/26.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit
import EasyPeasy

class ViewController: UIViewController {

  let moveObject: UIView = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

//    let button = UIButton(type: .system)
//    button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
//    button.frame = .init(x: 0, y: 0, width: 100, height: 100)
//    button.center = view.center
//    button.setTitle("open", for: .normal)
//    view.addSubview(button)

    moveObject.backgroundColor = .darkGray
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
    moveObject.addGestureRecognizer(tapGesture)
    view.addSubview(moveObject)

    moveObject.easy.layout(
      Center(),
      Size(100)
    )
  }

  @objc func didTapButton() {

    let controller = DetailViewController()
    present(controller, animated: true, completion: nil)
  }

}
