//
//  Created by Anton Spivak
//

import Foundation
import CoreData

internal class StringArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSArray.self
    }
    
    override class var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSString.self]
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let result = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: Self.allowedTopLevelClasses, from: data),
              let array = result as? [String]
        else {
            fatalError("Wrong data type: value must be a Data object; received \(type(of: value))")
        }
        
        return array
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let array = value as? [String],
              let value = try? NSKeyedArchiver.archivedData(withRootObject: array as NSArray, requiringSecureCoding: true)
        else {
            fatalError("Wrong data type: value must be a NSArray object; received \(type(of: value))")
        }
        return value
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: .StringArrayTransformer)
    }
}

private extension NSValueTransformerName {
    
    static let StringArrayTransformer = NSValueTransformerName(rawValue: "StringArrayTransformer")
}
