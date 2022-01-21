//
//  ViewController.swift
//  FormanNodesTest
//
//  Created by Miłosz Filimowski on 21/01/2022.
//

import UIKit

class NodeView: UIView {
    var evalTick: Int?

    var connectionLayer: CAShapeLayer?
    var parent: NodeView?

    init() {
        super.init(frame: .zero)
        backgroundColor = .blue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class WorkspaceView: UIView {
    private var evaluationTick = 0
    private var displayLink: CADisplayLink?

    private var nodes: [NodeView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("called")

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

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        node.isUserInteractionEnabled = true
        node.addGestureRecognizer(gesture)

        if let inputNode = nodes.last {
            inputNode.connectionLayer = CAShapeLayer()
            node.parent = inputNode
            let connectionLayer = inputNode.connectionLayer!

            connectionLayer.frame = self.frame;
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
    }

    func adjust(connectionLayer: CAShapeLayer, fromNode child: NodeView, to parent: NodeView) {
        let startPoint = connectionLayer.convert(child.center, from: layer)
        let targetPoint = connectionLayer.convert(parent.center, from: layer)
        connectionLayer.path = self.pathFrom(point: startPoint, to: targetPoint)
    }

    func pathFrom(point startPoint: CGPoint, to endPoint: CGPoint) -> CGPath {
        let nodeSize: CGFloat = 72

        let sourceX = startPoint.x
        let sourceY = startPoint.y
        let targetX = endPoint.x
        let targetY = endPoint.y

        var c1X, c1Y, c2X, c2Y: CGFloat!

        if targetX - 5 < sourceX {
            let curveFactor = (sourceX - targetX) * nodeSize / 200
            if fabsf(Float(targetY - sourceY)) < Float(nodeSize / 2)  {
                c1X = sourceX + curveFactor
                c1Y = sourceY - curveFactor
                c2X = targetX - curveFactor
                c2Y = targetY - curveFactor
            } else {
                c1X = sourceX + curveFactor
                c1Y = sourceY + (targetY > sourceY ? curveFactor : -curveFactor)
                c2X = targetX - curveFactor
                c2Y = targetY + (targetY > sourceY ? -curveFactor : curveFactor)
            }
        } else {
            c1X = sourceX + (targetX - sourceX) / 2
            c1Y = sourceY
            c2X = c1X
            c2Y = targetY
        }

        let curvedPath = CGMutablePath()
        curvedPath.move(to: startPoint)
        curvedPath.addCurve(to: endPoint, control1: CGPoint(x: c1X, y: c1Y), control2: CGPoint(x: c2X, y: c2Y))
        return curvedPath;
    }

    @objc func refresh(displayLink: CADisplayLink) {
        evaluationTick += 1

        for view in subviews {
            if let node = view as? NodeView, let parent = node.parent, let connectionLayer = parent.connectionLayer {
                adjust(connectionLayer: connectionLayer, fromNode: node, to: parent)
            }
        }
    }


    private var currentScale: CGFloat = 1.0

    @objc func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        let maxScale: CGFloat = 4.0
        let minScale: CGFloat = 1.0
        if recognizer.state == .began || recognizer.state == .changed {

            let pinchScale: CGFloat = recognizer.scale

            if currentScale * pinchScale < maxScale && currentScale * pinchScale > minScale {
                currentScale *= pinchScale
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
    }
}

class ViewController: UIViewController {

    let customView = WorkspaceView()

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.backgroundColor = .white

        let navItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNode))

        navigationItem.rightBarButtonItem = navItem
        navigationItem.title = "TEST"
    }

    @objc func addNode() {
        customView.add(node: NodeView())
    }

    override func loadView() {
        view = customView
    }
}

