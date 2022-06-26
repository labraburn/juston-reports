//
//  Created by Anton Spivak
//

import Foundation

public extension String {
    
    private static var detector: NSDataDetector {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else {
            fatalError("[HuetonCORE]: Can't create NSDataDetector")
        }
        return detector
    }
    
    var url: URL? {
        let string = trimmingCharacters(in: .whitespaces)
        
        let range = NSRange(location: 0, length: string.utf16.count)
        let match = Self.detector.firstMatch(
            in: string,
            options: [],
            range: range
        )
        
        if let match = match,
           match.range == range
        {
            return URL(string: string)
        }
        
        return nil
    }
}
