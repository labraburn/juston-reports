//
//  File.swift
//  
//
//  Created by Anton on 25.02.2021.
//

import Foundation

public struct Key: RawRepresentable, Hashable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public class Values<T> {
        
    private var container: [Key : T]
    public var allValues: [Key : T] { container }
    
    public init(_ values: [Key : T]) {
        container = values
    }
    
    public subscript(key: Key) -> T {
        get {
            guard let value = container[key] else {
                fatalError("Value with key \(key.rawValue) uniform/attribute can't be located")
            }
            return value
        }
        set(new) {
            container[key] = new
        }
    }
}
