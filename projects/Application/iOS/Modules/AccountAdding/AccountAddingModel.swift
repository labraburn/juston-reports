//
//  AccountAddingChunk.swift
//  iOS
//
//  Created by Anton Spivak on 21.03.2022.
//

import UIKit
import HuetonCORE

@MainActor
struct AccountAddingModel {
    
    enum Kind {
        
        case `default`(image: UIImage, text: String)
        case words(strings: [String], text: String)
        case `import`(text: String)
        case appearance
    }
    
    struct Field {
        
        final class Value {
            
            var text: String = ""
        }
        
        let title: String
        let placeholder: String
        let action: AccountAddingItem.TextFieldAction
    }
    
    struct Action {
        
        let title: String
        let kind: AccountAddingItem.ButtonKind
        let block: AccountAddingItem.ButtonAction
    }
    
    let kind: Kind
    let title: String
    let fields: [Field]
    let actions: [Action]
    let isModalInPresentation: Bool
}

extension AccountAddingModel {
    
    static var initial: AccountAddingModel {
        AccountAddingModel(
            kind: .default(
                image: .hui_placeholder512,
                text: "AccountAddingInitialDescription".asLocalizedKey
            ),
            title: "AccountAddingInitialTitle".asLocalizedKey,
            fields: [],
            actions: [
                .init(
                    title: "AccountAddingNextButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        viewController.next(.importOrCreate)
                    }
                ),
            ],
            isModalInPresentation: false
        )
    }
    
    static var importOrCreate: AccountAddingModel {
        AccountAddingModel(
            kind: .default(
                image: .hui_placeholder512,
                text: "AccountAddingIOCDescription".asLocalizedKey
            ),
            title: "AccountAddingIOCTitle".asLocalizedKey,
            fields: [],
            actions: [
                .init(
                    title: "AccountAddingCreateButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        createAccount({ [weak viewController] result in
                            switch result {
                            case let .success(result):
                                viewController?.next(.words(result.0, address: result.1))
                                viewController?.feedbackGenerator.impactOccurred()
                            case let .failure(error):
                                viewController?.present(error)
                            }
                        })
                    }
                ),
                .init(
                    title: "AccountAddingImportButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        viewController.next(.import)
                    }
                ),
            ],
            isModalInPresentation: false
        )
    }
    
    static var `import`: AccountAddingModel {
        // TODO: Should be reworked
        var address = ""
        return AccountAddingModel(
            kind: .import(
                text: "AccountAddingImportDescription".asLocalizedKey
            ),
            title: "AccountAddingImportTitle".asLocalizedKey,
            fields: [
                .init(
                    title: "Public key".asLocalizedKey,
                    placeholder: "Text key here".asLocalizedKey,
                    action: { textField in
                        address = textField.text ?? ""
                    }
                ),
            ],
            actions: [
                .init(
                    title: "AccountAddingNextButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        guard let address = Address(string: address)
                        else {
                            return
                        }
                        
                        viewController.next(.appearance(for: address.raw))
                    }
                ),
            ],
            isModalInPresentation: false
        )
    }
    
    static func words(_ array: [String], address: Address.RawAddress) -> AccountAddingModel {
        AccountAddingModel(
            kind: .words(
                strings: array,
                text: "AccountAddingWordsDescription".asLocalizedKey
            ),
            title: "AccountAddingWordsTitle".asLocalizedKey,
            fields: [],
            actions: [
                .init(
                    title: "AccountAddingCopyButton".asLocalizedKey,
                    kind: .secondary,
                    block: { viewController in
                        let pasteboard = UIPasteboard.general
                        pasteboard.string = array.joined(separator: " ")
                    }
                ),
                .init(
                    title: "AccountAddingNextButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        viewController.next(.appearance(for: address))
                    }
                ),
            ],
            isModalInPresentation: true
        )
    }
    
    static func appearance(for rawAddress: Address.RawAddress) -> AccountAddingModel {
        var name = ""
        return AccountAddingModel(
            kind: .appearance,
            title: "AccountAddingAppearanceTitle".asLocalizedKey,
            fields: [
                .init(
                    title: "AccountAddingAccountNameTitle".asLocalizedKey,
                    placeholder: "AccountAddingAccountNamePlaceholder".asLocalizedKey,
                    action: { textField in
                        name = textField.text ?? ""
                    }
                ),
            ],
            actions: [
                .init(
                    title: "AccountAddingDoneButton".asLocalizedKey,
                    kind: .primary,
                    block: { viewController in
                        guard !name.isEmpty
                        else {
                            return
                        }
                        
                        let account = Account(rawAddress: rawAddress, name: name)
                        viewController.finish(with: account)
                    }
                ),
            ],
            isModalInPresentation: true
        )
    }
}

fileprivate var _createAccountTask: Task<Void, Never>? = nil
fileprivate func createAccount(_ completion: @escaping (_ result: Result<([String], Address.RawAddress), Error>) -> ()) {
    guard _createAccountTask == nil
    else {
        return
    }
    
    _createAccountTask = Task {
        do {
            let result = try await HuetonCORE.KeyCreate()
            DispatchQueue.main.async(execute: { completion(.success((result.words, result.key.rawAddress))) })
        } catch {
            DispatchQueue.main.async(execute: { completion(.failure(error)) })
        }
        
        _createAccountTask = nil
    }
}
