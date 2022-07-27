//
//  QRSharingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 25.05.2022.
//

import UIKit
import SwiftyTON
import JustonUI
import QRCode

class QRSharingViewController: UIViewController {
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .jus_textPrimary
        $0.text = "Share this QR code to others receive coins into account"
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let qrImageView = UIImageView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private lazy var addressButton = UIButton().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(addressButtonDidClick(_:)), for: .touchUpInside)
        $0.setTitleColor(.jus_textPrimary, for: .normal)
        $0.titleLabel?.font = .font(for: .subheadline)
        $0.titleLabel?.numberOfLines = 0
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.lineBreakMode = .byCharWrapping
        $0.insertHighlightingScaleAnimation()
        $0.insertFeedbackGenerator(style: .light)
        $0.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
    })
    
    private lazy var shareImageButton = PrimaryButton(title: "ShareQRMainButton".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(shareImageButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var shareAddressButton = PrimaryButton(title: "ShareQRShareAddressButton".asLocalizedKey.uppercased()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(shareAddressButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private lazy var doneButton = TeritaryButton(title: "CommonDone".asLocalizedKey.uppercased()).with({
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
        
        title = "Your address"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .jus_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(qrImageView)
        view.addSubview(addressButton)
        
        view.addSubview(shareImageButton)
        view.addSubview(shareAddressButton)
        view.addSubview(doneButton)
        
        let address = initialConfiguration.address
        addressButton.setTitle(address.description, for: .normal)
        
        let url = SchemeURL.transfer(
            scheme: .ton,
            configuration: TransferConfiguration(
                destination: DisplayableAddress(rawValue: address)
            )
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
            guard let cgImage = UIImage.jus_qrCodeOverlay512.cgImage
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
            qrImageView.heightAnchor.pin(lessThan: qrImageView.widthAnchor)
            
            addressButton.topAnchor.pin(to: qrImageView.bottomAnchor, constant: 16)
            addressButton.centerXAnchor.pin(to: view.centerXAnchor)
            addressButton.widthAnchor.pin(to: qrImageView.widthAnchor)
            
            shareImageButton.topAnchor.pin(greaterThan: addressButton.bottomAnchor, constant: 24)
            shareImageButton.pin(horizontally: view, left: 16, right: 16)
            
            shareAddressButton.topAnchor.pin(lessThan: shareImageButton.bottomAnchor, constant: 16)
            shareAddressButton.pin(horizontally: view, left: 16, right: 16)
            
            doneButton.topAnchor.pin(lessThan: shareAddressButton.bottomAnchor, constant: 8)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: doneButton.bottomAnchor, constant: 8)
        })
        
    }
    
    // MARK: Actions
    
    @objc
    private func shareImageButtonDidClick(_ sender: UIButton) {
        guard let image = qrImageView.image
        else {
            return
        }
        
        let activityItems = [image]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        jus_present(activityViewController, animated: true)
    }
    
    @objc
    private func shareAddressButtonDidClick(_ sender: UIButton) {
        let activityItems = [initialConfiguration.address.description]
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        jus_present(activityViewController, animated: true)
    }
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
    
    @objc
    private func addressButtonDidClick(_ sender: UIButton) {
        let address = initialConfiguration.address
        UIPasteboard.general.string = address.description
        
        InAppAnnouncementCenter.shared.post(
            announcement: InAppAnnouncementInfo.self,
            with: .addressCopied
        )
    }
}
