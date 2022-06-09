//
//  Created by Anton Spivak
//

#import "Objective42.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SUI)

/// Checks class reponds instance methid and perfroms selector
- (id _Nullable)o42_performSelector:(SEL)aSelector;

/// Checks class reponds instance methid and perfroms selector with object
- (id _Nullable)o42_performSelector:(SEL)aSelector withObject:(id _Nullable)object;

/// Checks class reponds instance methid and perfroms selector with two objects
- (id _Nullable)o42_performSelector:(SEL)aSelector withObject:(id _Nullable)object1 withObject:(id _Nullable)object2;

/// Returns `YES` if class name starts with `_`
- (BOOL)o42_isKindOfSystemClass;

@end

NS_ASSUME_NONNULL_END
