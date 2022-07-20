//
//  PasscodeViewController.swift
//  iOS
//
//  Created by Anton Spivak on 10.04.2022.
//

import UIKit
import JustonUI
import JustonCORE

protocol PasscodeViewControllerDelegate: AnyObject {
    
    @MainActor
    func passcodeViewController(
        _ viewController: PasscodeViewController,
        didFinishWithPasscode passcode: String
    )
    
    @MainActor
    func passcodeViewControllerDidCancel(
        _ viewController: PasscodeViewController
    )
    
    @MainActor
    func passcodeViewControllerDidRequireBiometry(
        _ viewController: PasscodeViewController
    )
}

class PasscodeViewController: UIViewController {
    
    enum PasscodeMode {
        
        case create
        case get
    }
    
    fileprivate enum PasscodeModel {
        
        case get
        
        case create1Step
        case create2Step(create1Code: String)
    }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var passcodeHStackView: UIStackView!
    
    @IBOutlet private weak var faceIDButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var cancelButton: TeritaryButton!
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    weak var delegate: PasscodeViewControllerDelegate?
    
    private var model: PasscodeModel {
        didSet {
            updatePasscodeViews()
        }
    }
    
    private var code: String {
        didSet {
            updatePasscodeViews()
            finishIfNeeded()
        }
    }
    
    init(mode: PasscodeMode) {
        switch mode {
        case .get:
            model = .get
        case .create:
            model = .create1Step
        }
        
        code = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = .font(for: .headline)
        view.backgroundColor = .jus_backgroundPrimary
        
        faceIDButton.setImage(
            UIImage(
                systemName: "faceid",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 28)),
            for: .normal
        )
        
        deleteButton.setImage(
            UIImage(
                systemName: "delete.left",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 22)),
            for: .normal
        )
        
        cancelButton.title = "CANCEL"
        
        updatePasscodeViews()
    }
    
    public func restart(throwingError: Bool) {
        switch model {
        case .get:
            break
        case .create1Step:
            break
        case .create2Step:
            model = .create1Step
        }
        
        if throwingError {
            feedbackGenerator.notificationOccurred(.error)
            passcodeHStackView.shake()
        }
        
        code = ""
        updatePasscodeViews()
    }
    
    // MARK: Private
    
    private func updatePasscodeViews() {
        switch model {
        case .get:
            break
        case .create1Step, .create2Step:
            self.cancelButton.isHidden = true
            
            // Settings alpha because superview of this button is UIStackView
            self.faceIDButton.alpha = 0
            self.faceIDButton.isUserInteractionEnabled = false
        }
        
        var index = 0
        passcodeHStackView.arrangedSubviews.forEach({ subview in
            guard let subview = subview as? PasscodeDotView
            else {
                return
            }
            subview.filled = code.count > index
            index += 1
        })
        
        titleLabel.text = model.text
    }
    
    private func finishIfNeeded() {
        guard code.count == 6
        else {
            return
        }
        
        switch model {
        case .get:
            delegate?.passcodeViewController(self, didFinishWithPasscode: code)
        case .create1Step:
            model = .create2Step(create1Code: code)
            code = ""
        case .create2Step(let create1Code):
            guard create1Code == code
            else {
                restart(throwingError: true)
                break
            }
            delegate?.passcodeViewController(self, didFinishWithPasscode: code)
        }
    }
    
    // MARK: Actions
    
    @IBAction
    private func numberButtonDidClick(_ sender: UIButton) {
        guard code.count < 6
        else {
            return
        }
        
        let number = "\(sender.tag)"
        code = "\(code)\(number)"
    }
    
    @IBAction
    private func biometryButtonDidClick(_ sender: UIButton) {
        delegate?.passcodeViewControllerDidRequireBiometry(self)
    }
    
    @IBAction
    private func deleteButtonDidClick(_ sender: UIButton) {
        guard code.count > 0
        else {
            return
        }
        
        code = String(code.dropLast())
    }
    
    @IBAction
    private func cancelButtonDidClick(_ sender: TeritaryButton) {
        delegate?.passcodeViewControllerDidCancel(self)
    }
}

private extension PasscodeViewController.PasscodeModel {
    
    var text: String {
        switch self {
        case .get:
            return "PasscodeViewEnterCode".asLocalizedKey
        case .create1Step:
            return "PasscodeViewCreateCode1".asLocalizedKey
        case .create2Step:
            return "PasscodeViewCreateCode2".asLocalizedKey
        }
    }
}
