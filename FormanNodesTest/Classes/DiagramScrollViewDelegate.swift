import UIKit

class DiagramScrollViewDelegate: NSObject, UIScrollViewDelegate {
    private weak var diagramViewController: DiagramViewController?
    private var canApplyYScroll = true
    private var canApplyXScroll = true

    init(diagramViewController: DiagramViewController) {
        self.diagramViewController = diagramViewController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        diagramViewController?.diagramView.contentView
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        canApplyYScroll = true
        canApplyXScroll = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let vc = diagramViewController, vc.isViewLoaded && vc.view.window != nil else { return }

        vc.currentContentOffset = scrollView.contentOffset
        vc.currentContentSize = scrollView.contentSize
        vc.currentZoomScale = scrollView.zoomScale

        let triggerFactor = 0.75
        let triggerOffsetX = vc.currentContentSize.width - vc.view.bounds.width - vc.view.bounds.width * (1 - triggerFactor)
        let triggerOffsetY = vc.currentContentSize.height - vc.view.bounds.height - vc.view.bounds.height * (1 - triggerFactor)

        var newContentSize = scrollView.contentSize

        if canApplyXScroll && vc.currentContentOffset.x >= triggerOffsetX {
            canApplyXScroll = false
            newContentSize.width += vc.view.bounds.width / 2
        }

        if canApplyYScroll && vc.currentContentOffset.y >= triggerOffsetY{
            canApplyYScroll = false
            newContentSize.height += vc.view.bounds.height / 2
        }

        vc.currentContentSize = newContentSize
        vc.diagramView.contentView.frame = CGRect(origin: vc.diagramView.contentView.bounds.origin, size: newContentSize)
        scrollView.contentSize = newContentSize
    }
}
