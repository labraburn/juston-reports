//
//  SchemeURL.swift
//  iOS
//
//  Created by Anton Spivak on 07.06.2022.
//

import Foundation
import SwiftyTON

enum SchemeURL {
    
    enum Scheme: String {
        
        case ton = "ton"
        case juston = "juston"
        case pay = "juston-pay"
        
        var isEditableParameters: Bool {
            switch self {
            case .pay:
                return false
            case .ton, .juston:
                return true
            }
        }
    }
    
    case transfer(scheme: Scheme, configuration: TransferConfiguration)
    
    var url: URL {
        switch self {
        case let .transfer(scheme, configuration):
            let path = configuration.destination.displayName
            guard let url = URLComponents.url("\(scheme.rawValue)://transfer/\(path)", queryItems: configuration.queryItems)
            else {
                fatalError("Can't create URLComponents from \(self)")
            }
            
            return url
        }
    }
    
    init?(
        _ value: String
    ) {
        guard let url = URL(string: value)
        else {
            return nil
        }
        
        self.init(url)
    }
    
    init?(
        _ value: URL
    ) {
        guard let components = URLComponents(
            url: value,
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }

        guard let scheme = Scheme(rawValue: components.scheme ?? "")
        else {
            return nil
        }

        switch components.host {
        case "transfer":
            break
        default:
            return nil
        }

        let lastPathComponent = (components.path as NSString).lastPathComponent
        guard let destinationAddress = ConcreteAddress(string: lastPathComponent)
        else {
            return nil
        }

        self = .transfer(
            scheme: scheme,
            configuration: TransferConfiguration(
                destination: DisplayableAddress(rawValue: destinationAddress),
                queryItems: components.queryItems
            )
        )
    }
}

private extension URLComponents {
    
    static func url(
        _ string: String,
        queryItems: [URLQueryItem]
    ) -> URL? {
        guard var components = URLComponents(string: string)
        else {
            return nil
        }
        
        components.queryItems = queryItems
        return components.url
    }
}

private extension TransferConfiguration {
    
    init(
        destination: DisplayableAddress,
        queryItems: [URLQueryItem]?
    ) {
        var amount: Currency?
        var message: String?
        
        var payload: Data?
        var initial: Data?
        
        queryItems?.forEach({
            guard let value = $0.value
            else {
                return
            }
            
            switch $0.name.lowercased() {
            case "amount":
                guard let int = Int64(value)
                else {
                    break
                }
                
                amount = Currency(value: int)
            case "text", "message":
                message = value
            case "bin":
                payload = Data(base64Encoded: value.base64URLUnescaped())
            case "init":
                initial = Data(base64Encoded: value.base64URLUnescaped())
            default:
                break
            }
        })
        
        self.destination = destination
        self.amount = amount
        self.message = message
        self.payload = payload
        self.initial = initial
    }
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        items.append("amount", value: amount?.value)
        items.append("text", value: message)
        items.append("bin", value: payload?.base64EncodedString(options: []).base64URLEscaped())
        items.append("init", value: initial?.base64EncodedString(options: []).base64URLEscaped())
        return items
    }
}

private extension Array where Element == URLQueryItem {
    
    mutating func append(_ name: String, value: Any?) {
        guard let value = value
        else {
            return
        }
        
        append(URLQueryItem(name: name, value: "\(value)"))
    }
}
