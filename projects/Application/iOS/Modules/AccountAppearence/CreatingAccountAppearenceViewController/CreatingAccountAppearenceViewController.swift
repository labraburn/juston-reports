//
//  CreatingAccountAppearenceViewController.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import UIKit
import HuetonCORE

class CreatingAccountAppearenceViewController: BaseAccountAppearenceViewController {
    
    typealias CompletionBlock = (_ name: String, _ appearence: AccountAppearance) async throws -> Void
    
    private var task: Task<(), Never>?
    private var locked: Bool = false {
        didSet {
            view.isUserInteractionEnabled = locked
        }
    }
    
    let completionBlock: CompletionBlock
    
    init(completionBlock: @escaping CompletionBlock) {
        self.completionBlock = completionBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        guard task == nil
        else {
            return
        }

        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else {
            markNameTextViewAsError()
            return
        }
        
        let style = self.style
        view.isUserInteractionEnabled = true
        
        task?.cancel()
        task = Task { [weak self] in
            do {
                try await self?.completionBlock(name, style)
            } catch {
                present(error)
            }
            
            self?.view.isUserInteractionEnabled = true
            self?.task = nil
        }
    }
}
