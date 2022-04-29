//
//  InAppAnnouncementWindow.swift
//  iOS
//
//  Created by Anton Spivak on 28.04.2022.
//

import UIKit

class InAppAnnouncementWindow: UIWindow {
    
    struct InAppAnnouncement: Equatable {
        
        let image: UIImage?
        let attributedString: NSAttributedString
        let tintColor: UIColor
    }
    
    private struct CurrentInAppAnnouncement {
        
        let value: InAppAnnouncement
        let view: UIView
    }
    
    private static var retain: InAppAnnouncementWindow?
    
    private var storage: [InAppAnnouncement] = []
    private var subscriptions: [NSObjectProtocol] = []
    private var inAppAnnouncementView: CurrentInAppAnnouncement? = nil
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        isHidden = false
        backgroundColor = .clear
        
        rootViewController = UIViewController()
        rootViewController?.view.isUserInteractionEnabled = false
        rootViewController?.view.alpha = 0
        
        Self.retain = self
        self.subscribe()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setNeedsDisplayInAppAnnouncement() {
        guard inAppAnnouncementView == nil,
              let inAppAnnouncement = storage.popLast()
        else {
            return
        }
        
        let view = InAppAnnouncementView(inAppAnnouncement: inAppAnnouncement)
        let size = view.systemLayoutSizeFitting(
            CGSize(width: bounds.width - 64, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        
        view.frame = CGRect(x: 32, y: safeAreaInsets.top + 4, width: size.width, height: size.height)
        
        inAppAnnouncementView = CurrentInAppAnnouncement(
            value: inAppAnnouncement,
            view: view
        )
        
        show(inAppAnnouncementView: view, completion: { [weak self] in
            self?.inAppAnnouncementView?.view.removeFromSuperview()
            self?.inAppAnnouncementView = nil
            
            self?.setNeedsDisplayInAppAnnouncement()
        })
    }
    
    private func show(inAppAnnouncementView: InAppAnnouncementView, completion: @escaping () -> ()) {
        inAppAnnouncementView.alpha = 0
        inAppAnnouncementView.transform = .identity
            .translatedBy(x: 0, y: -inAppAnnouncementView.frame.maxY)
            .scaledBy(x: 0.96, y: 0.96)
        
        addSubview(inAppAnnouncementView)
        
        let animate = { (_ block: @escaping () -> (), completion: @escaping () -> ()) in
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: block,
                completion: { _ in
                    completion()
                }
            )
        }
        
        animate({
            inAppAnnouncementView.alpha = 1
            inAppAnnouncementView.transform = .identity
        }, {})
        
        let finish = { [weak inAppAnnouncementView] in
            animate({
                guard let inAppAnnouncementView = inAppAnnouncementView
                else {
                    return
                }
                
                inAppAnnouncementView.alpha = 0
                inAppAnnouncementView.transform = .identity
                    .translatedBy(x: 0, y: -inAppAnnouncementView.frame.maxY)
                    .scaledBy(x: 0.96, y: 0.96)
            }, {
                completion()
            })
        }
        
        let item = DispatchWorkItem(block: {
            finish()
        })
        
        inAppAnnouncementView.touchHandler = {
            item.cancel()
            finish()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: item)
    }
    
    private func subscribe() {
        let token = InAppAnnouncementCenter.shared.observe(
            of: InAppAnnouncementInfo.self,
            on: .main,
            using: { [weak self] content in
                let announcement = InAppAnnouncement(
                    image: content.icon.image,
                    attributedString: NSAttributedString(
                        string: content.text,
                        attributes: [
                            .foregroundColor : UIColor.hui_textPrimary,
                            .font : UIFont.font(for: .subheadline)
                        ]
                    ),
                    tintColor: content.tintColor
                )
                
                if let inAppAnnouncementView = self?.inAppAnnouncementView,
                   inAppAnnouncementView.value == announcement
                {
                    return
                }

                self?.storage.insert(announcement, at: 0)
                self?.setNeedsDisplayInAppAnnouncement()
            }
        )
        subscriptions.append(token)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTest = super.hitTest(point, with: event)
        guard hitTest != self
        else {
            return nil
        }
        return hitTest
    }
}
