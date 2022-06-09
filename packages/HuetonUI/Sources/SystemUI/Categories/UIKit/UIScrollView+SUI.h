//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SUI)

/// Scroll to top via system animation
- (void)sui_scrollToTopIfPossible:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
