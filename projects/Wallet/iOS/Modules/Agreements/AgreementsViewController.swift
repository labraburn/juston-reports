//
//  AgreementsViewController.swift
//  iOS
//
//  Created by Anton Spivak on 16.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class AgreementsViewController: C42ConcreteViewController {
    
    typealias CompletionBlock = (
        _ viewController: C42ViewController
    ) async throws -> Void
    
    private let imageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = .hui_placeholderV3512
    })
    
    private let textView = UITextView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .body)
        $0.textColor = .hui_textPrimary
        $0.text = "OnboardingAgreementsDescription".asLocalizedKey
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isEditable = false
        $0.isScrollEnabled = false
        $0.isSelectable = true
        $0.delaysContentTouches = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.backgroundColor = .hui_backgroundPrimary
        $0.isUserInteractionEnabled = true
        $0.linkTextAttributes = [
            .foregroundColor : UIColor.hui_letter_violet,
            .font : UIFont.font(for: .headline),
            .underlineColor : UIColor.hui_letter_purple,
            .underlineStyle : NSUnderlineStyle.single.rawValue,
        ]
        
        let terms = "OnboardingAgreementsTermsOfUse".asLocalizedKey
        let privacy = "OnboardingAgreementsPrivacy".asLocalizedKey
        
        let pattern = String(format: "OnboardingAgreementsDescription".asLocalizedKey, terms, privacy)
        let string = NSMutableAttributedString(
            string: pattern,
            attributes: [
                .foregroundColor : UIColor.hui_textPrimary,
                .font : UIFont.font(for: .body),
                .paragraphStyle : NSMutableParagraphStyle().with({
                    $0.alignment = .center
                })
            ]
        )
        
        string.addAttributes(
            [ .link : URL.privacyPolicy.absoluteString],
            range: NSRange(
                pattern.range(of: privacy)!,
                in: pattern
            )
        )
        
        string.addAttributes(
            [ .link : URL.termsOfUse.absoluteString],
            range: NSRange(
                pattern.range(of: terms)!,
                in: pattern
            )
        )
        
        $0.attributedText = string
    })
    
    lazy var doneButton = PrimaryButton(title: "OnboardingAgreementsActionButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private var task: Task<(), Never>?
    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
    
    let completionBlock: CompletionBlock
    
    init(
        completionBlock: @escaping CompletionBlock,
        isModalInPresentation: Bool = true,
        isBackActionAvailable: Bool = false,
        isNavigationBarHidden: Bool = false
    ) {
        self.completionBlock = completionBlock
        super.init(
            title: "OnboardingAgreementsTitle".asLocalizedKey,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate({
            imageView.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 0)
            imageView.pin(horizontally: view, left: 16, right: 16)
            imageView.heightAnchor.pin(to: imageView.widthAnchor)
            
            textView.topAnchor.pin(to: imageView.bottomAnchor, constant: 8)
            textView.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(to: textView.bottomAnchor, constant: 24)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(greaterThan: doneButton.bottomAnchor, constant: 8)
        })
        
        doneButton.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        guard task == nil
        else {
            return
        }
        
        view.isUserInteractionEnabled = false
        
        task?.cancel()
        task = Task {
            do {
                try await self.completionBlock(self)
            } catch {
                present(error)
            }
            
            self.view.isUserInteractionEnabled = true
            self.task = nil
        }
    }
}
