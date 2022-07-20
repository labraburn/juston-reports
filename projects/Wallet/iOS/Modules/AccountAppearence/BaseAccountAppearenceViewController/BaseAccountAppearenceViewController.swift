//
//  AccountAppearenceViewController.swift
//  iOS
//
//  Created by Anton Spivak on 01.06.2022.
//

import UIKit
import JustonUI
import JustonCORE

class BaseAccountAppearenceViewController: UIViewController {
    
    private let errorFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    private let descriptionLabel = UILabel().with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.font = .font(for: .headline)
        $0.textColor = .jus_textPrimary
        $0.text = "AccountAppearenceDescription".asLocalizedKey
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
    })
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.clipsToBounds = false
        $0.backgroundColor = .jus_backgroundPrimary
        $0.contentInset = UIEdgeInsets(top: 0, left: 16, right: 16, bottom: 0)
        
        $0.delegate = self
        $0.dataSource = self
        $0.register(reusableCellClass: StyleCell.self)
        
        let collectionViewLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.scrollDirection = .horizontal
    })
    
    private lazy var nameTextView = BorderedTextView(caption: "AccountAppearenceNameFieldDescription".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textView.delegate = self
        $0.textView.returnKeyType = .done
        $0.textView.autocapitalizationType = .sentences
        $0.textView.minimumContentSizeHeight = 21
        $0.textView.maximumContentSizeHeight = 21
    })
    
    lazy var doneButton = PrimaryButton(title: "CommonDone".asLocalizedKey).with({
        $0.translatesAutoresizingMaskIntoConstraints = false
    })
    
    private var selectedCardStyleIndexPath: IndexPath? = nil
    private let cardStyles: [AccountAppearance] = [
        .default,
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient0.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient1.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient2.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient3.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient4.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
        .init(
            kind: .gradientImage(imageData: UIImage.jus_cardGradient5.pngData()!, strokeColor: 0xFEF6FF0A),
            tintColor: 0xFFFFFFFF,
            controlsForegroundColor: 0xFFFFFFFF,
            controlsBackgroundColor: 0xFFFFFF14
        ),
    ]
    
    public var name: String? {
        get { nameTextView.textView.text }
        set { nameTextView.textView.text = newValue }
    }
    
    public var style: AccountAppearance {
        get {
            if let selectedCardStyleIndexPath = selectedCardStyleIndexPath {
                return cardStyles[selectedCardStyleIndexPath.row]
            } else {
                return .default
            }
        }
        set {
            if let index = cardStyles.firstIndex(of: newValue) {
                let indexPath = IndexPath(row: index, section: 0)
                collectionView(collectionView, didSelectItemAt: indexPath)
            } else {
                collectionView(collectionView, didSelectItemAt: .init(row: 0, section: 0))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "AccountAppearenceTitle".asLocalizedKey
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .jus_backgroundPrimary
        
        view.addSubview(descriptionLabel)
        view.addSubview(nameTextView)
        view.addSubview(collectionView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate({
            descriptionLabel.topAnchor.pin(to: view.safeAreaLayoutGuide.topAnchor, constant: 16)
            descriptionLabel.pin(horizontally: view, left: 16, right: 16)
            
            nameTextView.topAnchor.pin(to: descriptionLabel.bottomAnchor, constant: 32)
            nameTextView.pin(horizontally: view, left: 16, right: 16)
            
            collectionView.topAnchor.pin(to: nameTextView.bottomAnchor, constant: 24)
            collectionView.pin(horizontally: view, left: 0, right: 0)
            collectionView.heightAnchor.pin(to: 164)
            
            doneButton.topAnchor.pin(greaterThan: collectionView.bottomAnchor, constant: 24)
            doneButton.pin(horizontally: view, left: 16, right: 16)
            
            view.safeAreaLayoutGuide.bottomAnchor.pin(to: doneButton.bottomAnchor, constant: 8)
        })
        
        style = .default
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(false)
    }
    
    func markNameTextViewAsError() {
        nameTextView.shake()
        nameTextView.textView.textColor = .jus_letter_red
        errorFeedbackGenerator.impactOccurred()
    }
}

extension BaseAccountAppearenceViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        nameTextView.setFocused(true)
        textView.textColor = .white
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text != "\n"
        else {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        nameTextView.setFocused(false)
    }
}

extension BaseAccountAppearenceViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardStyles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(reusableCellClass: StyleCell.self, for: indexPath)
        cell.fill(with: cardStyles[indexPath.row])
        return cell
    }
}

extension BaseAccountAppearenceViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCardStyleIndexPath != nil,
           selectedCardStyleIndexPath != indexPath
        {
            selectionFeedbackGenerator.selectionChanged()
        }
        
        if let selectedCardStyleIndexPath = selectedCardStyleIndexPath {
            collectionView.deselectItem(at: selectedCardStyleIndexPath, animated: true)
        }
        
        selectedCardStyleIndexPath = indexPath
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

extension BaseAccountAppearenceViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(
            width: collectionView.bounds.height / 3 * 2,
            height: collectionView.bounds.height
        )
    }
}
