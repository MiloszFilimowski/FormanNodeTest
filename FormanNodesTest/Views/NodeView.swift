import UIKit

class NodeView: UIView {
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
