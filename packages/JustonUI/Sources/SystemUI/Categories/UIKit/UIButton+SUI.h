//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SUI)

// Shows UIContextMenuInteraction if currently nothing presented
- (void)sui_presentMenuIfPossible:(UIMenu *)menu API_AVAILABLE(ios(14.0)) API_UNAVAILABLE(watchos, tvos);

@end

NS_ASSUME_NONNULL_END
