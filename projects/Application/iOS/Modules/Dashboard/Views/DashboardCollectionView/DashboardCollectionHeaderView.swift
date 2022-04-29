//
//  DashboardCollectionHeaderView.swift
//  iOS
//
//  Created by Anton Spivak on 19.03.2022.
//

import UIKit
import HuetonUI

protocol DashboardCollectionHeaderViewDelegate: AnyObject {
    
    func dashboardCollectionHeaderViewLayoutType(
        `for` view: DashboardCollectionHeaderView
    ) -> DashboardCollectionHeaderView.LayoutType
}

protocol DashboardCollectionHeaderSubview: UIView {
    
    var layoutType: DashboardCollectionHeaderView.LayoutType { get set }
    var compacthHeight: CGFloat { get }
}

class DashboardCollectionHeaderView: UICollectionReusableView {
    
    struct LayoutType {
        
        enum Kind {
            
            case large
            case compact
        }
        
        let bounds: CGRect
        let safeAreaInsets: UIEdgeInsets
        let kind: Kind
    }
    
    weak var delegate: DashboardCollectionHeaderViewDelegate?
    
    var subview: DashboardCollectionHeaderSubview? {
        didSet {
            oldValue?.removeFromSuperview()
            
            guard let subview = subview
            else {
                return
            }

            addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.pinned(edges: self)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        var systemLayoutSizeFitting = targetSize
        systemLayoutSizeFitting.height = 0
        
        guard let type = delegate?.dashboardCollectionHeaderViewLayoutType(for: self),
              let subview = subview
        else {
            return systemLayoutSizeFitting
        }
        
        subview.layoutType = type
        
        switch type.kind {
        case .compact:
            systemLayoutSizeFitting.height = subview.compacthHeight
        case .large:
            let enclosingSafeAreaInsets = type.safeAreaInsets
            let enclosingBounds = type.bounds
            systemLayoutSizeFitting.height = enclosingBounds.height - enclosingSafeAreaInsets.top - enclosingSafeAreaInsets.bottom
        }
        
        return systemLayoutSizeFitting
    }
}

extension DashboardCollectionHeaderView.LayoutType: Equatable {}
extension DashboardCollectionHeaderView.LayoutType.Kind: Equatable {}
