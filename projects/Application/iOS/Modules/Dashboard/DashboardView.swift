//
//  DashboardView.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import BilftUI

class DashboardView: CollectionCompositionView {
    
    enum RefreshControlValue: Equatable {
        case text(value: String)
        case synchronization(value: Double)
        case lastUpdatedDate(date: Date)
    }
    
    var refreshControlValueTimer: Timer? = nil
    var refreshControlValue: RefreshControlValue = .lastUpdatedDate(date: Date()) {
        didSet {
            guard refreshControlValue != oldValue
            else {
                return
            }
            
            updateLogoViewTextLabel()
        }
    }
    
    
    init() {
        super.init(collectionViewLayout: DashboardCollectionViewLayout())
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        refreshControlValueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self
            else {
                timer.invalidate()
                return
            }
            
            self.updateLogoViewTextLabel()
        })
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        refreshControlValueTimer?.invalidate()
    }
    
    // MARK: Private
    
    private func updateLogoViewTextLabel() {
        switch refreshControlValue {
        case let .text(value):
            logoView.text = value
        case let .lastUpdatedDate(date):
            let formatter = RelativeDateTimeFormatter.shared
            let timeAgo = formatter.localizedString(for: Date(), relativeTo: date)
            logoView.text = "Updated \(timeAgo) ago"
        case let .synchronization(value):
            logoView.text = "Syncing.. \(Int(value * 100))%"
        }
    }
}
