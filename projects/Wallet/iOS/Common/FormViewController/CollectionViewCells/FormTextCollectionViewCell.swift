//
//  FormTextCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI

class FormTextCollectionViewCell: UICollectionViewCell {
    
    struct Model: Equatable {
        
        let text: String
        let alignment: NSTextAlignment
        let style: UIFont.TextStyle
    }
    
    var model: Model? = nil {
        didSet {
            guard oldValue != model
            else {
                return
            }
            
            textLabel.text = model?.text
            textLabel.textAlignment = model?.alignment ?? .left
            textLabel.font = .font(for: model?.style ?? .body)
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
    
    override var canBecomeFirstResponder: Bool {
        false
    }
    
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
