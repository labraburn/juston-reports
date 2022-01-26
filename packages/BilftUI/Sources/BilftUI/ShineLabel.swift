//
//  ShineLabel.swift
//  Application
//
//  Created by Anton Spivak on 16.05.2021.
//

import UIKit

protocol ShineLabelDelegate: AnyObject {
    
    func shineLabel(_ label: ShineLabel, didUpdateAttributedText attributedText: NSAttributedString?)
}

public class ShineLabel: UILabel {
    
    var shining : Bool { displayLink != nil }
    var visible : Bool { !fadeOut }
    
    weak var delegate: ShineLabelDelegate? = nil
    
    private var animationString: NSMutableAttributedString?
    
    private var characterAnimationDurtions: [CFTimeInterval] = []
    private var characterAnimationDelays: [CFTimeInterval] = []
    
    private var displayLink: CADisplayLink? = nil
    
    private var beginTime: CFTimeInterval = 0
    private var endTime: CFTimeInterval = 0
    
    private var fadeOut: Bool = true
    private var completion: (() -> ())?
    private var after: (() -> ())?
    
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
    
    open func update(attributedString: NSAttributedString?, duration: TimeInterval, completion: (() -> ())?) {
        if shining {
            return
        }
        
        self.completion = completion
        
        let nextAttributedString = initialAttributedString(attributedString: attributedString)
        let after = {
            guard let attributedString = nextAttributedString
            else {
                return
            }
            
            self.animationString = attributedString
            self.superupdate(attributedString.copy() as? NSAttributedString)
            
            for index in 0...attributedString.length - 1 {
                let delay = Double(arc4random_uniform(UInt32(duration / 4 * 100))) / 100.0
                self.characterAnimationDelays.insert(delay, at: index)
                
                let remain = duration / 2 - delay
                let duration = Double(arc4random_uniform(UInt32(remain * 100))) / 100.0
                self.characterAnimationDurtions.insert(duration, at: index)
            }
            
            self.fadeOut = false
            self.startAnimation(duration: duration / 2)
        }
        
        if super.attributedText != nil && !fadeOut {
            fadeOut = true
            startAnimation(duration: duration / 2)
            self.after = after
        } else {
            after()
        }
    }
    
    private func startAnimation(duration: CFTimeInterval) {
        beginTime = CACurrentMediaTime()
        endTime = beginTime + duration
        
        displayLink = CADisplayLink(target: self, selector:#selector(updateAttributedString))
        displayLink?.isPaused = false
        displayLink?.add(to: .current, forMode: .common)
    }

    @objc private func updateAttributedString() {
        let finish = {
            self.displayLink?.invalidate()
            self.displayLink = nil
            
            if self.after != nil {
                self.after?()
                self.after = nil
            } else {
                self.completion?()
                self.completion = nil
            }
        }
        
        guard let attributedString = animationString
        else {
            finish()
            return
        }
        
        let now = CACurrentMediaTime()
        for index in 0...attributedString.length - 1 {
            attributedString.enumerateAttribute(.foregroundColor, in: NSMakeRange(index, 1), options: .init(rawValue: 0), using: { (value, range, stop) in
                guard let color = value as? UIColor
                else {
                    return
                }
                
                let currentAlpha = color.cgColor.alpha
                let checkAlpha = (fadeOut && (currentAlpha > 0)) || (!fadeOut && (currentAlpha < 1))
                let shouldUpdateAlpha : Bool = checkAlpha || (now - beginTime) >= characterAnimationDelays[index]
                if !shouldUpdateAlpha {
                    return
                }
                
                var percentage = (now - beginTime - characterAnimationDelays[index]) / (characterAnimationDurtions[index])
                if (fadeOut) {
                    percentage = 1 - percentage
                }
                
                attributedString.addAttributes([
                    .foregroundColor : color.withAlphaComponent(CGFloat(percentage))
                ], range: range)
            })
        }
        
        super.attributedText = attributedString
        if now > endTime {
            finish()
        }
    }
    
    
    private func initialAttributedString(attributedString: NSAttributedString?) -> NSMutableAttributedString? {
        guard let attributedString = attributedString,
              attributedString.length > 0,
              let mutableAttributedString = attributedString.mutableCopy() as? NSMutableAttributedString
        else {
            return nil
        }
        
        for index in 0..<mutableAttributedString.length - 1 {
            mutableAttributedString.enumerateAttribute(.foregroundColor, in: NSMakeRange(index, 1), options: .init(rawValue: 0), using: { (value, range, stop) in
                guard let color = value as? UIColor
                else {
                    return
                }
                
                let newColor = color.withAlphaComponent(0)
                mutableAttributedString.addAttributes([
                    .foregroundColor : newColor
                ], range: range)
            })
        }
        
        return mutableAttributedString
    }
    
    private func superupdate(_ attributesText: NSAttributedString?) {
        super.attributedText = attributesText
        delegate?.shineLabel(self, didUpdateAttributedText: attributesText)
    }
}
