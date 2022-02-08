//
//  Created by Anton Spivak
//

import SystemUI
import UIKit

open class UnicornRefreshControl: SUIRefreshControl {
    public var animationView: UnicornRefreshControlContentView {
        contentView as! UnicornRefreshControlContentView
    }

    override public init() {
        let contentView = UnicornRefreshControlContentView()
        super.init(contentView: contentView)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
