import UIKit

extension CGPath {
    static func pathFrom(point startPoint: CGPoint, to endPoint: CGPoint) -> CGPath {
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
        return curvedPath.copy(dashingWithPhase: 0, lengths: [0, 10])
    }
}
