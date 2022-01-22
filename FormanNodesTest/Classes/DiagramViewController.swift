import UIKit

class DiagramViewController: UIViewController {
    private var nodes: [NodeView] = []
    private lazy var scrollDelegate = DiagramScrollViewDelegate(diagramViewController: self)

    private(set) lazy var diagramView = DiagramView(frame: view.frame)

    var currentContentOffset = CGPoint.zero
    var currentContentSize = CGSize.zero
    var currentZoomScale: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(diagramView)

        currentContentSize = diagramView.contentView.frame.size
        currentContentOffset = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)

        diagramView.scrollView.delegate = scrollDelegate
        diagramView.scrollView.contentOffset = currentContentOffset
        diagramView.scrollView.contentSize = currentContentSize
    }

    func add(node: NodeView) {
        node.frame = CGRect(origin: CGPoint(
            x: (currentContentOffset.x + view.bounds.width / 2) / currentZoomScale,
            y: (currentContentOffset.y + view.bounds.height / 2) / currentZoomScale
        ), size: CGSize(width: 80, height: 80))

        if let inputNode = nodes.last {
            let connectionLayer = CAShapeLayer.createConnectionLayer(with: diagramView.contentView.bounds)

            let connection = Connection(parent: inputNode, child: node, layer: connectionLayer)
            inputNode.connections += [connection]
            node.connections += [connection]

            diagramView.contentView.layer.addSublayer(connectionLayer)
            adjust(connection: connection)
        }

        diagramView.contentView.addSubview(node)
        nodes.append(node)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        node.isUserInteractionEnabled = true
        node.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        tapGesture.numberOfTapsRequired = 1
        node.addGestureRecognizer(tapGesture)
    }

    func adjust(connection: Connection) {
        guard let child = connection.childNode,
              let parent = connection.parentNode,
              let connectionLayer = connection.connectionLayer
        else { return }

        let startPoint = connectionLayer.convert(child.center, from: diagramView.contentView.layer)
        let targetPoint = connectionLayer.convert(parent.center, from: diagramView.contentView.layer)
        connectionLayer.path = CGPath.pathFrom(point: startPoint, to: targetPoint)
    }
}

extension DiagramViewController {
    @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer){
        guard let nodeView = recognizer.view as? NodeView else { return }

        let translation = recognizer.translation(in: nodeView)
        nodeView.center = CGPoint(x: nodeView.center.x + translation.x, y: nodeView.center.y + translation.y)
        recognizer.setTranslation(.zero, in: nodeView)

        nodeView.connections.forEach(adjust)
    }

    @objc func tapGestureHandler(_ recognizer: UITapGestureRecognizer){
        guard let nodeView = recognizer.view as? NodeView else { return }

        nodeView.removeFromSuperview()
        nodes.removeAll { $0 == nodeView }

        guard !nodeView.connections.isEmpty else { return }

        nodeView.connections.forEach { conn in
            if conn.parentNode == nodeView {
                conn.childNode?.connections.removeAll(where: { $0 == conn })
            }

            if conn.childNode == nodeView {
                conn.parentNode?.connections.removeAll(where: { $0 == conn })
            }
            conn.connectionLayer?.removeFromSuperlayer()
        }

    }
}
