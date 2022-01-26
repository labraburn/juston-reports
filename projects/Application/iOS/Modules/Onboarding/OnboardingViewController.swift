//
//  OnboardingViewController.swift
//  iOS
//
//  Created by Anton Spivak on 26.01.2022.
//

import UIKit
import SpriteKit

protocol OnboardingViewControllerDelegate: AnyObject {
    
    func onboardingViewControllerDidComplete(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {
    
    weak var delegate: OnboardingViewControllerDelegate? = nil
    
    struct Step {}
    
    @IBOutlet weak var skview: SKView!
    @IBOutlet weak var continueButton: UIButton!
    
    private var steps: [Step] = [.init(), .init(), .init(), .init()]
    private var step: Int = 0
    
    private var skscene: SKScene {
        skview.scene!
    }
    
    private var size: CGSize = .zero {
        didSet { skscene.size = size }
    }
    
    private lazy var skbutton: SKSpriteNode = {
        skscene.childNode(withName: "ButtonBackground") as! SKSpriteNode
    }()
    
    private lazy var lights: [SKLightNode] = {
        var lights: [SKLightNode] = []
        for i in 0 ..< 4 {
            let node = skscene.childNode(withName: "BackgroundLight\(i)")
            guard let node = node as? SKLightNode
            else {
                continue
            }
            
            
            lights.append(node)
        }
        return lights
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard size != view.bounds.size
        else {
            return
        }
        
        size = view.bounds.size
        let height = size.height
        
        // Lights
        
        let y = { height / 2 + .random(in: 0...height / 2) }
        var position = CGPoint(
            x: -size.width / 2,
            y: y()
        )
        
        lights.forEach { node in
            node.position = position
            
            position.y = y()
            position.x += size.width
        }
        
        // Button
        
        skbutton.size = continueButton.bounds.size
        skbutton.position = CGPoint(
            x: 0,
            y: -continueButton.center.y + size.height / 2
        )
    }
    
    private func next() {
        let next = step + 1
        guard next < steps.count
        else {
            delegate?.onboardingViewControllerDidComplete(self)
            return
        }
        
        let action = SKAction.moveBy(x: -view.bounds.width, y: 0, duration: 0.24)
        lights.forEach { $0.run(action) }
        
        step = next
    }
    
    // MARK: Actions
    
    @IBAction func continueButtonDidClick(_ sender: UIButton) {
        next()
    }
}
