//
//  Created by Anton Spivak
//

#import "UIEdgeInsets+SUI.h"

UIEdgeInsets UIEdgeInsetsWithAdditionalUIEdgeInsets(UIEdgeInsets insets, UIEdgeInsets additional) {
    UIEdgeInsets _insets = insets;
    _insets.left += additional.left;
    _insets.top += additional.top;
    _insets.right += additional.right;
    _insets.bottom += additional.bottom;
    return _insets;
}
