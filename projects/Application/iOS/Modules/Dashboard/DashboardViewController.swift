//
//  DashboardViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit

class DashboardViewController: UIViewController {
    
    private var dashboardView: DashboardView { view as! DashboardView }

    override func loadView() {
        let view = DashboardView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
