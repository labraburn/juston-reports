//
//  Created by Anton Spivak.
//

import UIKit
import DeclarativeUI

internal class SignboardImageView: UIView {
    
    private let backgroundImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = false
    })
    
    private let foregroundImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    })
    
    let size: CGSize
    
    init(letter: SignboardLetter) {
        let imageName = "Letters/\(letter.character.lowercased())"
        guard let image = UIImage(named: imageName, in: .module, compatibleWith: nil)
        else {
            fatalError("Could not find image for character: \(letter.character)")
        }
        
        self.size = image.size
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = .clear
        
        addSubview(backgroundImageView)
        addSubview(foregroundImageView)
        
        backgroundImageView.image = blurred(image: image, color: letter.color)
        foregroundImageView.image = image
        
        NSLayoutConstraint.activate {
            backgroundImageView.centerYAnchor.pin(to: centerYAnchor)
            backgroundImageView.centerXAnchor.pin(to: centerXAnchor)
            
            backgroundImageView.widthAnchor.pin(to: foregroundImageView.widthAnchor, multiplier: 1.6)
            backgroundImageView.heightAnchor.pin(to: foregroundImageView.heightAnchor, multiplier: 1.4)
            
            foregroundImageView.pin(edges: self)
        }
        
        match(letter: letter)
        letter.observer = { [weak self] letter in
            self?.match(letter: letter)
        }
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private func match(letter: SignboardLetter) {
        tintColor = letter.tintColor
        switch letter.tumbler {
        case .on:
            backgroundImageView.alpha = 1
        case .off:
            backgroundImageView.alpha = 0
        }
    }
    
    override func tintColorDidChange() {
        switch tintAdjustmentMode {
        case .dimmed:
            backgroundImageView.isHidden = true
        default:
            backgroundImageView.isHidden = false
        }
    }
    
    private func blurred(image: UIImage, color: UIColor) -> UIImage? {
        guard let _image = image.redraw(withTintColor: color)
        else {
            return nil
        }
        
        guard let ciimage = CIImage(image: _image)
        else {
            return nil
        }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciimage, forKey: kCIInputImageKey)
        filter?.setValue(18, forKey: kCIInputRadiusKey)
        
        let context = CIContext()
        guard let outputImage = filter?.outputImage,
              let cgimage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: cgimage, scale: image.scale, orientation: .up)
    }
    
    // MARK: Sizing
    
    override var intrinsicContentSize: CGSize {
        foregroundImageView.intrinsicContentSize
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        foregroundImageView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
}
