//
//  Created by Anton Spivak
//

import Foundation
import HuetonMOON

public struct GithubMOON: HuetonMOON {
    
    public var endpoint: URL {
        guard let url = URL(string: "https://hueton.github.io/configurations/wallet/mobile")
        else {
            fatalError("Can't happend.")
        }
        return url
    }
    
    public init() {}
}
