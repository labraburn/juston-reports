//
//  DeeplinkURL.swift
//  iOS
//
//  Created by Anton Spivak on 07.06.2022.
//

import Foundation
import SwiftyTON

enum DeeplinkURL {
    
    case tonURL(ConvenienceURL)
    
    case address(value: Address)
    case transfer(destination: Address, amount: Currency?, text: String?)
    
    public var url: URL {
        switch self {
        case let .tonURL(convenienceURL):
            return convenienceURL.url
        case let .address(value):
            let path = value.description
            guard let components = URLComponents(string: "https://hueton.com/action/address/\(path)")
            else {
                fatalError("Can't create URL from \(self)")
            }
            
            guard let url = components.url
            else {
                fatalError("Can't create URL from \(self)")
            }
            
            return url
        case let .transfer(destination, amount, text):
            let path = destination.description
            guard var components = URLComponents(string: "https://hueton.com/action/transfer/\(path)")
            else {
                fatalError("Can't create URL from \(self)")
            }
            
            var queryItems: [URLQueryItem] = []
            if let amount = amount {
                queryItems.append(.init(name: "amount", value: "\(amount.value)"))
            }
            if let text = text {
                queryItems.append(.init(name: "text", value: "\(text)"))
            }
            
            components.queryItems = queryItems
            
            guard let url = components.url
            else {
                fatalError("Can't create URL from \(self)")
            }
            
            return url
        }
    }
    
    //
    
    public init?(
        _ value: String
    ) {
        guard let url = URL(string: value)
        else {
            return nil
        }
        
        self.init(url)
    }
    
    public init?(
        _ value: URL
    ) {
        let url: URL
        if let converted = DeeplinkURL.universalIntoDeeplink(value) {
            url = converted
        } else {
            url = value
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return nil
        }
        
        if let tonURL = ConvenienceURL(components) {
            self = .tonURL(tonURL)
        } else if components.scheme == "hueton" {
            switch components.host {
            case "transfer":
                let lastPathComponent = (components.path as NSString).lastPathComponent
                guard let address = Address(string: lastPathComponent)
                else {
                    return nil
                }
                
                var amount: Currency?
                var text: String?
                
                components.queryItems?.forEach({
                    switch $0.name {
                    case "amount":
                        guard let value = $0.value,
                              let int = Int64(value)
                        else {
                            break
                        }
                        
                        amount = Currency(value: int)
                    case "text", "message":
                        text = $0.value
                    default:
                        break
                    }
                })
                
                self = .transfer(destination: address, amount: amount, text: text)
            case "address":
                let lastPathComponent = (components.path as NSString).lastPathComponent
                guard let address = Address(string: lastPathComponent)
                else {
                    return nil
                }
                
                self = .address(value: address)
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    private static func universalIntoDeeplink(
        _ url: URL
    ) -> URL? {
        var replaced = url
            .absoluteString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        
        let prefex = "hueton.com/action/"
        guard replaced.hasPrefix(prefex)
        else {
            return nil
        }
        
        replaced = replaced.replacingOccurrences(of: prefex, with: "")
        return URL(string: "hueton://\(replaced)")
    }
}
