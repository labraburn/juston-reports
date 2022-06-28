//
//  Safari3BannerCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import HuetonUI
import Nuke

class Safari3BannerCollectionViewCell: UICollectionViewCell {
    
    static let absoluteHeight = CGFloat(196)
    
    struct Model: Hashable {
        
        let title: String
        let subtitle: String?
        let imageURL: URL
    }
    
    private var imageDownloadTask: ImageTask?
    
    override var isHighlighted: Bool {
        didSet {
            setHighlightedAnimated(isHighlighted)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
               impactOccurred()
            }
        }
    }
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundSecondary
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    })
    
    private let textsSubstrateView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundPrimary.withAlphaComponent(0.8)
    })
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.numberOfLines = 0
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
    })

    private let subtitleLabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required - 1, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        $0.numberOfLines = 0
        $0.font = .font(for: .footnote)
        $0.textColor = .hui_textPrimary.withAlphaComponent(0.8)
    }
    
    private var titleConstraints: [NSLayoutConstraint] = []
    private var titleSubtitleConstraints: [NSLayoutConstraint] = []
    private var subtitleConstraints: [NSLayoutConstraint] = []
    
    var model: Model? {
        didSet {
            update(
                model: model
            )
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator(style: .soft)
        insertHighlightingScaleAnimation()
        
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(textsSubstrateView)
        
        textsSubstrateView.addSubview(titleLabel)
        textsSubstrateView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate({
            imageView.pin(edges: contentView)
            
            textsSubstrateView.pin(horizontally: contentView)
            bottomAnchor.pin(to: textsSubstrateView.bottomAnchor, constant: 0)
        })

        titleConstraints = Array({
            titleLabel.heightAnchor.pin(lessThan: 128)
            titleLabel.pin(
                edges: textsSubstrateView,
                insets: UIEdgeInsets(
                    top: 12,
                    left: 10,
                    bottom: 10,
                    right: 10
                )
            )
        })

        titleSubtitleConstraints = Array({
            titleLabel.topAnchor.pin(to: textsSubstrateView.topAnchor, constant: 12)
            titleLabel.heightAnchor.pin(lessThan: 64)
            titleLabel.pin(horizontally: textsSubstrateView, left: 10, right: 12)

            subtitleLabel.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 6)
            subtitleLabel.heightAnchor.pin(lessThan: 64)
            subtitleLabel.pin(horizontally: textsSubstrateView, left: 10, right: 12)
            
            textsSubstrateView.bottomAnchor.pin(to: subtitleLabel.bottomAnchor, constant: 12)
        })

        subtitleConstraints = Array({
            subtitleLabel.heightAnchor.pin(lessThan: 128)
            subtitleLabel.pin(
                edges: textsSubstrateView,
                insets: UIEdgeInsets(
                    top: 12,
                    left: 10,
                    bottom: 10,
                    right: 10
                )
            )
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(
        model: Model?
    ) {
        guard let model = model
        else {
            return
        }
        
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle

        let isTitleIsEmpty = (titleLabel.text ?? "").isEmpty
        let isTextIsEmpty = (subtitleLabel.text ?? "").isEmpty

        NSLayoutConstraint.deactivate(titleConstraints)
        NSLayoutConstraint.deactivate(titleSubtitleConstraints)
        NSLayoutConstraint.deactivate(subtitleConstraints)

        if isTitleIsEmpty && !isTextIsEmpty {
            NSLayoutConstraint.activate(subtitleConstraints)
        } else if !isTitleIsEmpty && isTextIsEmpty {
            NSLayoutConstraint.activate(titleConstraints)
        } else {
            NSLayoutConstraint.activate(titleSubtitleConstraints)
        }

        loadImageIfAvailable(
            with: model.imageURL
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetImageView()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        startStopAnimatingImageViewIfNeeded()
    }

    private func loadImageIfAvailable(
        with url: URL?
    ) {
        guard let url = url
        else {
            resetImageView()
            return
        }

        var options = ImageLoadingOptions(placeholder: nil)
        options.transition = .fadeIn(duration: 0.12)
        options.pipeline = ImagePipeline.shared

        let request = ImageRequest(url: url, processors: [])
        imageDownloadTask = loadImage(
            with: request,
            options: options,
            into: imageView,
            completion: { [weak self] result in
                switch result {
                case .success:
                    self?.startStopAnimatingImageViewIfNeeded()
                case .failure:
                    break
                }
            }
        )
    }

    private func resetImageView() {
        imageView.stopAnimating()
        imageDownloadTask?.cancel()
        imageView.image = nil
    }

    private func startStopAnimatingImageViewIfNeeded() {
        if window == nil {
            imageView.stopAnimating()
        } else {
            imageView.startAnimating()
        }
    }
}
