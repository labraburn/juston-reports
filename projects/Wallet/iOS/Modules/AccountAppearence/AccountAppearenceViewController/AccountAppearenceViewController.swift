//
//  AccountAppearenceViewController.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import UIKit
import HuetonCORE

class AccountAppearenceViewController: BaseAccountAppearenceViewController {

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
        
        name = initialConfiguration.account.name
        style = initialConfiguration.account.appearance
        
        doneButton.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    private func doneButtonDidClick(_ sender: UIButton) {
        let id = initialConfiguration.account.objectID
        
        let appearance = self.style
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else {
            markNameTextViewAsError()
            return
        }
        
        Task { @PersistenceWritableActor in
            let object = PersistenceAccount.writeableObject(id: id)
            object.name = name
            object.appearance = appearance
            try? object.save()
        }
        
        hide(animated: true)
    }
}
