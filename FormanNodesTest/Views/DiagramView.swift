import UIKit

class Connection: Hashable {
    let id = UUID()
    weak var connectionLayer: CAShapeLayer?
    weak var parentNode: NodeView?
    weak var childNode: NodeView?

    init(parent: NodeView, child: NodeView, layer: CAShapeLayer) {
        self.parentNode = parent
        self.childNode = child
        self.connectionLayer = layer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }
}

class DiagramView: UIView {
    private var currentViewScale: CGFloat = 1.0
    private var displayLink: CADisplayLink?

    private var nodes: [NodeView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:))))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
            displayLink = CADisplayLink(target: self, selector: #selector(refresh(displayLink:)))
            displayLink?.add(to: .main, forMode: .default)
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    func add(node: NodeView) {
        node.frame = CGRect(origin: CGPoint(
            x: bounds.size.width  / 2,
            y: bounds.size.height / 2
        ), size: CGSize(width: 80, height: 80))

        if let inputNode = nodes.last {
            let connectionLayer = createConnectionLayer()

            let connection = Connection(parent: inputNode, child: node, layer: connectionLayer)
            inputNode.connections += [connection]
            node.connections += [connection]

            layer.addSublayer(connectionLayer)
            adjust(connection: connection)
        }

        addSubview(node)
        nodes.append(node)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        node.isUserInteractionEnabled = true
        node.addGestureRecognizer(panGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        tapGesture.numberOfTapsRequired = 1
        node.addGestureRecognizer(tapGesture)
    }

    func createConnectionLayer() -> CAShapeLayer {
        let connectionLayer = CAShapeLayer()
        connectionLayer.frame = frame;
        connectionLayer.zPosition = -1;
        connectionLayer.lineWidth = 2;
        connectionLayer.fillColor = UIColor.clear.cgColor;
        connectionLayer.strokeColor = UIColor(red: 0.49, green: 0.52, blue: 0.56, alpha: 1).cgColor
        connectionLayer.allowsEdgeAntialiasing = true
        connectionLayer.lineCap = CAShapeLayerLineCap.round
        return connectionLayer
    }

    func adjust(connection: Connection) {
        guard let child = connection.childNode,
              let parent = connection.parentNode,
              let connectionLayer = connection.connectionLayer
        else { return }

        let startPoint = connectionLayer.convert(child.center, from: layer)
        let targetPoint = connectionLayer.convert(parent.center, from: layer)
        connectionLayer.path = CGPath.pathFrom(point: startPoint, to: targetPoint)
    }

    var affectedNodes: [NodeView: Bool] = [:]

    @objc func refresh(displayLink: CADisplayLink) {
        let nodesToUpdate = affectedNodes
        affectedNodes = [:]
        var seenConnections: [Connection: Bool] = [:]
        nodesToUpdate.keys.forEach { node in
            node.connections.forEach { connection in
                guard seenConnections[connection] == nil else { return }
                seenConnections[connection] = true
                adjust(connection: connection)
            }
        }
    }

    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        let maxScale: CGFloat = 4.0
        let minScale: CGFloat = 1.0
        if recognizer.state == .began || recognizer.state == .changed {

            let pinchScale: CGFloat = recognizer.scale

            if currentViewScale * pinchScale < maxScale && currentViewScale * pinchScale > minScale {
                currentViewScale *= pinchScale
                transform = (transform.scaledBy(x: pinchScale, y: pinchScale))
            }
            recognizer.scale = 1.0
        }
    }

    @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer){
        guard let nodeView = recognizer.view as? NodeView else { return }

        let translation = recognizer.translation(in: nodeView)
        nodeView.center = CGPoint(x: nodeView.center.x + translation.x, y: nodeView.center.y + translation.y)
        recognizer.setTranslation(.zero, in: nodeView)

        affectedNodes[nodeView] = true
    }

    @objc func tapGestureHandler(_ recognizer: UITapGestureRecognizer){
        print("on press")
        guard let nodeView = recognizer.view as? NodeView else { return }

        nodeView.removeFromSuperview()

        guard !nodeView.connections.isEmpty else { return }

        nodeView.connections.forEach { conn in
            if conn.parentNode == nodeView {
                conn.childNode?.connections.removeAll(where: { nestedConn in
                    nestedConn == conn
                })
            }

            if conn.childNode == nodeView {
                conn.parentNode?.connections.removeAll(where: { nestedConn in
                    nestedConn == conn
                })
            }
            conn.connectionLayer?.removeFromSuperlayer()
        }

    }
}
