//
//  File.swift
//  
//
//  Created by Anton Spivak on 29.01.2022.
//

import UIKit

public final class AnimatedLogoView: UIView {
    
    public struct Presentation: Equatable {
        
        public static let off = Presentation(b: .off, l: .off, i: .off, f: .off, t: .off)
        public static let on = Presentation(b: .on, l: .on, i: .on, f: .on, t: .on)
        
        let b: Switch
        let l: Switch
        let i: Switch
        let f: Switch
        let t: Switch
        
        public init(b: Switch, l: Switch, i: Switch, f: Switch, t: Switch) {
            self.b = b
            self.l = l
            self.i = i
            self.f = f
            self.t = t
        }
    }
    
    public enum Switch {
        case on
        case off
        
        internal var name: String {
            switch self {
            case .on: return "On"
            case .off: return "Off"
            }
        }
    }
    
    public private(set) var presentation: Presentation = .off
    
    private let b: UIImageView = AnimatedLogoView.imageView()
    private let l: UIImageView = AnimatedLogoView.imageView()
    private let i: UIImageView = AnimatedLogoView.imageView()
    private let f: UIImageView = AnimatedLogoView.imageView()
    private let t: UIImageView = AnimatedLogoView.imageView()
    
    public let label = UILabel()
    private let animation = UIView()
    
    public var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        
        animation.backgroundColor = .clear
        addSubview(animation)
        
        label.textColor = .bui_textPrimary
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        label.isHidden = true
        addSubview(label)
        
