//
//  C42BookmarkCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 20.04.2022.
//

import UIKit
import HuetonUI

class C42BookmarkCollectionViewCell: UICollectionViewCell {
    
    struct Model {
        
        var text: String
        var url: URL
        var image: UIImage?
    }
    
    var model: Model? {
        didSet {
            textLabel.text = model?.text
            
            if let image = model?.image {
                imageView.useImage(image)
            } else {
                imageView.loadImageWithURL(
                    model?.url.genericFaviconURL,
                    parameters: .init(
                        cornerRadius: 12,
                        placeholder: nil
                    )
                )
            }
        }
    }
    
    private let imageView = RemoteImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .font(for: .body)
        $0.textColor = .hui_textPrimary
        $0.textAlignment = .left
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator(style: .light)
        insertHighlightingScaleAnimation()
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        
        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: contentView.topAnchor, constant: 12)
            imageView.leftAnchor.pin(to: contentView.leftAnchor, constant: 12)
            imageView.heightAnchor.pin(to: 24)
            imageView.widthAnchor.pin(to: 24)
            bottomAnchor.pin(to: imageView.bottomAnchor, constant: 12)
            
            textLabel.leftAnchor.pin(to: imageView.rightAnchor, constant: 12)
            textLabel.pin(vertically: contentView, top: 12, bottom: 12)
            
            contentView.rightAnchor.pin(to: textLabel.rightAnchor, constant: 12)
        })
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            setHighlightedAnimated(isHighlighted)
            if isHighlighted {
               impactOccurred()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve = .continuous
    }
}
