import UIKit

class NodeView: UIView {
    let id = UUID()

    // TODO: Check for cycles
    var connections: [Connection] = []

    init() {
        super.init(frame: .zero)
        backgroundColor = .blue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