        [b, l, i, f, t].forEach { addSubview($0) }
        updateImageViews()
    }
    
    // Animations
    
    public func prepareLoadingAnimation(with progress: CGFloat) {
        stopAllAnimations()
        
        let _progress = max(min(progress, 1), 0)
        var presentation: Presentation
        
        if _progress >= 1 {
            presentation = Presentation(b: .off, l: .off, i: .off, f: .off, t: .off)
        } else if _progress >= 0.8 {
            presentation = Presentation(b: .on, l: .off, i: .off, f: .off, t: .off)
        } else if _progress >= 0.6 {
            presentation = Presentation(b: .on, l: .on, i: .off, f: .off, t: .off)
        } else if _progress >= 0.4 {
            presentation = Presentation(b: .on, l: .on, i: .on, f: .off, t: .off)
        } else if _progress >= 0.2 {
            presentation = Presentation(b: .on, l: .on, i: .on, f: .on, t: .off)
        } else {
            presentation = Presentation(b: .on, l: .on, i: .on, f: .on, t: .on)
        }
        
        if label.isHidden {
            label.alpha = 0
            label.isHidden = false
        }
        
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.label.alpha = min(_progress * 0.7, 0.7)
            }
        )
        animate(with: [presentation], duration: 2.1, completion: { _ in })
    }
    
    public func startLoadingAnimation(isInitial: Bool = true) {
        stopAllAnimations()
        
        var presentations: [Presentation] = []
        
        if isInitial {
            if presentation == .off {
                presentations.append(contentsOf: [
                    Presentation(b: .off, l: .off, i: .off, f: .off, t: .off),
                    Presentation(b: .on, l: .off, i: .off, f: .off, t: .off),
                    Presentation(b: .on, l: .on, i: .off, f: .off, t: .off),
                    Presentation(b: .on, l: .on, i: .on, f: .off, t: .off),
                    Presentation(b: .on, l: .on, i: .on, f: .on, t: .off),
                    Presentation(b: .on, l: .on, i: .on, f: .on, t: .on),
                ])
            } else if presentation == .on {
                presentations.append(contentsOf: [
                    Presentation(b: .on, l: .on, i: .on, f: .on, t: .on),
                ])
            }
        } else {
            presentations.append(contentsOf: [
                Presentation(b: .off, l: .off, i: .off, f: .off, t: .off),
                Presentation(b: .on, l: .off, i: .off, f: .off, t: .off),
                Presentation(b: .on, l: .on, i: .off, f: .off, t: .off),
                Presentation(b: .on, l: .on, i: .on, f: .off, t: .off),
                Presentation(b: .on, l: .on, i: .on, f: .on, t: .off),
                Presentation(b: .on, l: .on, i: .on, f: .on, t: .on),
            ])
        }
        
        presentations.append(contentsOf: [
            Presentation(b: .off, l: .on, i: .on, f: .on, t: .on),
            Presentation(b: .off, l: .off, i: .on, f: .on, t: .on),
            Presentation(b: .off, l: .off, i: .off, f: .on, t: .on),
            Presentation(b: .off, l: .off, i: .off, f: .off, t: .on),
            Presentation(b: .off, l: .off, i: .off, f: .off, t: .off),
            Presentation(b: .off, l: .off, i: .off, f: .off, t: .on),
            Presentation(b: .off, l: .off, i: .off, f: .on, t: .on),
            Presentation(b: .off, l: .off, i: .on, f: .on, t: .on),
            Presentation(b: .off, l: .on, i: .on, f: .on, t: .on),
            Presentation(b: .on, l: .on, i: .on, f: .on, t: .on),
            Presentation(b: .on, l: .on, i: .on, f: .on, t: .off),
            Presentation(b: .on, l: .on, i: .on, f: .off, t: .off),
            Presentation(b: .on, l: .on, i: .off, f: .off, t: .off),
            Presentation(b: .on, l: .off, i: .off, f: .off, t: .off),
        ])
        
        animate(with: presentations, duration: 2.1, completion: { [weak self] finished in
            guard finished
            else {
                return
            }
            
            self?.startLoadingAnimation(isInitial: false)
        })
    }
    
    public func stopLoadingAnimation() {
        stopAllAnimations()
        
        UIView.animate(
            withDuration: 0.24,
            animations: {
                self.label.alpha = 0
            },
            completion: { _ in
                self.label.isHidden = true
            }
        )
        
        DispatchQueue.main.async(execute: {
            self.animate(with: [.on], duration: 0.1, completion: { _ in })
        })
    }
    
    // Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let originalSpacing = CGFloat(8)
        let originalLetterHeight = CGFloat(74)
        
        let heightRatio = originalLetterHeight / CGFloat(96)
        let height = bounds.height * heightRatio
        
        let widthRatio = height / originalLetterHeight
        let spacing = originalSpacing * widthRatio
        
        guard height != 0
        else {
            return
        }
        
        b.bounds.size = CGSize(width: 50 * widthRatio, height: height)
        l.bounds.size = CGSize(width: 15 * widthRatio, height: height)
        i.bounds.size = CGSize(width: 33 * widthRatio, height: height)
        f.bounds.size = CGSize(width: 41 * widthRatio, height: height)
        t.bounds.size = CGSize(width: 43 * widthRatio, height: height)
        
        let views = [b, l, i, f, t]
        let width = views.reduce(into: CGFloat(0), { $0 += $1.bounds.width }) + spacing * 4
        
        var offset = (max(bounds.width, width) - width) / 2
        for i in 0..<views.count {
            let view = views[i]
            view.center = CGPoint(
                x: offset + view.bounds.width / 2,
                y: bounds.height / 2
            )
            offset = view.frame.maxX + spacing
        }
        
        label.frame = CGRect(
            x: b.frame.minX - 1,
            y: b.frame.maxX + 16,
            width: t.frame.maxX - b.frame.minX + 2,
            height: 17
        )
    }
    
    // MARK: Presentation
    
    public func update(presentation: Presentation) {
        self.presentation = presentation
        self.updateImageViews()
    }
    
    public func animate(
        with presentations: [Presentation],
        duration: TimeInterval,
        completion: @escaping (Bool) -> Void
    ) {
        stopAllAnimations()
        
        guard presentations.count > 0
        else {
            completion(true)
            return
        }
        
        let step = duration / TimeInterval(presentations.count)
        let transition = { [weak self] (_ to: Presentation) in
            guard let self = self
            else {
                return
            }
            
            let views = [self.b, self.l, self.i, self.f, self.t]
            let key = "transition"
            
            let transition = CATransition()
            transition.duration = step
            transition.type = .fade
            transition.timingFunction = .init(name: .easeInEaseOut)
            
            views.forEach {
                $0.layer.removeAnimation(forKey: key)
                $0.layer.add(transition, forKey: key)
            }
            
            self.presentation = to
            self.updateImageViews()
        }
        
        guard presentations.count > 1
        else {
            transition(presentations[0])
            return
        }
        
        transition(presentations[0])
        
        for i in 1..<presentations.count {
            let presentation = presentations[i]
            UIView.animate(
                withDuration: step,
                delay: CGFloat(i) * step,
                options: [.curveLinear],
                animations: {
                    // UIKit doesn't run animations if no chages
                    self.animation.center = CGPoint(
                        x: self.animation.center.x + 1,
                        y: self.animation.center.y + 1
                    )
                },
                completion: { finished in
                    guard finished
                    else {
                        return
                    }
                    
                    transition(presentation)
                }
            )
        }
        
        UIView.animate(
            withDuration: duration + step / 2,
            delay: 0,
            options: [.curveLinear],
            animations: {
                // UIKit doesn't run animations if no chages
                self.animation.center = CGPoint(
                    x: self.animation.center.x + 1,
                    y: self.animation.center.y + 1
                )
            },
            completion: { finished in
                self.animation.center = .zero
                completion(finished)
            }
        )
    }
    
    // MARK: Utilites
    
    private func stopAllAnimations() {
//        layer.removeAllAnimations()
        animation.layer.removeAllAnimations()
        [b, l, i, f, t].forEach { $0.layer.removeAllAnimations() }
    }
    
    private func updateImageViews() {
        b.image = UIImage(named: "Letters/B/\(presentation.b.name)", in: .module, with: nil)
        l.image = UIImage(named: "Letters/I/\(presentation.l.name)", in: .module, with: nil)
        i.image = UIImage(named: "Letters/L/\(presentation.i.name)", in: .module, with: nil)
        f.image = UIImage(named: "Letters/F/\(presentation.f.name)", in: .module, with: nil)
        t.image = UIImage(named: "Letters/T/\(presentation.t.name)", in: .module, with: nil)
    }
    
    static func imageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
}
