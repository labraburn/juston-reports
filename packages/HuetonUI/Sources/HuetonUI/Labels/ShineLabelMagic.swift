//
//  ShineLabel.swift
//  Application
//
//  Created by Anton Spivak on 16.05.2021.
//

import UIKit

open class ShineLabelMagic: MagicLabel {
    
    open override class var labelClass: UILabel.Type { ShineLabel.self }
    private var shineLabel: ShineLabel { backingLabel as! ShineLabel }
    
    public override var text: String? {
        set {
            print("Use 'update()' method instead")
        }
        get { super.text }
    }
    
    public override var attributedText: NSAttributedString? {
        set {
            print("Use 'update()' method instead")
        }
        get { super.attributedText }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        shineLabel.delegate = self
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        shineLabel.delegate = self
    }
    
    open func update(attributedString: NSAttributedString?, duration: TimeInterval, completion: (() -> ())?) {
        shineLabel.update(
            attributedString: attributedString,
            duration: duration,
            completion: completion
        )
    }
}

extension ShineLabelMagic: ShineLabelDelegate {
    
    func shineLabel(_ label: ShineLabel, didUpdateAttributedText attributedText: NSAttributedString?) {
        shineLabel.invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
    }
}
