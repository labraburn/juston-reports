//
//  Created by Anton Spivak
//

import Foundation

extension KeyedDecodingContainer {
    
    /// Decodes a value of the given type for the given key.
    ///
    /// - parameter type: The type of value to decode.
    /// - parameter key: The key that the decoded value is associated with.
    /// - parameter fallback: The value applied if something goes wrong
    /// - returns: A value of the requested type, if present for the given key
    ///   and convertible to the requested type.
    public func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, fallback: T) -> T where T: Decodable {
        (try? decode(type, forKey: key)) ?? fallback
    }
}
