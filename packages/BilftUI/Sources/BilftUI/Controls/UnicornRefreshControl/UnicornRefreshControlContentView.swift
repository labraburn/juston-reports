//
//  Created by Anton Spivak
//

import Lottie
import SystemUI
import UIKit

public final class UnicornRefreshControlContentView: SUIRefreshControlContentView {
    override public var tintColor: UIColor! {
        didSet {
            progressLayer.strokeColor = tintColor.cgColor
        }
    }

    private static let animationLayersSize = CGSize(width: 37, height: 24)
    private static let subviewsMaximumOffset = CGFloat(22)

    private let progressLayer = CAShapeLayer()
    private let animationView = LottieAnimationView(name: "AAA")

    public let textLabel = UILabel()

    private var previousLayoutOffset: CGFloat = .zero

    override public init(frame: CGRect) {
        super.init(frame: frame)

        guard let url = Bundle.module.url(forResource: "unicorn", withExtension: "svgp"),
              let content = try? String(contentsOf: url),
              let svg = try? SVG(string: content),
              let path = try? UIBezierPath(elements: svg.elements)
        else {
            fatalError("Can't initialize UIBezierPath for RefreshControlContentView.")
        }

        clipsToBounds = false

        progressLayer.bounds = CGRect(origin: .zero, size: Self.animationLayersSize)
        progressLayer.path = path.cgPath
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 1 / UIScreen.main.scale
        layer.addSublayer(progressLayer)

        animationView.bounds = CGRect(origin: .zero, size: Self.animationLayersSize)
        addSubview(animationView)

        textLabel.textAlignment = .center
        addSubview(textLabel)

        reset()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutSubviewsWithOffset(offset: previousLayoutOffset)
    }

    override public func update(with state: SUIRefreshControlState, withProgressIfAvailable progress: CGFloat) {
        switch state {
        case .hidden:
            reset()
        case .userInteraction:
            updateUserInitiatedProgress(progress)
        case .refreshing:
            runRefreshingAnimationIfNeeded()
        case .hidingAnimation:
            hideWithAnimation()
        @unknown default:
            break
        }

        let offset = Self.subviewsMaximumOffset * progress
        layoutSubviewsWithOffset(offset: offset)
        previousLayoutOffset = offset
    }

    private func updateUserInitiatedProgress(_ progress: CGFloat) {
        guard let refreshControl = superview as? UIRefreshControl,
              !refreshControl.isRefreshing
        else {
            return
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        progressLayer.opacity = 1
        animationView.layer.opacity = 0
        animationView.setProgressWithFrame(0)
        textLabel.layer.opacity = 1
        CATransaction.commit()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = progress
        CATransaction.commit()
    }

    private func runRefreshingAnimationIfNeeded() {
        guard !animationView.isAnimationPlaying
        else {
            return
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)
        progressLayer.opacity = 0
        animationView.layer.opacity = 1
        animationView.setProgressWithFrame(0)
        textLabel.layer.opacity = 1
        CATransaction.commit()

        animationView.loopAnimation = true
        animationView.startAnimating()
    }

    private func hideWithAnimation() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        progressLayer.opacity = 0
        animationView.layer.opacity = 0
        textLabel.layer.opacity = 0
        CATransaction.commit()
    }

    private func layoutSubviewsWithOffset(offset: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        textLabel.sizeToFit()

        progressLayer.position = CGPoint(
            x: bounds.midX,
            y: Self.animationLayersSize.height / 2 + offset
        )

        animationView.center = CGPoint(
            x: bounds.midX,
            y: Self.animationLayersSize.height / 2 + offset
        )

        let superviewFrame = superview?.frame ?? .zero
        textLabel.frame = CGRect(
            x: -(superviewFrame.width - bounds.width) / 2,
            y: animationView.frame.maxY + 4,
            width: superviewFrame.width,
            height: 18
        )

        CATransaction.commit()
    }

    private func reset() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        progressLayer.strokeEnd = 0
        progressLayer.strokeStart = 0
        progressLayer.opacity = 0
        progressLayer.removeAllAnimations()

        animationView.layer.opacity = 1
        animationView.setProgressWithFrame(0)
        animationView.stopAnimating()

        textLabel.layer.opacity = 0

        CATransaction.commit()
    }
}
