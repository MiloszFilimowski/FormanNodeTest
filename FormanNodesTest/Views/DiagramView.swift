import UIKit

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
        node.frame = CGRect(origin: CGPoint(x: bounds.size.width  / 2,
                                            y: bounds.size.height / 2), size: CGSize(width: 80, height: 80))
        addSubview(node)

        if let inputNode = nodes.last, inputNode.parent == nil {
            inputNode.connectionLayer = CAShapeLayer()
            node.parent = inputNode
            let connectionLayer = inputNode.connectionLayer!

            connectionLayer.frame = frame;
            connectionLayer.zPosition = -1;
            connectionLayer.lineWidth = 2;
            connectionLayer.fillColor = UIColor.clear.cgColor;
            connectionLayer.strokeColor = UIColor(red: 0.49, green: 0.52, blue: 0.56, alpha: 1).cgColor
            connectionLayer.allowsEdgeAntialiasing = true
            connectionLayer.lineCap = CAShapeLayerLineCap.round;

            self.layer.addSublayer(connectionLayer)


            adjust(connectionLayer: connectionLayer, fromNode: node, to: inputNode)
        }

        nodes.append(node)

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        node.isUserInteractionEnabled = true
        node.addGestureRecognizer(gesture)
    }

    func adjust(connectionLayer: CAShapeLayer, fromNode child: NodeView, to parent: NodeView) {
        let startPoint = connectionLayer.convert(child.center, from: layer)
        let targetPoint = connectionLayer.convert(parent.center, from: layer)
        connectionLayer.path = CGPath.pathFrom(point: startPoint, to: targetPoint)
    }

    var shouldUpdate = true

    @objc func refresh(displayLink: CADisplayLink) {
        guard shouldUpdate else { return }
        shouldUpdate = false
        for view in subviews {
            if let node = view as? NodeView, let parent = node.parent, let connectionLayer = parent.connectionLayer {
                adjust(connectionLayer: connectionLayer, fromNode: node, to: parent)
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
                shouldUpdate = true
            }
            recognizer.scale = 1.0
        }
    }

    @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer){
        guard let nodeView = recognizer.view as? NodeView else { return }

        let translation = recognizer.translation(in: nodeView)
        nodeView.center = CGPoint(x: nodeView.center.x + translation.x, y: nodeView.center.y + translation.y)
        recognizer.setTranslation(.zero, in: nodeView)
        shouldUpdate = true
    }
}
