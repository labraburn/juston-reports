//
//  DashboardViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI
import SwiftyTON
import Combine

class DashboardViewController: UIViewController {
    
    private var dashboardView: DashboardView { view as! DashboardView }
    private let address: String
    private var cancellables: Set<AnyCancellable> = []
    
    init(address: String) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashboardView.logoView.update(presentation: .on)
        dashboardView.addressLabel.text = address
        
        let ton = TON.shared
        ton.synchronization.receive(on: RunLoop.main).sink(receiveValue: { [weak self] progress in
            guard let self = self
            else {
                return
            }
            
            let view = self.dashboardView
            if progress < 1 {
                view.progressLabel.text = "Syncing.. \(progress)"
                self.dashboardView.logoView.startLoadingAnimation()
            } else {
                view.progressLabel.text = "Synced."
                self.dashboardView.logoView.stopLoadingAnimation()
            }
        }).store(in: &cancellables)
        
        Task {
            do {
                let state = try await ton.accountStateWithAddress(self.address)
                print(state)
            } catch {
                self.presentAlertViewController(with: error)
            }
        }
    }
}
