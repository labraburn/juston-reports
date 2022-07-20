//
//  Created by Anton Spivak
//

#import "../../SystemUI.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (SUI)

/// Returns first responder in chain if it's subclass of given class
- (UIResponder * _Nullable)sui_traverseResponderChainForSubclassOfClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
