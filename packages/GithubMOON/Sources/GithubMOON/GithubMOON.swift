//
//  Created by Anton Spivak
//

import Foundation
import JustonMOON

public struct GithubMOON: JustonMOON {
    
    public var endpoint: URL {
        guard let url = URL(string: "https://juston-io.github.io/configurations/wallet/mobile")
        else {
            fatalError("Can't happend.")
        }
        return url
    }
    
    public init() {}
}
