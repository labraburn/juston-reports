//
//  LaunchView.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class LaunchView: UIView {

    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.image = UIImage(named: "AppLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    func animate(completion: @escaping (Bool) -> ()) {
        let toggle = {
            self.imageView.alpha = self.imageView.alpha > 0 ? 0 : 1
        }
        
        UIView.animateKeyframes(withDuration: 0.21, delay: 0.0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.03, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.03, relativeDuration: 0.06, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.09, relativeDuration: 0.01, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.10, relativeDuration: 0.01, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.11, relativeDuration: 0.01, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.12, relativeDuration: 0.01, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.13, relativeDuration: 0.1, animations: {
                toggle()
            })
            UIView.addKeyframe(withRelativeStartTime: 0.14, relativeDuration: 0.07, animations: {
                toggle()
            })
        }, completion: completion)
    }
}
