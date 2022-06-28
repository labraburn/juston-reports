//
//  Safari3SearchCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import HuetonUI
import Nuke

class Safari3SearchCollectionViewCell: UICollectionViewCell, UICollectionViewPreviewCell {
    
    static let estimatedHeight = CGFloat(64)
    
    struct Model: Hashable {
        
        let title: String
        let url: URL
    }
    
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
    
    var contextMenuPreviewView: UIView? {
        imageView
    }
    
    private var imageDownloadTask: ImageTask?
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundPrimary.withAlphaComponent(0.8)
        $0.contentMode = .center
        
        $0.layer.cornerRadius = 12
        $0.layer.cornerCurve = .continuous
        $0.layer.masksToBounds = true
    })
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.numberOfLines = 1
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .left
    })
    
    private let subtitleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        $0.numberOfLines = 1
        $0.font = .font(for: .footnote)
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .left
    })
    
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
        
        contentView.backgroundColor = .hui_backgroundSecondary
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate({
            imageView.leftAnchor.pin(to: contentView.leftAnchor)
            imageView.pin(vertically: contentView)
            imageView.heightAnchor.pin(to: 64)
            imageView.widthAnchor.pin(to: imageView.heightAnchor)
            
            titleLabel.topAnchor.pin(to: contentView.topAnchor, constant: 10)
            titleLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 10)
            contentView.rightAnchor.pin(to: titleLabel.rightAnchor, constant: 12)
            
            subtitleLabel.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 4)
            subtitleLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 10)
            contentView.rightAnchor.pin(to: subtitleLabel.rightAnchor, constant: 12)
            
            contentView.bottomAnchor.pin(greaterThan: subtitleLabel.bottomAnchor, constant: 6)
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
        subtitleLabel.text = model.url.absoluteString
        
        loadImageIfAvailable(
            with: model.url.genericFaviconURL(with: .xl)
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
