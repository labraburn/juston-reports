//
//  UICollectionViewPreviewCell.swift
//  iOS
//
//  Created by Anton Spivak on 27.06.2022.
//

import UIKit

protocol UICollectionViewPreviewCell: UICollectionViewCell {
    
    var contextMenuPreviewView: UIView? { get }
}

extension UICollectionViewPreviewCell {
    
    var contextMenuPreviewView: UIView? { self }
}
