//
//  ViewController.swift
//  transition-practice
//
//  Created by jinsei_shima on 2019/03/26.
//  Copyright © 2019 Jinsei Shima. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 100, height: 100)
        button.center = view.center
        button.setTitle("hoge", for: .normal)
        view.addSubview(button)

    }

    @objc func didTapButton() {

        let controller = DetailViewController()
        present(controller, animated: true, completion: nil)
    }


}


class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.frame = .init(x: 0, y: 0, width: 100, height: 100)
        button.center = view.center
        button.setTitle("hoge", for: .normal)
        view.addSubview(button)

    }

    @objc func didTapButton() {

        let controller = DetailViewController()
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
        
    }

}
