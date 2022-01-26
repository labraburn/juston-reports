//
//  File.swift
//  
//
//  Created by Anton on 28.02.2021.
//

import UIKit

protocol AnimationProtocol {
    
    var isFinished: Bool { get }
    
    func prepare(with currentTimestamp: TimeInterval)
    func update(with currentTimestamp: TimeInterval)
}

public protocol Animatable: Equatable {
    
    static func progress(_ lhs: Self, _ rhs: Self, progress: Double) -> Self
}

public final class Animation<T: Animatable>: AnimationProtocol {
    
    public typealias AnimationBlock = ((_ value: T) -> ())
    
    enum Interpolation {
        
        case linear
        case easing
        case easeInOut
        case easeIn
        case easeOut
        
        func progress(_ progress: Double) -> Double {
            switch self {
            case .linear: return progress
            case .easeIn: return progress * progress * progress
            case .easeOut: return 1 - pow(1 - progress, 3)
            case .easeInOut: return progress < 0.5 ? 4 * progress * progress * progress : 1 - pow(-2 * progress + 2, 3) / 2
            case .easing: return 1 - ((1 - progress) * (1 - progress))
            }
        }
    }
    
    private let interpolation: Interpolation = .easeInOut
    
    private var previousTimestamp: CFTimeInterval = 0.0
    private var elapsedTime: CFTimeInterval = 0.0
    
    let duration: CFTimeInterval
    let from: T
    let to: T
    let block: AnimationBlock
    
    private(set) var isFinished = false

    public init(from: T, to: T, duration: TimeInterval, block: @escaping AnimationBlock) {
        self.from = from
        self.to = to
        self.duration = duration
        self.block = block
    }
    
    func prepare(with currentTimestamp: TimeInterval) {
        previousTimestamp = currentTimestamp
    }
    
    func update(with currentTimestamp: TimeInterval) {
        if isFinished {
            return
        }
        
        let timestampDiff = currentTimestamp - previousTimestamp
        elapsedTime += timestampDiff
        
        if elapsedTime > duration {
            elapsedTime = duration
            isFinished = true
        }
        
        let progress = elapsedTime / duration
        block(T.progress(from, to, progress: interpolation.progress(progress)))
        
        previousTimestamp = currentTimestamp
    }
}

extension Array: Animatable where Element: Animatable {
    
    public static func progress(_ lhs: Array<Element>, _ rhs: Array<Element>, progress: Double) -> Array<Element> {
        var result = lhs
        for (index, element) in lhs.enumerated() {
            result[index] = Element.progress(element, rhs[index], progress: progress)
        }
        return result
    }
}

extension CGFloat: Animatable {
    
    public static func progress(_ lhs: CGFloat, _ rhs: CGFloat, progress: Double) -> CGFloat {
        lhs + (rhs - lhs) * CGFloat(progress)
    }
}

extension Double: Animatable {
    
    public static func progress(_ lhs: Double, _ rhs: Double, progress: Double) -> Double {
        lhs + (rhs - lhs) * progress
    }
}

extension UIColor: Animatable {
    
    private var components: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        guard let components = self.cgColor.components else {
            fatalError("")
        }

        switch components.count == 2 {
        case true : return (r: components[0], g: components[0], b: components[0], a: components[1])
        case false: return (r: components[0], g: components[1], b: components[2], a: components[3])
        }
    }
    
    public static func progress(_ lhs: UIColor, _ rhs: UIColor, progress: Double) -> Self {
        let from = lhs.components
        let to = rhs.components
        let p = CGFloat(progress)

        let r = (1 - p) * from.r + p * to.r
        let g = (1 - p) * from.g + p * to.g
        let b = (1 - p) * from.b + p * to.b
        let a = (1 - p) * from.a + p * to.a

        guard let color = UIColor(red: r, green: g, blue: b, alpha: a) as? Self else {
            fatalError("")
        }
        
        return color
    }
}
