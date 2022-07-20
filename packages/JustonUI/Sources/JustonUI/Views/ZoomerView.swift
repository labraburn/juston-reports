//
//  Created by Anton Spivak
//
//  Some code getted from here
//  https://github.com/muukii/ZoomImageView/blob/master/ZoomImageView/ZoomImageView.swift
//
//  But some getted from my mind
//

import UIKit

/// Protocol that should be adopted if you want soom an view
public protocol ZoomerableView: AnyObject {
    var size: CGSize { get }
}

/// View that can zoom content
public class ZoomerView: UIScrollView, UIScrollViewDelegate {
    public typealias View = UIView & ZoomerableView

    public enum Mode {
        case fit
        case fill
    }

    public var zoomMode: Mode = .fill {
        didSet {
            updateContentView()
            scrollToCenter()
        }
    }

    public var contentView: View? {
        didSet {
            oldValue?.removeFromSuperview()

            guard let contentView = contentView
            else {
                return
            }

            addSubview(contentView)

            updateContentView()
            scrollToCenter()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)

        contentInsetAdjustmentBehavior = .never
        backgroundColor = UIColor.clear
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let contentView = contentView
        else {
            return
        }

        if contentView.frame.width <= bounds.width {
            contentView.center.x = bounds.width * 0.5
        }

        if contentView.frame.height <= bounds.height {
            contentView.center.y = bounds.height * 0.5
        }
    }

    // MARK: - API

    public func scrollToCenter() {
        let centerOffset = CGPoint(
            x: contentSize.width > bounds.width ? (contentSize.width / 2) - (bounds.width / 2) : 0,
            y: contentSize.height > bounds.height ? (contentSize.height / 2) - (bounds.height / 2) : 0
        )

        contentOffset = centerOffset
    }

    public func updateContentView() {
        func fitSize(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
            let widthRatio = (boundingSize.width / aspectRatio.width)
            let heightRatio = (boundingSize.height / aspectRatio.height)

            var boundingSize = boundingSize

            if widthRatio < heightRatio {
                boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height
            }
            else if heightRatio < widthRatio {
                boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(boundingSize.width), height: ceil(boundingSize.height))
        }

        func fillSize(aspectRatio: CGSize, minimumSize: CGSize) -> CGSize {
            let widthRatio = (minimumSize.width / aspectRatio.width)
            let heightRatio = (minimumSize.height / aspectRatio.height)

            var minimumSize = minimumSize

            if widthRatio > heightRatio {
                minimumSize.height = minimumSize.width / aspectRatio.width * aspectRatio.height
            }
            else if heightRatio > widthRatio {
                minimumSize.width = minimumSize.height / aspectRatio.height * aspectRatio.width
            }
            return CGSize(width: ceil(minimumSize.width), height: ceil(minimumSize.height))
        }

        guard let contentView = contentView
        else {
            return
        }

        var size: CGSize

        switch zoomMode {
        case .fit:
            size = fitSize(aspectRatio: contentView.size, boundingSize: bounds.size)
        case .fill:
            size = fillSize(aspectRatio: contentView.size, minimumSize: bounds.size)
        }

        size.height = round(size.height)
        size.width = round(size.width)

        maximumZoomScale = 1
        zoomScale = 1

        zoomScale = 1
        maximumZoomScale = contentView.size.width / size.width

        contentView.bounds.size = size
        contentSize = size

        contentView.center = ZoomerView.contentCenter(
            forBoundingSize: bounds.size, contentSize: contentSize
        )
    }

    // MARK: - UIScrollViewDelegate

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentView?.center = ZoomerView.contentCenter(
            forBoundingSize: bounds.size, contentSize: contentSize
        )
    }

    public func scrollViewWillBeginZooming(
        _ scrollView: UIScrollView, with view: UIView?
    ) {}

    public func scrollViewDidEndZooming(
        _ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat
    ) {}

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentView
    }

    @inline(__always)
    private static func contentCenter(
        forBoundingSize boundingSize: CGSize,
        contentSize: CGSize
    ) -> CGPoint {
        /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
        /// of content view changes too. But the default Apple implementation is keeping the last center
        /// value which doesn't make much sense. If the image ratio is not matching the screen
        /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
        /// so that we can get the correct new center value. When these are added, edges of contentView
        /// are aligned in realtime and always aligned with corners of scrollview.
        let horizontalOffest =
            (boundingSize.width > contentSize.width)
                ? ((boundingSize.width - contentSize.width) * 0.5) : 0.0
        let verticalOffset =
            (boundingSize.height > contentSize.height)
                ? ((boundingSize.height - contentSize.height) * 0.5) : 0.0

        return CGPoint(
            x: contentSize.width * 0.5 + horizontalOffest, y: contentSize.height * 0.5 + verticalOffset
        )
    }
}
