//
//  C42LabelCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import JustonUI

class C42LabelCell: UICollectionViewCell {
    
    struct Model: Equatable {
        
        let text: String?
        let kind: C42Item.LabelKind
    }
    
    var model: Model? = nil {
        didSet {
            guard oldValue != model
            else {
                return
            }
            
            textLabel.text = model?.text
            switch model?.kind {
            case .body, .none:
                textLabel.font = .font(for: .body)
            case .headline:
                textLabel.font = .font(for: .headline)
            }
        }
    }
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .jus_textPrimary
        $0.font = .font(for: .body)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .jus_backgroundPrimary
        contentView.addSubview(textLabel)
        
        textLabel.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
