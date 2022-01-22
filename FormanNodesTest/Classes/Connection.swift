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

    deinit {
        print("Connection destroyed")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }
}
