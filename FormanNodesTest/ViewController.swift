import UIKit

class ViewController: UIViewController {
    let diagramViewController = DiagramViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        let navItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNode))

        navigationItem.title = "TEST"
        navigationItem.rightBarButtonItem = navItem
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .red

        view.addSubview(diagramViewController.view)
        addChild(diagramViewController)
        diagramViewController.didMove(toParent: self)
    }

    @objc func addNode() {
        diagramViewController.add(node: NodeView())
    }
}

