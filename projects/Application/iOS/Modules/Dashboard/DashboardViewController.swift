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
    private var isUpdating = false
    private var dataSource: UICollectionViewDiffableDataSource<Int, Int>?
    
    init(address: String) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = DashboardView()
        view.delegate = self
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dashboardView.logoLoadingAddiotionlText = "Last updated \(10) min"
        dashboardView.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: dashboardView.collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "cell",
                    for: indexPath
                )
                cell.backgroundColor = .black
                return cell
            }
        )
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        snapshot.appendItems([0, 1, 2], toSection: 0)
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
//        dashboardView.logoView.update(presentation: .on)
//        dashboardView.addressLabel.text = address
        
        let ton = TON.shared
        ton.synchronization.receive(on: RunLoop.main).sink(receiveValue: { [weak self] progress in
            guard let self = self
            else {
                return
            }
            
            let view = self.dashboardView
            view.updateLoadingAnimationWithProgress(progress)
        }).store(in: &cancellables)
        
        dashboardView.startLoadingAnimation()
        updateIfNeeded()
    }
    
    private func updateIfNeeded() {
        guard !isUpdating
        else {
            return
        }
        
        isUpdating = true
        let ton = TON.shared
        
        Task {
            do {
//                let state = try await ton.accountStateWithAddress("EQBKCMGcAoyyG85L3SIakVRLMfwhp7-xA13jTWAYO1jgpb81") // v4
//                let state = try await ton.accountStateWithAddress("EQCMfNwPB8TaNqQ9hnXCYcXOz41jfI5PCawHe1ZvwKfKXTXM") // united
                let state = try await ton.accountStateWithAddress("EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk") // main
                
                let key = try await ton.storage.key(for: self.address)!
                let words = try await ton.wordsForKey(key, userPassword: Data())
                
                print(self.address)
                print(words)
                
//                var value = "0"
//                if state.balance > 0 {
//                    let string = "\(state.balance)"
//                    let last = string[lower: (string.count - 9), upper: string.count]
//                }
                
//                self.dashboardView.progressLabel.text = "\(state.balance)"
                print(state)
            } catch {
                self.presentAlertViewController(with: error)
            }
            
            self.isUpdating = false
            self.dashboardView.finishLoadingAnimationIfNeeded()
        }
    }
}

extension DashboardViewController: CollectionCompositionViewDelegate {
    
    func collectionCompositionViewShouldStartReload(_ view: CollectionCompositionView) -> Bool {
        updateIfNeeded()
        return true
    }
}





//
//
//
//
//
// 14.9
// EQAVhOY2uT49tcvM6rRJII25bgEqEBWu6ZywXrtaqYtvIlMk
// ["episode", "diary", "tower", "either", "void", "into", "until", "universe", "loan", "answer", "own", "ribbon", "adapt", "step", "tuna", "innocent", "accident", "female", "already", "nasty", "wrist", "tenant", "toast", "post"]
