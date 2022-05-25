//
//  QRViewController.swift
//  iOS
//
//  Created by Anton Spivak on 24.05.2022.
//

import UIKit
import AVFoundation
import SwiftyTON
import HuetonUI

protocol CameraViewControllerDelegate: AnyObject {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeConvenienceURL convenienceURL: ConvenienceURL
    )
}

class CameraViewController: UIViewController {
    
    private enum CaptureSessionError: LocalizedError {
        
        case noCamera
        case noPermission
        
        var errorDescription: String? {
            switch self {
            case .noCamera:
                return "Hmm, looks like we can't fina any camera on device"
            case .noPermission:
                return "Please, allow camera access in settings to scan QR code"
            }
        }
    }
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.text = "Please, position camera to any QR code and we will try to detect TON address"
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private let cameraView = UIView().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .hui_backgroundSecondary
    })
    
    private lazy var cancelButton = TeritaryButton(title: "CANCEL").with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
    })
    
    private var session: AVCaptureSession?
    private var layer: AVCaptureVideoPreviewLayer?
    private let queue = DispatchQueue(label: "com.hueton.capture-session")
    private var convenienceURL: ConvenienceURL? = nil
    
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .hui_backgroundPrimary
        
        
        cameraView.layer.cornerRadius = 12
        cameraView.layer.cornerCurve = .continuous
        
        view.addSubview(descriptionLabel)
        view.addSubview(cameraView)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            cameraView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32)
            cameraView.pin(horizontally: view, left: 16, right: 16)
            
            cancelButton.topAnchor.pin(to: cameraView.bottomAnchor, constant: 16)
            cancelButton.pin(horizontally: view, left: 16, right: 16)
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: cancelButton.bottomAnchor, constant: 8)
        })
        
        startCaptureSessionIfNeeded({ error in
            guard let error = error
            else {
                return
            }
            print(error)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraView.startLoadingAnimation(delay: 0.1, fade: false, width: 3)
        convenienceURL = nil
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            present(CaptureSessionError.noPermission)
        default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraView.stopLoadingAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layer?.cornerRadius = cameraView.layer.cornerRadius
        layer?.cornerCurve = cameraView.layer.cornerCurve
        layer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer?.frame = cameraView.layer.bounds
    }
    
    private func startCaptureSessionIfNeeded(_ completion: @escaping (_ error: Error?) -> ()) {
        queue.async(execute: {
            guard self.session == nil
            else {
                return
            }
            
            let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInDualCamera,
                    .builtInWideAngleCamera,
                    .builtInTripleCamera,
                    .builtInUltraWideCamera
                ],
                mediaType: .video,
                position: .back
            )

            guard let captureDevice = deviceDiscoverySession.devices.first
            else {
                completion(CaptureSessionError.noCamera)
                return
            }
            
            let output = AVCaptureMetadataOutput()
            let input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: captureDevice)
            } catch {
                completion(error)
                return
            }
            
            let session = AVCaptureSession()
            session.addOutput(output)
            session.addInput(input)
            
            output.setMetadataObjectsDelegate(self, queue: self.queue)
            output.metadataObjectTypes = [.qr]
            
            session.startRunning()
            
            let layer = AVCaptureVideoPreviewLayer(session: session)
            
            DispatchQueue.main.async(execute: {
                self.cameraView.layer.insertSublayer(layer, at: 0)
                self.view.setNeedsLayout()
            })
            
            self.session = session
            self.layer = layer
            
            completion(nil)
        })
    }
    
    // MARK: Actions
    
    @objc
    private func cancelButtonDidClick(_ sender: UIButton) {
        hide(animated: true)
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !metadataObjects.isEmpty, self.convenienceURL == nil
        else {
            return
        }
        
        let readableCodeObjects = metadataObjects
            .compactMap({ $0 as? AVMetadataMachineReadableCodeObject })
            .filter({ $0.type == .qr })
        
        guard let readableCodeObject = readableCodeObjects.first,
              let stringValue = readableCodeObject.stringValue,
              let convenienceURL = ConvenienceURL(stringValue)
        else {
            return
        }
        
        self.convenienceURL = convenienceURL
        DispatchQueue.main.async {
            self.delegate?.qrViewController(
                self,
                didRecognizeConvenienceURL: convenienceURL
            )
        }
    }
}
