//
//  FormInputCollectionViewCell.swift
//  iOS
//
//  Created by Anton Spivak on 27.07.2022.
//

import Foundation
import JustonUI

@MainActor
protocol FormInput {
    
    var text: String { get }
    
    func performErrorAnimation()
    func makeFirstResponder()
}

protocol FormInputCollectionViewCellDelegate: AnyObject {
    
    func formInputCollectionViewCellDidStartEditing(_ cell: FormInputCollectionViewCell)
    func formInputCollectionViewCellDidRequestNext(_ cell: FormInputCollectionViewCell)
    func formInputCollectionViewCellDidEndEditing(_ cell: FormTextCollectionViewCell)
}

class FormInputCollectionViewCell: UICollectionViewCell {
    
    struct Model {
        
        let text: String?
        let placeholder: String
        let keyboardType: UIKeyboardType
        let returnKeyType: UIReturnKeyType
        let autocorrectionType: UITextAutocorrectionType
        let autocapitalizationType: UITextAutocapitalizationType
        let maximumContentSizeHeight: CGFloat
        let minimumContentSizeHeight: CGFloat
        let isEditable: Bool
        let actions: [BorderedTextView.Action]
    }
    
    var model: Model? = nil {
        didSet {
            borderedTextView.caption = model?.placeholder ?? ""
            borderedTextView.actions = model?.actions ?? []
            
            borderedTextView.textView.text = model?.text ?? ""
            borderedTextView.textView.keyboardType = model?.keyboardType ?? .default
            borderedTextView.textView.returnKeyType = model?.returnKeyType ?? .default
            borderedTextView.textView.autocorrectionType = model?.autocorrectionType ?? .yes
            borderedTextView.textView.autocapitalizationType = model?.autocapitalizationType ?? .sentences
            borderedTextView.textView.maximumContentSizeHeight = model?.maximumContentSizeHeight ?? 21
            borderedTextView.textView.minimumContentSizeHeight = model?.minimumContentSizeHeight ?? 42
            borderedTextView.textView.isEditable = model?.isEditable ?? true
        }
    }
    
    weak var delegate: FormInputCollectionViewCellDelegate?
    
    private(set) lazy var errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private(set) lazy var borderedTextView = BorderedTextView(caption: "".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .next
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 42
        $0.textView.delegate = self
    })
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .jus_backgroundPrimary
        contentView.addSubview(borderedTextView)
        borderedTextView.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        borderedTextView.containerViewAnchor = superview
    }
    
    override func becomeFirstResponder() -> Bool {
        borderedTextView.textView.becomeFirstResponder()
    }
}

extension FormInputCollectionViewCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        borderedTextView.setFocused(true)
        textView.textColor = .white
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if model?.returnKeyType == .next && text == "\n" {
            delegate?.formInputCollectionViewCellDidRequestNext(self)
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        borderedTextView.setFocused(false)
    }
}

extension FormInputCollectionViewCell: FormInput {
    
    var text: String {
        borderedTextView.textView.text ?? ""
    }
    
    func performErrorAnimation() {
        borderedTextView.shake()
        borderedTextView.textView.textColor = .jus_letter_red
        errorFeedbackGenerator.impactOccurred()
    }
    
    func makeFirstResponder() {
        let _ = becomeFirstResponder()
    }
}
