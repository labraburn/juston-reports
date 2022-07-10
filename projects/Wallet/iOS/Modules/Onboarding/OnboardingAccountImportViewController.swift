//
//  OnboardingAccountImportViewController.swift
//  iOS
//
//  Created by Anton Spivak on 02.06.2022.
//

import UIKit
import HuetonUI
import HuetonCORE

class OnboardingAccountImportViewController: C42ConcreteViewController {
    
    enum Result {
        
        case words(value: [String])
        case address(value: String)
    }
    
    typealias CompletionBlock = (
        _ viewController: C42ViewController,
        _ result: Result
    ) async throws -> Void
    
    private let errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .hui_textPrimary
        $0.text = "OnboardingImportDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private lazy var inputTextView = BorderedTextView(caption: "OnboardingImportTitleCaption".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.keyboardType = .asciiCapable
        $0.textView.returnKeyType = .done
        $0.textView.autocorrectionType = .no
        $0.textView.autocapitalizationType = .none
        $0.textView.minimumContentSizeHeight = 64
        $0.textView.maximumContentSizeHeight = 96
        $0.heightAnchor.pin(lessThan: 256).isActive = true
    })
    
    lazy var nextButton = PrimaryButton(title: "OnboardingNextButton".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(self, action: #selector(nextButtonDidClick(_:)), for: .touchUpInside)
    })
    
    let completionBlock: CompletionBlock
    
    init(
        completionBlock: @escaping CompletionBlock,
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.completionBlock = completionBlock
        super.init(
            title: "OnboardingImportTitle".asLocalizedKey,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .hui_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(inputTextView)
        view.addSubview(nextButton)
        
        inputTextView.actions = [
            .init(
                image: .hui_scan20,
                block: { [weak self] in
                    self?.scanQRAndFill()
                }
            )
        ]
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            inputTextView.topAnchor.pin(to: descriptionLabel.bottomAnchor, constant: 32)
            inputTextView.pin(horizontally: view, left: 16, right: 16)
            
            nextButton.topAnchor.pin(greaterThan: inputTextView.bottomAnchor, constant: 24)
            nextButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: nextButton.bottomAnchor, constant: 8)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(false)
    }
    
    fileprivate func result(from textView: UITextView) -> Result? {
        guard textView.hasText
        else {
            return nil
        }
        
        let words = (textView.text?.split(whereSeparator: { !$0.isLetter }) ?? []).map({ String($0)})
        if words.count == 24 {
            return .words(value: words)
        } else if let _ = ConcreteAddress(string: textView.text) {
            return .address(value: textView.text)
        } else if DNSAddress.isTONDomain(string: textView.text) {
            return .address(value: textView.text)
        } else {
            return nil
        }
    }
    
    fileprivate func markTextViewErrorIfNeeded() {
        guard result(from: inputTextView.textView) == nil
        else {
            return
        }
        
        markTextViewError()
    }
    
    fileprivate func markTextViewError() {
        inputTextView.shake()
        inputTextView.textView.textColor = .hui_letter_red
        errorFeedbackGenerator.impactOccurred()
    }
    
    private func scanQRAndFill() {
        let qrViewController = CameraViewController()
        qrViewController.delegate = self
        
        let navigationController = NavigationController(rootViewController: qrViewController)
        hui_present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @objc
    private func nextButtonDidClick(_ sender: UIButton) {
        guard let result = result(from: inputTextView.textView)
        else {
            markTextViewErrorIfNeeded()
            return
        }
        
        nextButton.startAsynchronousOperation({ @MainActor in
            do {
                try await self.completionBlock(self, result)
            } catch AddressError.unparsable {
                self.markTextViewError()
            } catch {
                self.present(error)
            }
        })
    }
}

extension OnboardingAccountImportViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        inputTextView.setFocused(true)
        textView.textColor = .white
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.count > 1 {
            // copy/paste
            
            DispatchQueue.main.async(execute: {
                if self.result(from: textView) != nil {
                    textView.resignFirstResponder()
                }
            })
            
            return true
        } else if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {}
    
    func textViewDidEndEditing(_ textView: UITextView) {
        inputTextView.setFocused(false)
        markTextViewErrorIfNeeded()
    }
}

extension OnboardingAccountImportViewController: CameraViewControllerDelegate {
    
    func qrViewController(
        _ viewController: CameraViewController,
        didRecognizeConvenienceURL convenienceURL: ConvenienceURL
    ) {
        viewController.hide(animated: true)
        
        switch convenienceURL {
        case let .transfer(destination, _, _):
            inputTextView.textView.text = destination.displayName
        }
    }
}
