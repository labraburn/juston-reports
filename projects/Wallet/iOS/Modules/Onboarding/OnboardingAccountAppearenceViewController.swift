//
//  OnboardingAccountAppearenceViewController.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import UIKit
import JustonCORE

class OnboardingAccountAppearenceViewController: C42ConcreteViewController {
    
    typealias CompletionBlock = (
        _ viewController: C42ViewController,
        _ name: String,
        _ appearence: AccountAppearance
    ) async throws -> Void
    
    private let appearanceViewController = BaseAccountAppearenceViewController()
    
    private var task: Task<(), Never>?
    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
    
    let completionBlock: CompletionBlock
    
    init(
        title: String,
        predefinedName: String?,
        completionBlock: @escaping CompletionBlock,
        isModalInPresentation: Bool = false,
        isBackActionAvailable: Bool = true,
        isNavigationBarHidden: Bool = false
    ) {
        self.completionBlock = completionBlock
        super.init(
            title: title,
            isModalInPresentation: isModalInPresentation,
            isBackActionAvailable: isBackActionAvailable,
            isNavigationBarHidden: isNavigationBarHidden
        )
        self.appearanceViewController.name = predefinedName
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(appearanceViewController)
        appearanceViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appearanceViewController.view)
        appearanceViewController.view.pinned(edges: view)
        appearanceViewController.didMove(toParent: self)
        
        appearanceViewController.doneButton.addTarget(
            self,
            action: #selector(doneButtonDidClick(_:)),
            for: .touchUpInside
        )
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        guard task == nil
        else {
            return
        }

        guard let name = appearanceViewController.name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else {
            appearanceViewController.markNameTextViewAsError()
            return
        }
        
        let style = appearanceViewController.style
        view.isUserInteractionEnabled = false
        
        task?.cancel()
        task = Task {
            do {
                try await self.completionBlock(self, name, style)
            } catch {
                present(error)
            }
            
            self.view.isUserInteractionEnabled = true
            self.task = nil
        }
    }
}
