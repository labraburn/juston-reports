//
//  File.swift
//  
//
//  Created by Anton on 22.02.2021.
//

import UIKit

protocol DisplayDelegate: NSObjectProtocol {
    
    func displayDidRequireDraw(_ display: Display)
}

final class Display {

    weak var delegate: DisplayDelegate?
    
    private var link: CADisplayLink? = nil
    private let offset: TimeInterval = 0
    
    private(set) var isPaused: Bool = false
    private(set) var time: TimeInterval = 0
    private(set) var lastUpdate: TimeInterval = 0
    
    var currentTimestamp: CFTimeInterval { (link?.timestamp ?? 0) + offset }
    
    init(timeOffset: TimeInterval) {
        time = timeOffset
        lastUpdate = timeOffset
        
        link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link?.preferredFramesPerSecond = 45
        link?.add(to: RunLoop.main, forMode: .default)
    }
    
    func pause() {
        if isPaused {
            return
        }
        
        isPaused = true
    }
    
    func play() {
        if !isPaused {
            return
        }
        
        isPaused = false
    }
    
    func invalidate() {
        link?.invalidate()
        link = nil
    }
    
    @objc func tick(_ link: CADisplayLink) {
        if isPaused {
            return
        }
        
        self.lastUpdate = (link.targetTimestamp - link.timestamp)
        self.time += self.lastUpdate
        
        delegate?.displayDidRequireDraw(self)
    }
}
