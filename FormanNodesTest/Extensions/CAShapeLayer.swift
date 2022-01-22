import UIKit

extension CAShapeLayer {
    static func createConnectionLayer(with bounds: CGRect) -> CAShapeLayer {
        let connectionLayer = CAShapeLayer()
        connectionLayer.frame = bounds
        connectionLayer.zPosition = -1;
        connectionLayer.lineWidth = 2;
        connectionLayer.fillColor = UIColor.clear.cgColor;
        connectionLayer.strokeColor = UIColor(red: 0.49, green: 0.52, blue: 0.56, alpha: 1).cgColor
        connectionLayer.allowsEdgeAntialiasing = true
        connectionLayer.lineCap = CAShapeLayerLineCap.round
        return connectionLayer
    }
}
