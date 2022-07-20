//
//  Created by Anton Spivak.
//

import UIKit

open class JustonView: SignboardView {
    
    private var timer: Timer? = nil
    
    public init() {
        super.init(
            letters: [
                .init(character: "J", color: .jus_letter_red, tumbler: .off),
                .init(character: "U", color: .jus_letter_yellow, tumbler: .off),
                .init(character: "S", color: .jus_letter_green, tumbler: .off),
                .init(character: "T", color: .jus_letter_blue, tumbler: .off),
                .init(character: "O", color: .jus_letter_violet, tumbler: .off),
                .init(character: "N", color: .jus_letter_purple, tumbler: .off),
            ]
        )
    }
    
    deinit {
        invalidateTimer()
    }
    
    // MARK: API
    
    public func perfromLoadingAnimationAndStartInfinity() {
        guard letters.filter({ $0.tumbler == .on }).isEmpty
        else {
            return
        }
        
        performUpdatesWithLetters({ updates in
            updates.trigger()
        }, completion: { [weak self] _ in
            self?.startTimerIfNeeded()
        })
    }
    
    // MARK: Private
    
    private func startTimerIfNeeded() {
        guard timer == nil
        else {
            return
        }
        
        let timer = Timer(timeInterval: 3, repeats: true, block: { [weak self] timer in
            guard let self = self
            else {
                timer.invalidate()
                return
            }
            
            self.timerDidChange()
        })
        
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerDidChange() {
        guard Int.random(in: 0..<99) < 33
        else {
            return
        }
        
        var tumblers: [[SignboardTumbler]] = [
            .on(count: 6),
            .on(count: 6),
            .on(count: 6),
            .on(count: 6),
            .on(count: 6),
            .on(count: 6),
            .on(count: 6),
        ]
        
        let random = Int.random(in: 0..<6)
        tumblers[0][random] = .off
        tumblers[1][random] = .on
        tumblers[2][random] = .on
        tumblers[3][random] = .off
        tumblers[4][random] = .off
        tumblers[5][random] = .off
        tumblers[6][random] = .on
        
        performUpdatesWithLetters({ updates in
            updates.animate(sequence: tumblers, duration: 1)
        }, completion: nil)
    }
}
