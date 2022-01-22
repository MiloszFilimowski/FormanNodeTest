import UIKit

class DiagramView: UIView {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        scrollView.decelerationRate = .fast
        scrollView.maximumZoomScale = 3
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        print(frame)

        scrollView.frame = bounds
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width * 2, height: bounds.height * 2)

        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
