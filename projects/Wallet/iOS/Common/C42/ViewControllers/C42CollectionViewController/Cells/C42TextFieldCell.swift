//
//  C42TextFieldCell.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonUI

class C42TextFieldCell: UICollectionViewCell {
    
    var title: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }
    
    var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    var change: ((_ textFiled: UITextField) -> ())?
    var done: ((_ textFiled: UITextField) -> ())?
    
    private let textLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .caption1)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.textAlignment = .left
        $0.numberOfLines = 0
    })
    
    private lazy var textField = UITextField().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .hui_textPrimary
        $0.font = .font(for: .body)
        $0.heightAnchor.pin(to: 52).isActive = true
        $0.delegate = self
        $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    })
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .hui_backgroundPrimary
        contentView.addSubview(textLabel)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate({
            textLabel.topAnchor.pin(to: contentView.topAnchor)
            textLabel.pin(horizontally: contentView)
            
            textField.topAnchor.pin(to: textLabel.bottomAnchor, constant: 4)
            textField.pin(horizontally: contentView)
            
            contentView.bottomAnchor.pin(to: textField.bottomAnchor)
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        change?(textField)
    }
}

extension C42TextFieldCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard !((textField.text ?? "").isEmpty)
        else {
            return false
        }
        
        textField.resignFirstResponder()
        done?(textField)
        return true
    }
}
