//
//  CollectionCompositionView.swift
//  iOS
//
//  Created by Anton Spivak on 05.02.2022.
//

import UIKit
import BilftUI

protocol CollectionCompositionViewDelegate: UICollectionViewDelegate {
    
    func collectionCompositionViewShouldStartReload(
        _ view: CollectionCompositionView
    ) -> Bool
}

class DiffableCollectionView: UICollectionView {
    
    var isContentOffsetUpdatesLocked = false
    
    override var contentOffset: CGPoint {
        get { super.contentOffset }
        set {
            guard !isContentOffsetUpdatesLocked
            else {
                return
            }
            
            super.contentOffset = newValue
        }
    }
    
    override var bounds: CGRect {
        get { super.bounds }
        set {
            var bounds = newValue
            if isContentOffsetUpdatesLocked {
                bounds.origin = super.bounds.origin
            }
            
            super.bounds = newValue
        }
    }
}

class CollectionCompositionView: UIView {
    
    static let layout = UICollectionViewFlowLayout()
    
    private var additionalLogoViewOffset = CGFloat.zero
    private var additionalInset = CGFloat.zero
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var isLoadingAnimationInProgress = false
    private var isAbleStartLoading = true
    
    weak var delegate: CollectionCompositionViewDelegate?
    
    var logoLoadingAddiotionlText: String? {
        get { logoView.text }
        set { logoView.text = newValue }
    }
    
    let logoView = AnimatedLogoView(
        frame: .zero
    )
    
    let backgroundView = BackgroundView(
        frame: .zero
    )
    
    let collectionView = DiffableCollectionView(
        frame: .zero,
        collectionViewLayout: CollectionCompositionView.layout
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _init()
    }
    
    private func _init() {
        logoView.update(presentation: .on)
        logoView.backgroundColor = .clear
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        addSubview(backgroundView)
        addSubview(collectionView)
        addSubview(logoView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        collectionView.frame = bounds
        
        let logoViewHeight = CGFloat(64)
        
        logoView.bounds = CGRect(x: 0, y: 0, width: 171, height: logoViewHeight)
        logoView.center = CGPoint(
            x: bounds.midX,
            y: safeAreaInsets.top + additionalLogoViewOffset + logoViewHeight / 2
        )
        
        let shoudLockContnetOffset = collectionView.isDragging && collectionView.isTracking
        if shoudLockContnetOffset {
            collectionView.isContentOffsetUpdatesLocked = true
        }
        
        var contentInset = collectionView.contentInset
        contentInset.top = logoView.bounds.height + additionalInset + 12
        collectionView.contentInset = contentInset
        
        if shoudLockContnetOffset {
            collectionView.isContentOffsetUpdatesLocked = false
        }
    }
    
    func updateLoadingAnimationWithProgress(_ progress: Double) {
        guard isLoadingAnimationInProgress
        else {
            return
        }
        
        logoView.updateLoadingAnimationWithProgress(progress)
    }
    
    func startLoadingAnimation() {
        startLoadingAnimationIfNeccessary(applyInsets: false)
    }
    
    private func startLoadingAnimationIfNeccessary(applyInsets: Bool) {
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
        
        if applyInsets {
            additionalInset = CollectionCompositionView.reloadOffset / 2
        }
        
        isAbleStartLoading = false
        isLoadingAnimationInProgress = true
    }
    
    func finishLoadingAnimationIfNeeded() {
        guard isLoadingAnimationInProgress
        else {
            return
        }
        
        feedbackGenerator.impactOccurred(intensity: 0.3)
        logoView.stopLoadingAnimation()
        additionalInset = .zero
        
        setNeedsLayout()
        
        if !collectionView.isDragging,
           !collectionView.isTracking
        {
            if collectionView.contentOffset.y < -collectionView.adjustedContentInset.top {
                let contentOffset = CGPoint(
                    x: -collectionView.adjustedContentInset.left,
                    y: -collectionView.adjustedContentInset.top
                )
                
                collectionView.setContentOffset(contentOffset, animated: true)
            }
            
            UIView.animate(
                withDuration: 0.64,
                delay: 0.0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.0,
                options: [.curveEaseOut],
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { _ in
                    self.isAbleStartLoading = true
                }
            )
        }
        
        isLoadingAnimationInProgress = false
    }
}

extension CollectionCompositionView: UICollectionViewDelegate {
    
    static let reloadOffset = CGFloat(64)
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let reloadOffset = CollectionCompositionView.reloadOffset
        let contentOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top - additionalInset
        
        let additionalOffset = -contentOffset / 2
        additionalLogoViewOffset = max(additionalOffset, 0)
        
        setNeedsLayout()
        
        if additionalOffset > reloadOffset {
            startLoadingAnimationIfNeccessary(applyInsets: true)
        }
        
        if !isLoadingAnimationInProgress && isAbleStartLoading {
            let progress = additionalOffset / reloadOffset
            logoView.prepareLoadingAnimation(with: progress)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
