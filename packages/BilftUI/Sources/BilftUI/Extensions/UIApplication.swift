//
//  Created by Anton Spivak.
//

import UIKit

extension UIApplication {
    
    public static func cleanLaunchScreenCache() {
        do {
           try FileManager.default.removeItem(atPath: "\(NSHomeDirectory())/Library/SplashBoard")
        } catch {
           print("Failed to clean up launch screen cache: \(error)")
        }
    }
}
