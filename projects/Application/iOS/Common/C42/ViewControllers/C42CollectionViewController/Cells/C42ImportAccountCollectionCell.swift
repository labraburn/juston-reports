//
//  C42ImportAccountCollectionCell.swift
//  iOS
//
//  Created by Anton Spivak on 31.05.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class C42ImportAccountCollectionCell: UICollectionViewCell {
    
    enum Result {
        
        case words(value: [String])
        case address(value: Address)
    }
    
    private let errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    private lazy var inputTextView = BorderedTextView(caption: "OnboardingImportTitleCaption".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .done
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 64
        $0.textView.maximumContentSizeHeight = 96
        $0.heightAnchor.pin(lessThan: 128).isActive = true
    })
    
    var done: ((_ result: Result) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insertFeedbackGenerator(style: .light)
        insertHighlightingScaleAnimation()
        
        contentView.addSubview(inputTextView)
        inputTextView.pinned(edges: contentView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted, !inputTextView.textView.isFirstResponder {
                inputTextView.textView.becomeFirstResponder()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
        layer.cornerCurve = .continuous
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        inputTextView.containerViewAnchor = superview
    }
    
    fileprivate func result(from textView: UITextView) -> Result? {
        guard textView.hasText
        else {
            return nil
        }
        
        let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let words = text.components(separatedBy: " ")
        if words.count == 24 {
            return .words(value: words)
        } else if let address = Address(string: text) {
            return .address(value: address)
        } else {
            return nil
        }
    }
}

extension C42ImportAccountCollectionCell: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        inputTextView.setFocused(true)
        textView.textColor = .white
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard result(from: textView) != nil
        else {
            return
        }
        
        inputTextView.setFocused(false)
        textView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.setFocused(false)
        guard textView.hasText
        else {
            return
        }
        
        if let result = result(from: textView) {
            done?(result)
        } else {
            textView.superview?.shake()
            textView.textColor = .hui_letter_red
            errorFeedbackGenerator.impactOccurred()
        }
    }
}
