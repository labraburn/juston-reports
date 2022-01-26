//
//  DashboardView.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class DashboardView: UIView {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFit
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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.image = UIImage(named: "AppLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
