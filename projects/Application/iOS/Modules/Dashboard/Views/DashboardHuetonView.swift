//
//  DashboardHuetonView.swift
//  iOS
//
//  Created by Anton Spivak on 04.04.2022.
//

import UIKit
import HuetonUI
import HuetonCORE
import SwiftyTON

class DashboardHuetonView: HuetonView {
    
    private var timer: Timer? = nil
    private var date: Date? = nil
    private var observer: AnyObject? = nil
    
    private enum TextMode: Equatable {
        
        case calm
        case loading(progress: Double)
    }
    
    var account: PersistenceAccount? {
        didSet {
            oldValue?.remove(observer: self)
            account?.register(observer: self)
            
            guard let account = account
            else {
                return
            }

            persistenceObjectDidChange(account)
        }
    }
    
    private var textMode: TextMode = .loading(progress: 0) {
        didSet {
            switch textMode {
            case .calm:
                startUpdatesIfNeccessary()
            case let .loading(progress):
                stopUpdates()
                text = "Syncing.. \(Int(progress * 100))%"
            }
        }
    }
    
    override init() {
        super.init()
        
        defer {
            textMode = .calm
        }
        
        observer = NotificationCenter.default.addObserver(
            forName: SwiftyTON.didUpdateSynchronization,
            object: nil,
            queue: .main,
            using: { [weak self] notification in
                guard let self = self
                else {
                    return
                }
                
                let value = notification.userInfo?[SwiftyTON.synchronizationKey]
                if let progress = value as? Double, progress > 0, progress < 1 {
                    self.textMode = .loading(progress: progress)
                } else {
                    self.textMode = .calm
                }
            }
        )
    }
    
    deinit {
        stopUpdates()
    }
    
    // MARK: Private
    
    private func startUpdatesIfNeccessary() {
        guard timer == nil
        else {
            return
        }
        
        let updates = { [weak self] (_ timer: Timer) in
            guard let self = self,
                  self.textMode == .calm
            else {
                return
            }
            
            if let date = self.date {
                let formatter = RelativeDateTimeFormatter.shared
                let timeAgo = formatter.localizedString(for: Date(), relativeTo: date)
                self.text = "Updated \(timeAgo) ago"
            } else {
                self.text = ""
            }
        }
        
        let timer = Timer(timeInterval: 1, repeats: true, block: updates)
        RunLoop.main.add(timer, forMode: .common)
        
        self.timer = timer
    }
    
    private func stopUpdates() {
        timer?.invalidate()
        timer = nil
    }
}

extension DashboardHuetonView: PersistenceObjectObserver {
    
    func persistenceObjectDidChange(_ persistenceObject: PersistenceObject) {
        date = (persistenceObject as? PersistenceAccount)?.synchronizationDate
    }
}
