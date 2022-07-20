//
//  TopupAgreementsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 19.07.2022.
//

import UIKit
import JustonUI

protocol TopupAgreementsViewControllerDelegate: AnyObject {
    
    func topupAgreementsViewController(
        _ viewController: TopupAgreementsViewController,
        didAcceptAgreementsWithError error: Error?
    )
}

class TopupAgreementsViewController: UIViewController {
    
    weak var delegate: TopupAgreementsViewControllerDelegate?
    
    private let titleLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .title3)
        $0.textColor = .jus_textPrimary
        $0.text = "VeneraExhangeTitle".asLocalizedKey
        $0.numberOfLines = 1
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
    })
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = .jus_veneraExchange128
        $0.contentMode = .center
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    })
    
    private let textView = TextView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .body)
        $0.textColor = .jus_textPrimary
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.isSelectable = true
        $0.delaysContentTouches = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.backgroundColor = .jus_backgroundPrimary
        $0.isUserInteractionEnabled = true
        $0.linkTextAttributes = [
            .foregroundColor : UIColor.jus_letter_violet,
            .font : UIFont.font(for: .headline),
            .underlineColor : UIColor.jus_letter_purple,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
        ]
        
        let terms = "VeneraExhangeTermsOfUse".asLocalizedKey
        let privacy = "VeneraExhangePrivacy".asLocalizedKey
        
        let pattern = String(format: "VeneraExhangeDescription".asLocalizedKey, terms, privacy)
        let string = NSMutableAttributedString(
            string: pattern,
            attributes: [
                .foregroundColor : UIColor.jus_textPrimary,
                .font : UIFont.font(for: .body),
                .paragraphStyle : NSMutableParagraphStyle().with({
                    $0.alignment = .center
                })
            ]
        )
        
        string.addAttributes(
            [ .link : URL.veneraPrivacyPolicy.absoluteString],
            range: NSRange(
                pattern.range(of: privacy)!,
                in: pattern
            )
        )
        
        string.addAttributes(
            [ .link : URL.veneraTermsOfUse.absoluteString],
            range: NSRange(
                pattern.range(of: terms)!,
                in: pattern
            )
        )
        
        $0.attributedText = string
    })
    
    private lazy var doneButton = PrimaryButton(title: "VeneraExhangeActionButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CommonCancel".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .jus_backgroundPrimary
        
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate({
            titleLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 12)
            titleLabel.pin(horizontally: view, left: 16, right: 16)
            
            imageView.topAnchor.pin(to: titleLabel.bottomAnchor, constant: 8)
            imageView.centerXAnchor.pin(to: view.centerXAnchor)
            imageView.widthAnchor.pin(to: imageView.heightAnchor)
            
            textView.topAnchor.pin(to: imageView.bottomAnchor, constant: 8)
            textView.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(to: textView.bottomAnchor, constant: 24)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(lessThan: doneButton.bottomAnchor, constant: 8)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        delegate?.topupAgreementsViewController(
            self,
            didAcceptAgreementsWithError: nil
        )
    }
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        delegate?.topupAgreementsViewController(
            self,
            didAcceptAgreementsWithError: CancellationError()
        )
    }
}

extension TopupAgreementsViewController: PreferredContentSizeHeightViewController {
    
    func preferredContentSizeHeight(
        with containerFrame: CGRect
    ) -> CGFloat {
        let size = view.systemLayoutSizeFitting(
            CGSize(width: containerFrame.width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return size.height
    }
}

private class TextView: UITextView {
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.height = attributedTextHeight(
            for: intrinsicContentSize.width
        )
        return intrinsicContentSize
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        var systemLayoutSizeFitting = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        systemLayoutSizeFitting.height = attributedTextHeight(
            for: systemLayoutSizeFitting.width
        )
        return systemLayoutSizeFitting
    }
    
    private func attributedTextHeight(
        for width: CGFloat
    ) -> CGFloat {
        attributedText.boundingRect(
            with: CGSize(width: width - textContainerInset.left - textContainerInset.right, height: UIView.layoutFittingExpandedSize.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height + textContainerInset.bottom + textContainerInset.top + 2
    }
}
