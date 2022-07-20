//
//  Safari3FavouriteCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 26.06.2022.
//

import UIKit
import JustonUI
import Nuke

class Safari3FavouriteCollectionViewCell: UICollectionViewCell, UICollectionViewPreviewCell {
    
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
        imageViewWrapperView
    }
    
    private var imageDownloadTask: ImageTask?
    
    private var imageViewWrapperView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .jus_backgroundSecondary
        
        $0.layer.cornerRadius = 12
        $0.layer.cornerCurve = .continuous
        $0.layer.masksToBounds = true
    })
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .jus_backgroundSecondary
        $0.contentMode = .scaleAspectFill
    })
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
        $0.numberOfLines = 2
        $0.font = .font(for: .footnote)
        $0.textColor = .jus_textPrimary
        $0.textAlignment = .center
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
        
        contentView.addSubview(imageViewWrapperView)
        imageViewWrapperView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate({
            imageViewWrapperView.topAnchor.pin(to: contentView.topAnchor)
            imageViewWrapperView.pin(horizontally: contentView)
            imageViewWrapperView.heightAnchor.pin(to: imageViewWrapperView.widthAnchor)
            
            imageView.pin(edges: imageViewWrapperView, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
            
            titleLabel.topAnchor.pin(to: imageViewWrapperView.bottomAnchor, constant: 6)
            titleLabel.pin(horizontally: contentView, left: 2, right: 2)
            contentView.bottomAnchor.pin(to: titleLabel.bottomAnchor)
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
