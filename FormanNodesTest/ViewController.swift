//
//  ViewController.swift
//  FormanNodesTest
//
//  Created by Miłosz Filimowski on 21/01/2022.
//

import UIKit


class ViewController: UIViewController {
    let customView = DiagramView()

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.backgroundColor = .white

        let navItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNode))

        navigationItem.title = "TEST"
        navigationItem.rightBarButtonItem = navItem
    }

    @objc func addNode() {
        customView.add(node: NodeView())
    }

    override func loadView() {
        view = customView
    }
}

