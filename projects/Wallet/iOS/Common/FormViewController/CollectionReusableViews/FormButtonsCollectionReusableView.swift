//
//  FormButtonsCollectionReusableView.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI

protocol FormButtonsCollectionReusableViewDelegate: AnyObject {
    
    func formButtonsCollectionReusableView(
        _ view: FormButtonsCollectionReusableView,
        didSelectButtonAtIndex index: Int
    )
}

class FormButtonsCollectionReusableView: UICollectionViewCell {
    
    struct Model {
        
        let title: String
        let action: (_ button: JustonButton) -> ()
        let kind: C42Item.ButtonKind
    }
    
    var models: [Model] = [] {
        didSet {
            var buttons: [JustonButton] = []
            models.forEach({
                switch $0.kind {
                case .primary:
                    buttons.append(PrimaryButton(title: $0.title))
                case .secondary:
                    buttons.append(SecondaryButton(title: $0.title))
                case .teritary:
                    buttons.append(TeritaryButton(title: $0.title))
                }
            })
            self.buttons = buttons
        }
    }
    
    private let stackView = UIStackView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = 8
    })
    
    private var buttons: [JustonButton] = [] {
        willSet {
            buttons.forEach({ $0.removeFromSuperview() })
        }
        didSet {
            var index = 0
            buttons.forEach({
                stackView.addArrangedSubview($0)
                
                if $0.allTargets.contains(self) {
                    $0.removeTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)
                }
                
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.tag = index
                $0.addTarget(self, action: #selector(buttonDidClick(_:)), for: .touchUpInside)
                
                index += 1
            })
        }
    }
    
    weak var delegate: FormButtonsCollectionReusableViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(stackView)
        stackView.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Sizing
    
    public override var intrinsicContentSize: CGSize {
        stackView.intrinsicContentSize
    }
    
    public override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        stackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    // MARK: Actions
    
    @objc
    private func buttonDidClick(_ sender: JustonButton) {
        models[sender.tag].action(sender)
    }
}
