//
//  QRSharingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 25.05.2022.
//

import UIKit
import SwiftyTON
import HuetonUI
import QRCode

class QRSharingViewController: UIViewController {
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.text = "Share this QR code to receive coins"
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let qrImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var addressButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(addressButtonDidClick(_:)), for: .touchUpInside)
        $0.setTitleColor(.hui_textPrimary, for: .normal)
        $0.titleLabel?.font = .font(for: .subheadline)
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.lineBreakMode = .byCharWrapping
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    })
    
    private lazy var doneButton = PrimaryButton(title: "DONE").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    })
    
    let initialConfiguration: InitialConfiguration
    
    init(initialConfiguration: InitialConfiguration) {
        self.initialConfiguration = initialConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sharing"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(qrImageView)
        view.addSubview(addressButton)
        view.addSubview(doneButton)
        
        let address = initialConfiguration.address
        addressButton.setTitle(
        """
        or just copy address:
        
        \(address.convert(to: .base64url(flags: [])))
        """, for: .normal)
        
        let url = ConvenienceURL.transfer(
            destination: address,
            amount: nil,
            text: nil
        ).url
        
        let qr = QRCode.Document(
            utf8String: url.absoluteString,
            errorCorrection: .medium
        )
        
        qr.design.shape.data = QRCode.DataShape.RoundedPath()
        qr.design.shape.eye = QRCode.EyeShape.Squircle()
        
        qrImageView.layer.cornerRadius = 12
        qrImageView.layer.cornerCurve = .continuous
        qrImageView.layer.masksToBounds = true
        
        let rect = CGRect(origin: .zero, size: CGSize(width: 512, height: 512))
        qrImageView.image = UIGraphicsImageRenderer(size: rect.size).image(actions: { context in
            qr.draw(ctx: context.cgContext, rect: rect)
            guard let cgImage = UIImage.hui_qrCodeOverlay512.cgImage
            else {
                return
            }
            context.cgContext.draw(cgImage, in: rect)
        })
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            qrImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32)
            qrImageView.pin(horizontally: view, left: 48, right: 48)
            qrImageView.heightAnchor.pin(to: qrImageView.widthAnchor)
            
            addressButton.topAnchor.pin(to: qrImageView.bottomAnchor, constant: 16)
            addressButton.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(lessThan: addressButton.bottomAnchor, constant: 16)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: doneButton.bottomAnchor, constant: 16)
        })
        
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
    
    @objc
    private func addressButtonDidClick(_ sender: UIButton) {
        let address = initialConfiguration.address
        UIPasteboard.general.string = address.convert(to: .base64url(flags: []))
        
        InAppAnnouncementCenter.shared.post(
            announcement: InAppAnnouncementInfo.self,
            with: .addressCopied
        )
    }
}
