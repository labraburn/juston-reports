//
//  CollectionCompositionView.swift
//  iOS
//
//  Created by Anton Spivak on 05.02.2022.
//

import UIKit
import BilftUI
import SystemUI
import DeclarativeUI

protocol CollectionCompositionViewDelegate: UICollectionViewDelegate {
    
    func collectionCompositionViewShouldStartReload(
        _ view: CollectionCompositionView
    ) -> Bool
}

class CollectionCompositionView: UIView {
    
    private var additionalLogoViewOffset = CGFloat.zero
    private var additionalInset = CGFloat.zero
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var isLoadingAnimationInProgress = false
    private var isAbleStartLoading = true
    
    weak var delegate: CollectionCompositionViewDelegate?
    
    let logoView = AnimatedLogoView(
        frame: .zero
    )
    
    let visualEffectView = UIView().with {
        $0.backgroundColor = .bui_backgroundPrimary
        $0.isHidden = true
    }
    
    let collectionView: DiffableCollectionView
    
    init(collectionViewLayout: UICollectionViewLayout) {
        collectionView = DiffableCollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        
        super.init(frame: .zero)
        
        logoView.update(presentation: .on)
        logoView.backgroundColor = .clear
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        addSubview(collectionView)
        addSubview(visualEffectView)
        addSubview(logoView)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        let logoViewHeight = CGFloat(64)
        var logoOffset = additionalLogoViewOffset
        
        if isLoadingAnimationInProgress {
            logoOffset += additionalInset
        }
        
        logoView.bounds = CGRect(x: 0, y: 0, width: 171, height: logoViewHeight)
        logoView.center = CGPoint(
            x: bounds.midX,
            y: safeAreaInsets.top + logoOffset + logoViewHeight / 2 - 12
        )
        
        visualEffectView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: logoView.frame.maxY
        )
        
        if !collectionView.isDragging,
           !collectionView.isTracking,
           !collectionView.isDecelerating
        {
            updateCollectionViewContentInset()
        }
    }
    
    // MARK: API
    
    func startLoadingAnimation() {
        startLoadingAnimationIfNeccessary()
        
        if collectionView.contentOffset.y == -collectionView.adjustedContentInset.top,
           !collectionView.isDragging,
           !collectionView.isTracking,
           !collectionView.isDecelerating
        {
            logoView.showTextLabel(progress: 1)
            updateCollectionViewContentInset()
            
            setNeedsLayout()
            UIView.animate(
                withDuration: 0.12,
                animations: {
                    self.layoutIfNeeded()
                }
            )
            
            collectionView.setContentOffset(
                CGPoint(
                    x: collectionView.contentOffset.x,
                    y: -collectionView.adjustedContentInset.top
                ),
                animated: true
            )
        }
    }
    
    func finishLoadingAnimationIfNeeded() {
        guard isLoadingAnimationInProgress
        else {
            return
        }
        
        logoView.stopLoadingAnimation()
        isLoadingAnimationInProgress = false
        
        setNeedsLayout()
        UIView.animate(
            withDuration: 0.42,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [.curveEaseOut],
            animations: {
                if !self.collectionView.isDragging && !self.collectionView.isTracking {
                    self.updateCollectionViewContentInset()
                }
                self.layoutIfNeeded()
            },
            completion: { _ in
                if !self.collectionView.isDragging && !self.collectionView.isTracking {
                    self.isAbleStartLoading = true
                }
            }
        )
    }
    
    // MARK: Overrides
    
    class func collectionViewLayout() -> UICollectionViewLayout {
        fatalError("Override me")
    }
    
    // MARK: Private
    
    private func startLoadingAnimationIfNeccessary() {
        guard !isLoadingAnimationInProgress,
              isAbleStartLoading
        else {
            return
        }
        
        let shouldStartReload = delegate?.collectionCompositionViewShouldStartReload(self) ?? false
        guard shouldStartReload
        else {
            return
        }
        
        logoView.startLoadingAnimation()
        feedbackGenerator.impactOccurred()
        
        isAbleStartLoading = false
        isLoadingAnimationInProgress = true
    }
    
    private func updateCollectionViewContentInset() {
        if isLoadingAnimationInProgress && !logoView.label.isHidden {
            additionalInset = CollectionCompositionView.defaultOffset
        } else {
            additionalInset = 0
        }
        
        var contentInset = collectionView.contentInset
        contentInset.top = logoView.bounds.height - 12 + additionalInset
        
        var scrollIndicatorInsets = collectionView.verticalScrollIndicatorInsets
        scrollIndicatorInsets.top = contentInset.top - additionalInset
        
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = scrollIndicatorInsets
    }
    
    private func updateVisualEffectViewHidden(_ flag: Bool) {
        guard flag != visualEffectView.isHidden
        else {
            return
        }
        
        if flag {
            UIView.animate(withDuration: 0.01, animations: {
                self.visualEffectView.alpha = 0
            }, completion: { _ in
                self.visualEffectView.isHidden = true
            })
        } else {
            visualEffectView.alpha = 0
            visualEffectView.isHidden = false
            
            UIView.animate(withDuration: 0.01, animations: {
                self.visualEffectView.alpha = 1
            }, completion: nil)
        }
    }
}

extension CollectionCompositionView: UICollectionViewDelegate {
    
    static let reloadOffset = CGFloat(64)
    static let defaultOffset = CGFloat(24)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let reloadOffset = CollectionCompositionView.reloadOffset
        let contentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        
        updateVisualEffectViewHidden(contentOffset <= 0)
        
        let additionalOffset = -contentOffset / 2
        additionalLogoViewOffset = max(additionalOffset, 0)
        
        setNeedsLayout()
        
        if !isLoadingAnimationInProgress && isAbleStartLoading {
            let progress = additionalOffset / reloadOffset
            logoView.prepareLoadingAnimation(with: progress)
        }
        
        if additionalOffset > reloadOffset {
            startLoadingAnimationIfNeccessary()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            updateCollectionViewContentInset()
        } else {
            UIView.animate(
                withDuration: 0.42,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.updateCollectionViewContentInset()
                },
                completion: nil
            )
        }
        
        guard !isLoadingAnimationInProgress,
              !decelerate
        else {
            return
        }
        
        isAbleStartLoading = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !isLoadingAnimationInProgress
        else {
            return
        }
        
        isAbleStartLoading = true
    }
}
